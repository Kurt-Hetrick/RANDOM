# ---qsub parameter settings---
# --these can be overrode at qsub invocation--

# tell sge to execute in bash
#$ -S /bin/bash 

# tell sge to submit any of these queue when available
#$ -q prod.q,rnd.q,c6420.q

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

	INPUT_FILE=$1 # INPUT CRAM FILE
		ORIGINAL_SM_TAG=$(basename $INPUT_FILE .cram)
		NEW_SM_TAG=$(basename $INPUT_FILE .cram | sed 's/@/-/g')
	OUTPUT_DIR=$2 # DIRECTORY WHERE YOU WANT THE OUTPUT TO GO TO
		## **!! DO NOT CHOSE THE SAME DIRECTORY AS THE INPUT FILE

# turn on noclobber so that you don't accidentally overwrite existing files.

	set -o noclobber

# programs

	SAMTOOLS_DIR="/mnt/linuxtools/ANACONDA/anaconda2-5.0.0.1/bin"

# function for grabbing the cram header and creating a sample sheet records per platform unit

	MAKE_NEW_CRAM_HEADER ()
	{
		$SAMTOOLS_DIR/samtools view -H \
			$INPUT_FILE \
			| sed "s/$ORIGINAL_SM_TAG/$NEW_SM_TAG/g" \
		>| $OUTPUT_DIR/$NEW_SM_TAG".header.sam"
	}

	REHEADER_CRAM_FILE ()
	{
		$SAMTOOLS_DIR/samtools reheader \
			$OUTPUT_DIR/$NEW_SM_TAG".header.sam" \
			$INPUT_FILE \
		>| $OUTPUT_DIR/$NEW_SM_TAG".cram"
	}

	INDEX_NEW_CRAM_FILE ()
	{
		$SAMTOOLS_DIR/samtools index \
		$OUTPUT_DIR/$NEW_SM_TAG".cram"
	}

	MD5_NEW_CRAM_FILE ()
	{
		md5sum $OUTPUT_DIR/$NEW_SM_TAG".cram" $OUTPUT_DIR/$NEW_SM_TAG".cram.crai" \
		>| $OUTPUT_DIR/$NEW_SM_TAG".cram.md5"
	}

MAKE_NEW_CRAM_HEADER
REHEADER_CRAM_FILE
INDEX_NEW_CRAM_FILE 
MD5_NEW_CRAM_FILE
