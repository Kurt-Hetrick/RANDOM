# ---qsub parameter settings---
# --these can be overrode at qsub invocation--

# tell sge to execute in bash
#$ -S /bin/bash 

# tell sge to submit any of these queue when available
#$ -q prod.q,rnd.q,c6320.q,lemon.q,c6420.q

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

echo

# INPUT ARGUMENTS

	INFILE=$1 # Input CRAM File
	OUT_DIR=$2 # Output Directory for Fastq Files
	DOWNSAMPLE_FRACTION=$3 # FRACTION THAT YOU WANT TO DOWNSAMPLE TO, 0 TO 1
	REF_GENOME=$4 # Reference genome in fasta format used for creating BAM file. Needs to be indexed with samtools faidx (would have ref.fasta.fai companion file)

		DEFAULT_REF_GENOME=/mnt/research/tools/PIPELINE_FILES/bwa_mem_0.7.5a_ref/human_g1k_v37_decoy.fasta

			if [[ ! $REF_GENOME ]]
				then
				REF_GENOME=$DEFAULT_REF_GENOME
			fi

# STATIC VARIABLES

	module load java/1.8.0_112

	PICARD_DIR="/mnt/linuxtools/PICARD/picard-2.20.6"

# DOWNSAMPLE CRAM FILE, RESORT TO QUERYNAME CONVERT TO FASTQ

java -jar \
$PICARD_DIR/picard.jar \
DownsampleSam \
INPUT=$INFILE \
OUTPUT=/dev/stdout \
PROBABILITY=$DOWNSAMPLE_FRACTION \
REFERENCE_SEQUENCE=$REF_GENOME \
VALIDATION_STRINGENCY=SILENT \
COMPRESSION_LEVEL=0 \
	| java -jar \
		$PICARD_DIR/picard.jar \
		RevertSam \
		INPUT=/dev/stdin \
		OUTPUT=/dev/stdout \
		SORT_ORDER=queryname \
		REFERENCE_SEQUENCE=$REF_GENOME \
		COMPRESSION_LEVEL=0 \
		VALIDATION_STRINGENCY=SILENT \
	| java -jar \
		$PICARD_DIR/picard.jar \
		SamToFastq \
		INPUT=/dev/stdin \
		REFERENCE_SEQUENCE=$REF_GENOME \
		OUTPUT_PER_RG=true \
		OUTPUT_DIR=$OUT_DIR \
		VALIDATION_STRINGENCY=SILENT
