#!/bin/bash

# INPUT VARIABLES

	INPUT_BAM_LIST=$1 # one file per row with full path to bam file.
	PROJECT=$2 # project where you want the sample sheet to go to.
	TS_TV_BED_FILE=$3
	BAIT_BED_FILE=$4
	TARGET_BED_FILE=$5

# STATIC VARIABLES

	REF_GENOME="/mnt/research/tools/PIPELINE_FILES/bwa_mem_0.7.5a_ref/human_g1k_v37_decoy.fasta"
	DBSNP="/mnt/research/tools/PIPELINE_FILES/GATK_resource_bundle/2.8/b37/dbsnp_138.b37.vcf"
	KNOWN_INDEL_FILES="/mnt/research/tools/PIPELINE_FILES/GATK_resource_bundle/2.8/b37/1000G_phase1.indels.b37.vcf;/mnt/research/tools/PIPELINE_FILES/GATK_resource_bundle/2.8/b37/Mills_and_1000G_gold_standard.indels.b37.vcf"
	CORE_PATH="/mnt/research/active"

# OTHER VARIABLS

	# module load samtools

		SAMTOOLS_DIR="/isilon/sequencing/Kurt/Programs/PYTHON/Anaconda2-5.0.0.1/bin"

	sleep 1s

	TIMESTAMP=`date '+%F.%H-%M-%S'`

	OUTPUT_SAMPLE_SHEET=$(echo $CORE_PATH/$PROJECT/$PROJECT"_SAMPLE_SHEET_"$TIMESTAMP".csv")

# create a file with the header

echo \
Project,\
FCID,\
Lane,\
Index,\
Platform,\
Library_Name,\
Date,\
SM_Tag,\
Center,\
Description,\
Seq_Exp_ID,\
Genome_Ref,\
Operator,\
Extra_VCF_Filter_Params,\
TS_TV_BED_File,\
Baits_BED_File,\
Targets_BED_File,\
KNOWN_SITES_VCF,\
KNOWN_INDEL_FILES\
>| $OUTPUT_SAMPLE_SHEET

# function for grabbing the cram header and creating a sample sheet records per platform unit

	GRAB_BAM_HEADER_FORMAT ()
	{
		$SAMTOOLS_DIR/samtools view -H \
		$BAM_FILE \
			| grep ^@RG \
			| awk \
				-v PU_TAG="$PU_TAG" \
				-v DT_TAG="$DT_TAG" \
				-v PL_TAG="$PL_TAG" \
				-v LB_TAG="$LB_TAG" \
				-v CN_TAG="$CN_TAG" \
				'BEGIN {OFS=","} {split($PU_TAG,PU_FIELD,":"); split(PU_FIELD[2],PLATFORM_UNIT,"_"); \
				split($DT_TAG,DT_FIELD,":"); split(DT_FIELD[2],DATE_TIME,"T"); split(DATE_TIME[1],DATE,"-"); \
				split($PL_TAG,PL_FIELD,":"); \
				split($LB_TAG,LB_FIELD,":"); \
				split($CN_TAG,CN_FIELD,":"); \
				print "'$PROJECT'",\
				PLATFORM_UNIT[1],\
				PLATFORM_UNIT[2],\
				PLATFORM_UNIT[3],\
				PL_FIELD[2],\
				LB_FIELD[2],\
				DATE[2]"/"DATE[3]"/"DATE[1],\
				"'$SM_TAG'",\
				CN_FIELD[2],\
				"HiSeq-2500_HighOutput",\
				"do_not_care",\
				"'$REF_GENOME'",\
				"KNH",\
				"-2",\
				"'$TS_TV_BED_FILE'",\
				"'$BAIT_BED_FILE'",\
				"'$TARGET_BED_FILE'",\
				"'$DBSNP'",\
				"'$KNOWN_INDEL_FILES'"}' \
			| sed 's/HiSeq2000/HiSeq-2000/g' \
			| sed 's/HiSeq2500/HiSeq-2500/g' \
			>> $OUTPUT_SAMPLE_SHEET
	}

for BAM_FILE in $(cat $INPUT_BAM_LIST)
do

		SM_TAG=$(basename $BAM_FILE .bam | sed 's/.cram//g')

				# grab field number for PLATFORM_UNIT_TAG

					PU_TAG=(`$SAMTOOLS_DIR/samtools view -H \
					$BAM_FILE \
						| grep -m 1 ^@RG \
						| sed 's/\t/\n/g' \
						| cat -n \
						| sed 's/^ *//g' \
						| awk '$2~/^PU:/ {print $1}'`)

				# grab field number for DATE_TAG

					DT_TAG=(`$SAMTOOLS_DIR/samtools view -H \
					$BAM_FILE \
						| grep -m 1 ^@RG \
						| sed 's/\t/\n/g' \
						| cat -n \
						| sed 's/^ *//g' \
						| awk '$2~/^DT:/ {print $1}'`)

				# grab PL field

					PL_TAG=(`$SAMTOOLS_DIR/samtools view -H \
					$BAM_FILE \
						| grep -m 1 ^@RG \
						| sed 's/\t/\n/g' \
						| cat -n \
						| sed 's/^ *//g' \
						| awk '$2~/^PL:/ {print $1}'`)

				# grab LB field

					LB_TAG=(`$SAMTOOLS_DIR/samtools view -H \
					$BAM_FILE \
						| grep -m 1 ^@RG \
						| sed 's/\t/\n/g' \
						| cat -n \
						| sed 's/^ *//g' \
						| awk '$2~/^LB:/ {print $1}'`)

				# grab SM field

					CN_TAG=(`$SAMTOOLS_DIR/samtools view -H \
					$BAM_FILE \
						| grep -m 1 ^@RG \
						| sed 's/\t/\n/g' \
						| cat -n \
						| sed 's/^ *//g' \
						| awk '$2~/^CN:/ {print $1}'`)

				# grab the PM field
				# in our old pipeline, the DS tag was populated with the platform model

					PM_TAG=(`$SAMTOOLS_DIR/samtools view -H \
					$BAM_FILE \
						| grep -m 1 ^@RG \
						| sed 's/\t/\n/g' \
						| cat -n \
						| sed 's/^ *//g' \
						| awk '$2~/^DS:/ {print $1}'`)

				# in our old bam files, the DS tag was used to populate the platfrom model
				# # grab the DS field for the bed files.

				# 	DS_TAG=(`$SAMTOOLS_DIR/samtools view -H \
				# 	$CORE_PATH/$PROJECT/CRAM/$SM_TAG".cram" \
				# 		| grep -m 1 ^@RG \
				# 		| sed 's/\t/\n/g' \
				# 		| cat -n \
				# 		| sed 's/^ *//g' \
				# 		| awk '$2~/^DS:/ {print $1}'`)


	GRAB_BAM_HEADER_FORMAT
done

echo SAMPLE SHEET was written to $OUTPUT_SAMPLE_SHEET
