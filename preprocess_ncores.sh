#!/bin/bash
#                      
#	preprocess_ncores.sh
#
#	This script runs preprocessing across multiple cores (quality filtering, adapter trimming, and low-complexity filtering)
#	Chiu Laboratory
#	University of California, San Francisco
#	January, 2014
#
# Copyright (C) 2014 Charles Chiu - All Rights Reserved
# SURPI has been released under a modified BSD license.
# Please see license file for details.

scriptname=${0##*/}

if [[ $# != 7 ]]; then
    echo "Usage: $scriptname <FASTQfile> <adapter_set> <S/I quality> <quality_cutoff> <entropy_cutoff> <length cutoff; 0 for no length cutoff> <# of cores>"
    exit
fi

###
inputfile=$1
adapter_set=$2
quality=$3
quality_cutoff=$4
entropy_cutoff=$5
length_cutoff=$6
cores=$7
###

if [ ! -f $inputfile ]; then
    echo "$inputfile not found!"
    exit
fi

echo -e "$(date)\t$scriptname START"

START=$(date +%s)

echo -e "$(date)\t$scriptname\tSplitting $inputfile..."

numlines=$(wc -l $inputfile | awk '{print $1}')
FASTQentries=$(( numlines / 4 ))
echo -e "$(date)\t$scriptname\tThere are $FASTQentries FASTQ entries in $inputfile"
LinesPerCore=$(( numlines / cores ))
FASTQperCore=$(( LinesPerCore / 4 ))
SplitPerCore=$(( FASTQperCore * 4 ))
echo -e "$(date)\t$scriptname\twill use $cores cores with $FASTQperCore entries per core"

split -l $SplitPerCore $inputfile

END_SPLIT=$(date +%s)
diff_SPLIT=$(( END_SPLIT - START ))

echo -e "$(date)\t$scriptname\tDone splitting: "
echo -e "$(date)\t$scriptname\tSPLITTING took $diff_SPLIT seconds"

echo -e "$(date)\t$scriptname\tRunning preprocess script for each chunk..."

for f in x??
do
    mv $f $f.fastq
    echo -e "$(date)\t$scriptname\tpreprocess.sh $f.fastq $adapter_set $quality $quality_cutoff $entropy_cutoff $length_cutoff 2>&1 | tee $f.preprocess.log &"
    preprocess.sh $f.fastq "$adapter_set" $quality $quality_cutoff $entropy_cutoff $length_cutoff 2>&1 | tee $f.preprocess.log &
done

wait

echo -e "$(date)\t$scriptname\tDone preprocessing for each chunk..."

nopathf2=${1##*/}
basef2=${nopathf2%.fastq}


rm -f $basef2.cutadapt.fastq
rm -f $basef2.preprocessed.fastq

for f in x??.fastq
do
    nopathf=${f##*/}
    basef=${nopathf%.fastq}
#    cat $basef.cutadapt.summary.log >> $basef2.cutadapt.log
#    rm -f $basef.cutadapt.summary.log
    cat $basef.preprocess.log >> $basef2.preprocess.log
    rm -f $basef.preprocess.log

#   cat $basef.cutadapt.fastq >> $basef2.cutadapt.fastq
    rm -f $basef.cutadapt.fastq
    cat $basef.preprocessed.fastq >> $basef2.preprocessed.fastq
    rm -f $basef.preprocessed.fastq

    rm -f $f
done

echo -e "$(date)\t$scriptname\tDone concatenating output..."

echo -e "$(date)\t$scriptname\tIncluding duplicates (did not run UNIQ)"

END=$(date +%s)
diff_TOTAL=$(( END - START ))

let "avgtime1=`grep CUTADAPT $basef2.preprocess.log | awk '{print $12}' | sort -n | awk '{ a[i++]=$1} END {print a[int(i/2)];}'`"
echo -e "$(date)\t$scriptname\tmedian CUTADAPT time per core: $avgtime1 seconds"

let "avgtime2=0"

let "avgtime3=`grep PRINSEQ $basef2.preprocess.log | awk '{print $12}' | sort -n | awk '{ a[i++]=$1} END {print a[int(i/2)];}'`"
echo -e "$(date)\t$scriptname\tmedian PRINSEQ time per core: $avgtime3 seconds"

#rm -f $basef2.preprocess.log

let "totaltime = diff_SPLIT + avgtime1 + avgtime2 + avgtime3"
echo -e "$(date)\t$scriptname\tTOTAL TIME: $totaltime seconds"

echo -e "$(date)\t$scriptname\tTOTAL CLOCK TIME (INCLUDING OVERHEAD): $diff_TOTAL seconds"
echo -e "$(date)\t$scriptname END"
