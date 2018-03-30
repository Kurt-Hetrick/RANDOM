# ---qsub parameter settings---
# --these can be overrode at qsub invocation--

# tell sge to execute in bash
#$ -S /bin/bash

# tell sge to submit any of these queue when available
#$ -q rnd.q,prod.q,bigdata.q

# tell sge that you are in the users current working directory
#$ -cwd

# tell sge to export the users environment variables
#$ -V

# tell sge to submit at this priority setting
#$ -p -1022

# tell sge to output both stderr and stdout to the same file
#$ -j y

# export all variables, useful to find out what compute node the program was executed on
# redirecting stderr/stdout to file as a log.

set

SAMTOOLS_DIR="/mnt/research/tools/LINUX/SAMTOOLS/samtools-1.6"

IN_CRAM=$1 # Input CRAM File
BAM_DIR=$2 # Output BAM File Path
REF_GENOME=$3 # Reference genome used for creating BAM file. Needs to be indexed with samtools faidx (would have ref.fasta.fai companion file)

DEFAULT_REF_GENOME=/mnt/research/tools/PIPELINE_FILES/bwa_mem_0.7.5a_ref/human_g1k_v37_decoy.fasta

if [[ ! $REF_GENOME ]]
	then
	REF_GENOME=$DEFAULT_REF_GENOME
fi

SM_TAG=$(basename $IN_CRAM .cram)

# For further information: http://www.htslib.org/doc/samtools.html

# Using samtools-1.3 or later to convert a bam file to a cram file with the same file name with the .cram extension

$SAMTOOLS_DIR/samtools \
view -b \
$IN_CRAM \
-o $BAM_DIR/$SM_TAG".bam" \
-T $REF_GENOME

# Using samtools-1.3 or later to create an index file for the recently created cram file with the extension .crai

$SAMTOOLS_DIR/samtools \
index \
$BAM_DIR/$SM_TAG".bam"

cp $BAM_DIR/$SM_TAG".bam.bai" \
$BAM_DIR/$SM_TAG".bai"
