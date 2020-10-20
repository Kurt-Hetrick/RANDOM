#!/bin/bash

# INPUT VARIABLES

	INPUT_DIR=$1 # locations where bam/cram files are located at.

# programs

	SAMTOOLS_DIR="/mnt/linuxtools/ANACONDA/anaconda2-5.0.0.1/bin"

# function for grabbing the cram header and creating a sample sheet records per platform unit

	GRAB_BAM_HEADER_FORMAT ()
	{
		$SAMTOOLS_DIR/samtools view -H \
		$BAM_FILE \
			| grep ^@RG \
			| awk \
				-v PU_TAG="$PU_TAG" \
				-v LB_TAG="$LB_TAG" \
				-v DT_TAG="$DT_TAG" \
				-v SM_TAG="$SM_TAG" \
				-v CN_TAG="$CN_TAG" \
				'BEGIN {OFS="\t"} \
				{split($PU_TAG,PU_FIELD,":"); \
				split($LB_TAG,LB_FIELD,":"); \
				split($DT_TAG,DT_FIELD,":"); split(DT_FIELD[2],DATE_TIME,"T"); split(DATE_TIME[1],DATE,"-"); \
				split($SM_TAG,SM_FIELD,":"); \
				split($CN_TAG,CN_FIELD,":"); \
				print PU_FIELD[2],\
				LB_FIELD[2],\
				DATE[2]"/"DATE[3]"/"DATE[1],\
				SM_FIELD[2],\
				CN_FIELD[2]}'
	}

for BAM_FILE in $( find $INPUT_DIR -type f \( -name \*.bam -o -name \*.cram \) )
	do
		# grab field number for PLATFORM_UNIT_TAG

			PU_TAG=(`$SAMTOOLS_DIR/samtools view -H \
			$BAM_FILE \
				| grep -m 1 ^@RG \
				| sed 's/\t/\n/g' \
				| cat -n \
				| sed 's/^ *//g' \
				| awk '$2~/^PU:/ {print $1}'`)

		# grab LB field

			LB_TAG=(`$SAMTOOLS_DIR/samtools view -H \
			$BAM_FILE \
				| grep -m 1 ^@RG \
				| sed 's/\t/\n/g' \
				| cat -n \
				| sed 's/^ *//g' \
				| awk '$2~/^LB:/ {print $1}'`)

		# grab field number for DATE_TAG

			DT_TAG=(`$SAMTOOLS_DIR/samtools view -H \
			$BAM_FILE \
				| grep -m 1 ^@RG \
				| sed 's/\t/\n/g' \
				| cat -n \
				| sed 's/^ *//g' \
				| awk '$2~/^DT:/ {print $1}'`)

		# grab field number for SM_TAG

			SM_TAG=(`$SAMTOOLS_DIR/samtools view -H \
			$BAM_FILE \
				| grep -m 1 ^@RG \
				| sed 's/\t/\n/g' \
				| cat -n \
				| sed 's/^ *//g' \
				| awk '$2~/^SM:/ {print $1}'`)

		# grab CN field

			CN_TAG=(`$SAMTOOLS_DIR/samtools view -H \
			$BAM_FILE \
				| grep -m 1 ^@RG \
				| sed 's/\t/\n/g' \
				| cat -n \
				| sed 's/^ *//g' \
				| awk '$2~/^CN:/ {print $1}'`)

		GRAB_BAM_HEADER_FORMAT
done
