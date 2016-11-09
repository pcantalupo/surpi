#!/bin/bash
#
# 	cutadapt_quality.sh
#
#	runs cutadapt to remove primer sequences from Illumina files
#	also accepts a quality argument for Illumina / Sanger quality 
#	user specifies length cutoff
#	user specifies whether short reads less than length cutoff are kept; if so, they are converted to size=1
#
#	Chiu Laboratory
#	University of California, San Francisco
#	January, 2014
#
# *** modified by Scot Federman, 2013 ***
#     -- Added TEMPDIR var for portability to AWS
#     -- TEMPDIR specifies a directory that can be used for temp storage during the life of this program execution
#     -- AWS typically has boot volumes of only 8GB, which is too small for the data created.
#
# Copyright (C) 2014 Charles Chiu - All Rights Reserved
# SURPI has been released under a modified BSD license.
# Please see license file for details.

if [[ $# != 3 ]]; then
    echo "Usage: cutadapt_quality.csh <FASTQfile> <quality S/I> <adapter_set>"
    exit
fi

###
inputfile=$1
quality=$2
adapter_set=$3
###

#set numreads_start = `egrep -c "@HWI|@M00|@SRR" $inputfile`
#echo $numreads_start" reads at beginning of cutadapt"

if [[ $quality = S ]]; then
    echo "Quality is Sanger"
    qual=33
else
    echo "Quality is Illumina"
    qual=64
fi

if [[ $adapter_set = truseq ]]; then
    cutadapt -g GTTTCCCACTGGAGGATA -a TATCCTCCAGTGGGAAAC \
             -a AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGTAGATCTCGGTGGTCGCCGTATCATT -g GTGACTGGAGTTCAGACGTGTGCTCTTCCGATC \
             -a GATCGGAAGAGCACACGTCTGAACTCCAGTCAC -a AATGATACGGCGACCACCGAGATCTACACTCTTTCCCTACACGACGCTCTTCCGATC \
             -n 15 -O 5 --quality-base=$qual -o "${inputfile%.*}$$".fastq \
             --info-file=${inputfile%.*}.adapterinfo.log $inputfile > ${inputfile%.*}.cutadapt.summary.log
else
    echo "No adapter set selected!!!!!"
fi

#set numreads_end = `egrep -c "@HWI|@M00|@SRR" $inputfile:r.cutadapt.fastq`

#@ reads_removed = $numreads_start - $numreads_end
#echo $reads_removed" reads removed by cutadapt" 
#echo $numreads_end" reads at end of cutadapt"
