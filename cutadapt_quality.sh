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
    # These are
    #    Primer B
    #    Illumina Adapter 1 (-a seq based on Illumina bulletin; using -g revcom similar to Surpi)
    #             Adapter 2 (-a seq based on Illumina bulletin; using -a revcom exactly like Surpi)
    echo Trimming Primer B + Illumina TruSeq adapters
    cutadapt -g GTTTCCCAGTCACGATA -a TATCGTGACTGGGAAAC \
             -g TGACTGGAGTTCAGACGTGTGCTCTTCCGATCT                         -a AGATCGGAAGAGCACACGTCTGAACTCCAGTCA \
             -a AATGATACGGCGACCACCGAGATCTACACTCTTTCCCTACACGACGCTCTTCCGATC -a AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGT \
             -n 15 -O 5 --quality-base=$qual -o "${inputfile%.*}".cutadapt.fastq $inputfile
elif [[ $adapter_set = prepx ]]; then
    # These are Primer B
    #           Wafergen Adapter 1
    #           Wafergen Adapter 2
    echo Trimming Primer B + Wafergen PrepX adapters
    cutadapt -g GTTTCCCAGTCACGATA -a TATCGTGACTGGGAAAC \
             -a AGATCGGAAGAGCACACGTCTGAACTCCAGTCA \
             -a GATCGTCGGACTGTAGAACTCTGAACGTGTAGA \
             -n 15 -O 5 --quality-base=$qual -o "${inputfile%.*}".cutadapt.fastq $inputfile
else
    echo "No adapter set selected!!!!!"
fi
