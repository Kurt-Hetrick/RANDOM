#!/bin/bash

# INPUT PARAMETERS

	QC_REPORT=$1
	IN_PROJECT=$2
	TS_TV_BED_FILE=$3
	BAIT_BED_FILE=$4
	TARGET_BED_FILE=$5

# STATIC VARIABLES

	REF_GENOME="/mnt/research/tools/PIPELINE_FILES/bwa_mem_0.7.5a_ref/human_g1k_v37_decoy.fasta"
	DBSNP="/mnt/research/tools/PIPELINE_FILES/GATK_resource_bundle/2.8/b37/dbsnp_138.b37.vcf"
	KNOWN_INDEL_FILES="/mnt/research/tools/PIPELINE_FILES/GATK_resource_bundle/2.8/b37/1000G_phase1.indels.b37.vcf;/mnt/research/tools/PIPELINE_FILES/GATK_resource_bundle/2.8/b37/Mills_and_1000G_gold_standard.indels.b37.vcf"
	SAMTOOLS_DIR="/isilon/sequencing/Kurt/Programs/PYTHON/Anaconda2-5.0.0.1/bin/"
	CORE_PATH="/mnt/research/active"

# OTHER_VARIABLES

	QC_REPORT_NAME=$(basename $QC_REPORT .csv)

	TIMESTAMP=`date '+%F.%H-%M-%S'`

		OUTPUT_SAMPLE_SHEET=$CORE_PATH"/"$IN_PROJECT"/"$QC_REPORT_NAME"_SAMPLE_SHEET_"$TIMESTAMP".csv"

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
>| $CORE_PATH/$IN_PROJECT/$QC_REPORT_NAME"_SAMPLE_SHEET_"$TIMESTAMP".csv"

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

GRAB_CRAM_HEADER_FORMAT ()
{
	$SAMTOOLS_DIR/samtools view -H \
	$IN_CRAM \
		| grep ^@RG \
		| sed 's/:/\t/g' \
		| awk 'BEGIN {OFS=","} {split($17,PLATFORM_UNIT,"_"); split($7,DATE_TIME,"T"); split(DATE_TIME[1],DATE,"-"); \
			print "'$PROJECT'",\
			PLATFORM_UNIT[1],\
			PLATFORM_UNIT[2],\
			PLATFORM_UNIT[3],\
			$15,\
			$11,\
			DATE[2]"/"DATE[3]"/"DATE[1],\
			$19,\
			$5,\
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

for SM_TAG in $(awk 'BEGIN {FS=","} NR>1 {print $1}' $QC_REPORT | sort | uniq)
do

	CREATE_SAMPLE_ARRAY

		IN_CRAM=$CORE_PATH/$PROJECT/CRAM/$SM_TAG".cram"

	GRAB_CRAM_HEADER_FORMAT
done
