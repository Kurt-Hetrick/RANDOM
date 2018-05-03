# ---qsub parameter settings---
# --these can be overrode at qsub invocation--

# tell sge to execute in bash
#$ -S /bin/bash 

# tell sge to submit any of these queue when available
#$ -q bigdata.q,prod.q,rnd.q

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

module load java/1.7.0_80

PICARD_DIR="/mnt/research/tools/LINUX/PICARD/picard-tools-1.141"

set

INFILE=$1 # Input CRAM File
OUT_DIR=$2 # Output Directory for Fastq Files
REF_GENOME=$3 # Reference genome in fasta format used for creating BAM file. Needs to be indexed with samtools faidx (would have ref.fasta.fai companion file)

DEFAULT_REF_GENOME=/mnt/research/tools/PIPELINE_FILES/bwa_mem_0.7.5a_ref/human_g1k_v37_decoy.fasta

if [[ ! $REF_GENOME ]]
	then
	REF_GENOME=$DEFAULT_REF_GENOME
fi

# See for further explanation: http://broadinstitute.github.io/picard/command-line-overview.html#SamToFastq

#Can use picard versions 1.141 or later

#If using picard 2+ java 8 is required.  Older versions work with java 7

# Using picard-1.141 or later SamToFastq to convert the CRAM file designated by the first parameter (IN_CRAM) to it's FASTQ parts broken out per read group into the specified directory (OUT_DIR) without the need to convert to an intermediate BAM file

# OUTPUT_PER_RG writes a pair of fastq files per lane and named based on the Platform Unit found in the header of the BAM file
# Because you couldn't populate platform unit with bina have to set the RG_TAG to ID

# RG_TAG=ID \

java -jar $PICARD_DIR/picard.jar \
RevertSam \
INPUT=$INFILE \
OUTPUT=/dev/stdout \
SORT_ORDER=queryname \
REFERENCE_SEQUENCE=$REF_GENOME \
COMPRESSION_LEVEL=0 \
VALIDATION_STRINGENCY=SILENT \
| java -jar $PICARD_DIR/picard.jar \
SamToFastq \
INPUT=/dev/stdin \
REFERENCE_SEQUENCE=$REF_GENOME \
OUTPUT_PER_RG=true \
OUTPUT_DIR=$OUT_DIR \
VALIDATION_STRINGENCY=SILENT
