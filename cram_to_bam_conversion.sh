# ---qsub parameter settings---
# --these can be overrode at qsub invocation--

# tell sge to execute in bash
#$ -S /bin/bash

# tell sge to submit any of these queue when available
#$ -q rnd.q,prod.q,c6420_21.q,lemon.q,c6320.q,c6420_23.q

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

# INPUT VARIABLES

	SAMTOOLS_DIR="/mnt/linuxtools/ANACONDA/anaconda2-5.0.0.1/bin"

	IN_CRAM=$1 # Input CRAM File
	BAM_DIR=$2 # Output BAM File Path
	REF_GENOME=$3 # Optional arugment.
		# Reference genome used for creating BAM file.
		# Needs to be indexed with samtools faidx (would have ref.fasta.fai companion file)
		# if not supplied, defaulted to grch37, 1kg phase 2 ref.

	DEFAULT_REF_GENOME=/mnt/research/tools/PIPELINE_FILES/bwa_mem_0.7.5a_ref/human_g1k_v37_decoy.fasta

		if [[ ! $REF_GENOME ]]
			then
			REF_GENOME=$DEFAULT_REF_GENOME
		fi

	SM_TAG=$(basename $IN_CRAM .cram)

# make output directory if it does not already exist.

	mkdir -p $BAM_DIR

# Using samtools-1.3 or later to convert a cram file to a bam file with the same file name with the .bam extension
# For further information: http://www.htslib.org/doc/samtools.html

	$SAMTOOLS_DIR/samtools \
	view \
	-b $IN_CRAM \
	-o $BAM_DIR/$SM_TAG".bam" \
	-T $REF_GENOME

# Using samtools-1.3 or later to create an index file for the recently created bam file with the extension .bai

	$SAMTOOLS_DIR/samtools \
	index \
	$BAM_DIR/$SM_TAG".bam"

	cp $BAM_DIR/$SM_TAG".bam.bai" \
	$BAM_DIR/$SM_TAG".bai"
