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

# adapteroptions is a string of cutadapt options (ex. -g GTTCAGAGTTCTACAGTCCGACGATC -a TCGTATGCCGTCTTCTGCTTG) 
if [[ $# != 3 ]]; then
    echo "Usage: cutadapt_quality.csh <FASTQfile> <quality S/I> <adapter_set> <adapteroptions>"
    exit
fi

###
inputfile=$1
quality=$2
adapter_set=$3
adapteroptions=$4
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

if [[ $adapter_set = prepx ]]; then
    # These are Primer B and Primer K
    #           Wafergen Adapter 1
    #           Wafergen Adapter 2
    echo "Trimming Wafergen PrepX adapters + others"
    cutadapt -g GTTTCCCAGTCACGATA    -a TATCGTGACTGGGAAAC \
             -g GACCATCTAGCGACCTCCAC -a GTGGAGGTCGCTAGATGGTC \
             -a AGATCGGAAGAGCACACGTCTGAACTCCAGTCA \
             -a GATCGTCGGACTGTAGAACTCTGAACGTGTAGA \
             "$adapteroptions" \
             -n 15 -O 5 --quality-base=$qual -o "${inputfile%.*}".cutadapt.fastq $inputfile
elif [[ $adapter_set = delwart ]]; then
   echo "Trimming Delwart Ng et al 2012 primers"
   cutadapt -g ATCGTCGTCGTAGGCTGCTC -a GAGCAGCCTACGACGACGAT \
            -g GTATCGCTGGACACTGGACC -a GGTCCAGTGTCCAGCGATAC \
            -g CGCATTGGTCGGCACTTGGT -a ACCAAGTGCCGACCAATGCG \
            -g CGTAGATAAGCGGTCGGCTC -a GAGCCGACCGCTTATCTACG \
            -g CATCACATAGGCGTCCGCTG -a CAGCGGACGCCTATGTGATG \
            -g CGCAGGACCTCTGATACAGG -a CCTGTATCAGAGGTCCTGCG \
            -g CGCACTCGACTCGTAACAGG -a CCTGTTACGAGTCGAGTGCG \
            -g CGTCCAGGCACAATCCAGTC -a GACTGGATTGTGCCTGGACG \
            -g CCGAGGTTCAAGCGAGGTTG -a CAACCTCGCTTGAACCTCGG \
            -g ACGGTGTGTTACCGACGTCC -a GGACGTCGGTAACACACCGT \
            "$adapteroptions" \
            -n 15 -O 5 --quality-base=$qual -o "${inputfile%.*}".cutadapt.fastq $inputfile
elif [[ $adapter_set = primerb ]]; then
    echo Trimming Primer B
    cutadapt -g GTTTCCCAGTCACGATA -a TATCGTGACTGGGAAAC \
             "$adapteroptions" \
             -n 15 -O 5 --quality-base=$qual -o "${inputfile%.*}".cutadapt.fastq $inputfile
else
    # There are 5 sets of non-template sequence:
    #    Primer B
    #    Primer K (pubmed 22855479)
    #    Sol B (same as in Surpi)
    #    Illumina Adapter 1 (-a seq based on Illumina bulletin; using -g revcom similar to Surpi)
    #             Adapter 2 (-a seq based on Illumina bulletin; using -a revcom exactly like Surpi)
    #    Nextera (same as in Surpi)
    echo "Trimming TruSeq + others (default option)"
    cutadapt -g GTTTCCCAGTCACGATA    -a TATCGTGACTGGGAAAC \
             -g GACCATCTAGCGACCTCCAC -a GTGGAGGTCGCTAGATGGTC \
             -g GTTTCCCACTGGAGGATA   -a TATCCTCCAGTGGGAAAC \
             -g TGACTGGAGTTCAGACGTGTGCTCTTCCGATCT                         -a AGATCGGAAGAGCACACGTCTGAACTCCAGTCA \
             -a AATGATACGGCGACCACCGAGATCTACACTCTTTCCCTACACGACGCTCTTCCGATC -a AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGT \
             -a CTGTCTCTTATACACATCTCCGAGCCCACGAGAC -a CTGTCTCTTATACACATCTGACGCTGCCGACGA -a CTGTCTCTTATACACATCT \
             "$adapteroptions" \
             -n 15 -O 5 --quality-base=$qual -o "${inputfile%.*}".cutadapt.fastq $inputfile
fi
