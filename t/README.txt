temp.1K.fastq - 1000 raw reads from FC_02516 A4 sample. A4 sample (aedes
aegypti) is 150bp single end RNAseq done at Harvard Biopolymers using
Wafergen PrepX library kit (strand specific). The sequences were NOT adapter
trimmed by Harvard.


examples:
preprocess_ncores.sh temp.1K.fastq prepx S 15 60 30 2
preprocess_ncores.sh temp.1K.fastq primerb S 15 60 30 2
preprocess_ncores.sh temp.1K.fastq "" S 15 60 30 2   # or can replace "" with "none"
preprocess_ncores.sh temp.1K.fastq truseq S 15 60 30 2
