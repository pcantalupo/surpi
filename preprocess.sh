#!/bin/bash
#
#	preprocess.sh
#
#	This script preprocesses a FASTQ-formatted file
#	Chiu Laboratory
#	University of California, San Francisco
#	January, 2014
#
# cutadapt -> prinseq
#                                                                                                                                
# 12/20/12 - modified to switch to cutadapt for trimming
# 12/31/12 - modified from Cshell to BASH version for timing
#
# Copyright (C) 2014 Charles Chiu - All Rights Reserved
# SURPI has been released under a modified BSD license.
# Please see license file for details.

scriptname=${0##*/}

if [ $# != 8 ]; then
    echo "Usage: $scriptname <FASTQfile> <adapter_set> <S/I quality> <quality_cutoff> <entropy_cutoff> <length_cutoff; 0 for no length_cutoff> <trimleft> <trimright>"
    exit
fi

###
inputfile=$1
adapter_set=$2
quality=$3
quality_cutoff=$4
entropy_cutoff=$5
length_cutoff=$6
trim_left=${7:-0}  # default 0 
trim_right=${8:-0} # default 0
###

if [[ ! -f $inputfile ]]; then
    echo "$inputfile not found!"
    exit
fi

echo -e "$(date)\t$scriptname START"

if [[ $quality = S ]]; then
    echo -e "$(date)\t$scriptname\tselected Sanger quality"
else
    echo -e "$(date)\t$scriptname\tselected Illumina quality"
fi

nopathf=${1##*/}
basef=${nopathf%.fastq}

#################### START OF PREPROCESSING #########################

# run cutadapt, Read1
echo -e "$(date)\t$scriptname\t********** running cutadapt **********"
START1=$(date +%s)

cutadapt_quality.sh "$inputfile" "$quality" "$adapter_set"

END1=$(date +%s)
diff=$(( END1 - START1 ))
echo -e "$(date)\t$scriptname\tDone cutadapt: CUTADAPT took $diff seconds"



# run prinseq, Read1
echo -e "$(date)\t$scriptname\t********** running prinseq **********"
START1=$(date +%s)

# $quality = S or I
# $length_cutoff = 30
# $quality_cutoff = 15  (for average quality cutoff and for trimming ends)
# $entropy_cutoff = 60

prinseq-lite.pl -fastq "$basef".cutadapt.fastq \
                -lc_method entropy -lc_threshold "$entropy_cutoff" \
                -min_qual_mean "$quality_cutoff" -ns_max_p 5 \
                -trim_qual_right "$quality_cutoff" -trim_qual_left "$quality_cutoff" \
                -trim_left "$trim_left" -trim_right "$trim_right" \
                -min_len "$length_cutoff" -no_qual_header \
                -out_good "$basef".cutadapt.prinseq -out_bad null
mv -f "$basef".cutadapt.prinseq.fastq "$basef".preprocessed.fastq

END1=$(date +%s)
diff=$(( END1 - START1 ))
echo -e "$(date)\t$scriptname\tDone prinseq: PRINSEQ took $diff seconds"
echo -e "$(date)\t$scriptname END"
