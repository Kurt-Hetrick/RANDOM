#!/bin/bash

BAM_PATH=$1
PROJECT=$2
TS_TV_BED_FILE=$3
BAIT_BED_FILE=$4
TARGET_BED_FILE=$5

REF_GENOME="/mnt/research/tools/PIPELINE_FILES/bwa_mem_0.7.5a_ref/human_g1k_v37_decoy.fasta"
DBSNP="/mnt/research/tools/PIPELINE_FILES/GATK_resource_bundle/2.8/b37/dbsnp_138.b37.vcf"
KNOWN_INDEL_FILES="/mnt/research/tools/PIPELINE_FILES/GATK_resource_bundle/2.8/b37/1000G_phase1.indels.b37.vcf;/mnt/research/tools/PIPELINE_FILES/GATK_resource_bundle/2.8/b37/Mills_and_1000G_gold_standard.indels.b37.vcf"

module load samtools

sleep 1s

TIMESTAMP=`date '+%F.%H-%M-%S'`

OUTPUT_FILE="/mnt/research/active/"$PROJECT"/"$PROJECT"_SAMPLE_SHEET_"$TIMESTAMP".csv"

# 1: Project
# 2: FCID
# 3: Lane
# 4: Index
# 5: Platform
# 6: Library_Name
# 7: Date
# 8: SM_Tag
# 9: Center
# 10: Description
# 11: Seq_Exp_ID
# 12: Genome_Ref
# 13: Operator
# 14: Extra_VCF_Filter_Params
# 15: TS_TV_BED_File
# 16: Baits_BED_File
# 17: Targets_BED_File
# 18: KNOWN_SITES_VCF
# 19: KNOWN_INDEL_FILES


# ls $BAM_PATH/*bam \
# | awk '{print "samtools view -H",$1,"| grep ^@RG"}' \
# | bash \
# | sed 's/:/\t/g' \
# | awk 'BEGIN {OFS=","} {split($9,PLATFORM_UNIT,"_"); split($5,DATE_TIME,"T"); split(DATE_TIME[1],DATE,"-"); \
# print "'$PROJECT'",\
# PLATFORM_UNIT[1],\
# PLATFORM_UNIT[2],\
# PLATFORM_UNIT[3],\
# $17,\
# $11,\
# DATE[2]"/"DATE[3]"/"DATE[1],\
# $13,\
# $15,\
# $19,\
# "do_not_care",\
# "'$REF_GENOME'",\
# "KNH",\
# "-2",\
# "'$TS_TV_BED_FILE'",\
# "'$BAIT_BED_FILE'",\
# "'$TARGET_BED_FILE'",\
# "'$DBSNP'",\
# "'$KNOWN_INDEL_FILES'"}' \
# | awk 'BEGIN {print "Project,\
# FCID,\
# Lane,\
# Index,\
# Platform,\
# Library_Name,\
# Date,\
# SM_Tag,\
# Center,\
# Description,\
# Seq_Exp_ID,\
# Genome_Ref,\
# Operator,\
# Extra_VCF_Filter_Params,\
# TS_TV_BED_File,\
# Baits_BED_File,\
# Targets_BED_File,\
# KNOWN_SITES_VCF,\
# KNOWN_INDEL_FILES"} \
# {print $0}' \
# | sed 's/HiSeq2000/HiSeq-2000/g' \
# | sed 's/HiSeq2500/HiSeq-2500/g' \
# > $OUTPUT_FILE

# this worked for the bam headers for up to mendel 38...afterwards, the header changed
# the only thing that I can see that changed was the cidrseqsuite version

ls $BAM_PATH/*bam \
| awk '{print "samtools view -H",$1,"| grep ^@RG"}' \
| bash \
| sed 's/:/\t/g' \
| awk 'BEGIN {OFS=","} {split($7,PLATFORM_UNIT,"_"); split($13,DATE_TIME,"T"); split(DATE_TIME[1],DATE,"-"); \
print "'$PROJECT'",\
PLATFORM_UNIT[1],\
PLATFORM_UNIT[2],\
PLATFORM_UNIT[3],\
$5,\
$9,\
DATE[2]"/"DATE[3]"/"DATE[1],\
$17,\
$19,\
$11,\
"do_not_care",\
"'$REF_GENOME'",\
"KNH",\
"-2",\
"'$TS_TV_BED_FILE'",\
"'$BAIT_BED_FILE'",\
"'$TARGET_BED_FILE'",\
"'$DBSNP'",\
"'$KNOWN_INDEL_FILES'"}' \
| awk 'BEGIN {print "Project,\
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
KNOWN_INDEL_FILES"} \
{print $0}' \
| sed 's/HiSeq2000/HiSeq-2000/g' \
| sed 's/HiSeq2500/HiSeq-2500/g' \
> $OUTPUT_FILE
