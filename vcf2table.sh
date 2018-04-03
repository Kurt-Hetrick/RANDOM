#!/bin/bash

# Example script for converting VCF to tab delimited table

JAVA_1_8="/isilon/sequencing/Kurt/Programs/Java/jdk1.8.0_73/bin"
GATK_DIR="/isilon/sequencing/CIDRSeqSuiteSoftware/gatk/GATK_3/GenomeAnalysisTK-3.7"
REF_GENOME="/isilon/sequencing/GATK_resource_bundle/bwa_mem_0.7.5a_ref/human_g1k_v37_decoy.fasta"

INPUT_VCF=$1
OUTPUT_TABLE=$2

$JAVA_1_8/java -jar $GATK_DIR/GenomeAnalysisTK.jar \
-T VariantsToTable \
--disable_auto_index_creation_and_locking_when_reading_rods \
-R $REF_GENOME \
--variant $INPUT_VCF \
--fields CHROM \
--fields POS \
--fields ID \
--fields REF \
--fields ALT \
--fields QUAL \
--fields EVENTLENGTH \
--fields FILTER \
--fields AC \
--fields AC_Orig \
--fields AN \
--fields AN_Orig \
--fields AF \
--fields AF_Orig \
--fields ABHet \
--fields ABHom \
--fields OND \
--fields HOM-REF \
--fields HET \
--fields HOM-VAR \
--fields NO-CALL \
--fields NSAMPLES \
--fields GQ_MEAN \
--fields GQ_STDDEV \
--fields NDA \
--fields Samples \
--fields DP \
--fields DP_Orig \
--fields QD \
--fields FS \
--fields SOR \
--fields MQ \
--fields MQRankSum \
--fields ReadPosRankSum \
--fields culprit \
--fields VQSLOD \
--fields POSITIVE_TRAIN_SITE \
--fields NEGATIVE_TRAIN_SITE \
--fields GC \
--fields FractionInformativeReads \
--fields HRun \
--fields RPA \
--fields RU \
--fields STR \
--fields MVLR \
--fields ClippingRankSum \
--genotypeFields AD \
--genotypeFields DP \
--genotypeFields GQ \
--genotypeFields GT \
--genotypeFields PGT \
--genotypeFields PID \
--genotypeFields PL \
--genotypeFields RGQ \
--genotypeFields SAC \
--allowMissingData \
--showFiltered \
-o $OUTPUT_TABLE
