#!/bin/bash

# INPUT PARAMETERS

	QC_REPORT=$1 # full path to the qc report file that you want to create a sample sheet for
	SAMPLE_SHEET_OUT_DIR=$2 # the full path to the directory that you want the sample sheet to go to
	BUILD=$3

# if 3rd argument is absent ref genome, dbsnp and known indels are for grch37, if present then they will be for grch38


if [[ ! $BUILD ]]
	then
		REF_GENOME="/mnt/research/tools/PIPELINE_FILES/bwa_mem_0.7.5a_ref/human_g1k_v37_decoy.fasta"
		DBSNP="/mnt/research/tools/PIPELINE_FILES/GATK_resource_bundle/2.8/b37/dbsnp_138.b37.vcf"
		KNOWN_INDEL_FILES="/mnt/research/tools/PIPELINE_FILES/GATK_resource_bundle/2.8/b37/1000G_phase1.indels.b37.vcf;/mnt/research/tools/PIPELINE_FILES/GATK_resource_bundle/2.8/b37/Mills_and_1000G_gold_standard.indels.b37.vcf"
	else
		REF_GENOME="/mnt/shared_resources/public_resources/GRCh38DH/GRCh38_full_analysis_set_plus_decoy_hla.fa"
		DBSNP="/mnt/research/tools/PIPELINE_FILES/GRCh38_aux_files/Homo_sapiens_assembly38.dbsnp138.vcf"
		KNOWN_INDEL_FILES="/mnt/research/tools/PIPELINE_FILES/GRCh38_aux_files/Homo_sapiens_assembly38.known_indels.vcf.gz;/mnt/research/tools/PIPELINE_FILES/GRCh38_aux_files/Mills_and_1000G_gold_standard.indels.hg38.vcf.gz"
fi

# STATIC VARIABLES

	SAMTOOLS_DIR="/mnt/linuxtools/ANACONDA/anaconda2-5.0.0.1/bin"
	CORE_PATH="/mnt/research/active"

# OTHER_VARIABLES

	QC_REPORT_NAME=$(basename $QC_REPORT .csv)

	TIMESTAMP=`date '+%F.%H-%M-%S'`

		OUTPUT_SAMPLE_SHEET=$SAMPLE_SHEET_OUT_DIR"/"$QC_REPORT_NAME"_SAMPLE_SHEET_"$TIMESTAMP".csv"

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

# function for creating an arrary per sample containing the project that the sample belongs to using the qc report.

	# grab field number for SM_TAG

		SM_TAG_COLUMN=(`awk 1 $QC_REPORT \
			| sed 's/\r//g; /^$/d' \
			| head -n 1 \
			| sed 's/,/\n/g' \
			| cat -n \
			| sed 's/^ *//g' \
			| awk '$2=="SM_TAG" {print $1}'`)

	# grab field number for PROJECT

		PROJECT_COLUMN=(`awk 1 $QC_REPORT \
				| sed 's/\r//g; /^$/d' \
				| head -n 1 \
				| sed 's/,/\n/g' \
				| cat -n \
				| sed 's/^ *//g' \
				| awk '$2=="PROJECT" {print $1}'`)


	CREATE_SAMPLE_ARRAY ()
	{
		SAMPLE_ARRAY=(`awk 1 $QC_REPORT \
			| sed 's/\r//g; /^$/d' \
			| awk 'BEGIN {FS=","} $1=="'$SM_TAG'" {print $1,$2}' \
			| sort -k1,1 -k 2,2 \
			| uniq`)

				#  1  Project=the Seq Proj folder name
				SM_TAG=${SAMPLE_ARRAY[0]}

				#  2  FCID=flowcell that sample read group was performed on
				PROJECT=${SAMPLE_ARRAY[1]}
	}

# function for grabbing the cram header and creating a sample sheet records per platform unit

	GRAB_CRAM_HEADER_FORMAT ()
	{
		$SAMTOOLS_DIR/samtools view -H \
		$IN_CRAM \
			| grep ^@RG \
			| awk \
				-v PU_TAG="$PU_TAG" \
				-v DT_TAG="$DT_TAG" \
				-v PL_TAG="$PL_TAG" \
				-v LB_TAG="$LB_TAG" \
				-v CN_TAG="$CN_TAG" \
				-v DS_TAG="$DS_TAG" \
				-v PM_TAG="$PM_TAG" \
				'BEGIN {OFS=","} {split($PU_TAG,PU_FIELD,":"); split(PU_FIELD[2],PLATFORM_UNIT,"_"); \
				split($DT_TAG,DT_FIELD,":"); split(DT_FIELD[2],DATE_TIME,"T"); split(DATE_TIME[1],DATE,"-"); \
				split($PL_TAG,PL_FIELD,":"); \
				split($LB_TAG,LB_FIELD,":"); \
				split($CN_TAG,CN_FIELD,":"); \
				split($PM_TAG,PM_FIELD,":"); \
				split($DS_TAG,DS_FIELD,":"); split(DS_FIELD[2],BED_FILE,","); \
				print "'$PROJECT'",\
				PLATFORM_UNIT[1],\
				PLATFORM_UNIT[2],\
				PLATFORM_UNIT[3],\
				PL_FIELD[2],\
				LB_FIELD[2],\
				DATE[2]"/"DATE[3]"/"DATE[1],\
				"'$SM_TAG'",\
				CN_FIELD[2],\
				PM_FIELD[2],\
				"do_not_care",\
				"'$REF_GENOME'",\
				"KNH",\
				"-2",\
				"'$CORE_PATH'" "/" "'$PROJECT'" "/BED_Files/" BED_FILE[3] ".bed",\
				"'$CORE_PATH'" "/" "'$PROJECT'" "/BED_Files/" BED_FILE[1] ".bed",\
				"'$CORE_PATH'" "/" "'$PROJECT'" "/BED_Files/" BED_FILE[2] ".bed",\
				"'$DBSNP'",\
				"'$KNOWN_INDEL_FILES'"}' \
			| sed 's/HiSeq2000/HiSeq-2000/g' \
			| sed 's/HiSeq2500/HiSeq-2500/g' \
			>> $OUTPUT_SAMPLE_SHEET
	}

for SM_TAG in $(awk 'BEGIN {FS=","} NR>1 {print $1}' $QC_REPORT | sort | uniq)
do

	CREATE_SAMPLE_ARRAY

		IN_CRAM=$CORE_PATH/$PROJECT/CRAM/$SM_TAG".cram"

				# grab field number for PLATFORM_UNIT_TAG

					PU_TAG=(`$SAMTOOLS_DIR/samtools view -H \
					$CORE_PATH/$PROJECT/CRAM/$SM_TAG".cram" \
						| grep -m 1 ^@RG \
						| sed 's/\t/\n/g' \
						| cat -n \
						| sed 's/^ *//g' \
						| awk '$2~/^PU:/ {print $1}'`)

				# grab field number for DATE_TAG

					DT_TAG=(`$SAMTOOLS_DIR/samtools view -H \
					$CORE_PATH/$PROJECT/CRAM/$SM_TAG".cram" \
						| grep -m 1 ^@RG \
						| sed 's/\t/\n/g' \
						| cat -n \
						| sed 's/^ *//g' \
						| awk '$2~/^DT:/ {print $1}'`)

				# grab PL field

					PL_TAG=(`$SAMTOOLS_DIR/samtools view -H \
					$CORE_PATH/$PROJECT/CRAM/$SM_TAG".cram" \
						| grep -m 1 ^@RG \
						| sed 's/\t/\n/g' \
						| cat -n \
						| sed 's/^ *//g' \
						| awk '$2~/^PL:/ {print $1}'`)

				# grab LB field

					LB_TAG=(`$SAMTOOLS_DIR/samtools view -H \
					$CORE_PATH/$PROJECT/CRAM/$SM_TAG".cram" \
						| grep -m 1 ^@RG \
						| sed 's/\t/\n/g' \
						| cat -n \
						| sed 's/^ *//g' \
						| awk '$2~/^LB:/ {print $1}'`)

				# grab SM field

					CN_TAG=(`$SAMTOOLS_DIR/samtools view -H \
					$CORE_PATH/$PROJECT/CRAM/$SM_TAG".cram" \
						| grep -m 1 ^@RG \
						| sed 's/\t/\n/g' \
						| cat -n \
						| sed 's/^ *//g' \
						| awk '$2~/^CN:/ {print $1}'`)

				# grab the PM field

					PM_TAG=(`$SAMTOOLS_DIR/samtools view -H \
					$CORE_PATH/$PROJECT/CRAM/$SM_TAG".cram" \
						| grep -m 1 ^@RG \
						| sed 's/\t/\n/g' \
						| cat -n \
						| sed 's/^ *//g' \
						| awk '$2~/^PM:/ {print $1}'`)

				# grab the DS field for the bed files

					DS_TAG=(`$SAMTOOLS_DIR/samtools view -H \
					$CORE_PATH/$PROJECT/CRAM/$SM_TAG".cram" \
						| grep -m 1 ^@RG \
						| sed 's/\t/\n/g' \
						| cat -n \
						| sed 's/^ *//g' \
						| awk '$2~/^DS:/ {print $1}'`)

	GRAB_CRAM_HEADER_FORMAT
done

echo SAMPLE SHEET was written to $OUTPUT_SAMPLE_SHEET
