#!/bin/bash

set

echo

JAVA_1_8="/mnt/research/tools/LINUX/JAVA/jdk1.8.0_73/bin"
GATK_DIR="/mnt/research/tools/LINUX/GATK/GenomeAnalysisTK-3.7"
REF_GENOME="/mnt/research/tools/PIPELINE_FILES/bwa_mem_0.7.5a_ref/human_g1k_v37_decoy.fasta"

SAMPLE_LIST=$1 #file should have a .list extension
IN_VCF=$2
OUT_VCF=$3

OUT_DIR=$(dirname $IN_VCF)

# Extract out sample

$JAVA_1_8/java -jar \
$GATK_DIR/GenomeAnalysisTK.jar \
-T SelectVariants \
-R $REF_GENOME \
-sn $SAMPLE_LIST \
--keepOriginalAC \
--variant $IN_VCF \
-o $OUT_DIR/OUT_VCF".vcf.gz"
