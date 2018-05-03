#!/bin/bash

CORE_PATH="/isilon/sequencing/Seq_Proj/"
GATK_DIR="/isilon/sequencing/CIDRSeqSuiteSoftware/gatk/GATK_3/GenomeAnalysisTK-3.3-0"
REF_GENOME="/isilon/sequencing/GATK_resource_bundle/1.5/b37/human_g1k_v37_decoy.fasta"
DBSNP="/isilon/sequencing/GATK_resource_bundle/2.8/b37/dbsnp_138.b37.vcf"
JAVA_1_7="/isilon/sequencing/Kurt/Programs/Java/jdk1.7.0_25/bin"

SM_TAG=$1 # SAMPLE NAME
PROJECT=$2 # PROJECT FOLDER
IN_BED=$3 # SOME BED FILE WITH THE PLACES THAT YOU WANT TO LOOK AT...IF NOT PADDED, PAD BEFOREHAND

mkdir -p $CORE_PATH/Amos_LungCa_SeqWholeExomePlus_040413_1/Post_Release_Calls/HC_BAM

## GATK bamout article link: https:/www.broadinstitute.org/gatk/guide/tagged?tag=bamout

## Create a bed file for the HC calls with a 250bp pad from the leftmost coordinate...using the VQSR PASS polymorphic calls per individual sample.
## This is what I would normally pipeline.

# grep -v "^#" $CORE_PATH/$PROJECT/VCF/RELEASE/FILTERED_ON_BAIT/$SM_TAG"_MS_OnBait.vcf" \
# | awk 'BEGIN {OFS="\t"} {print $1,$2-250,$2+250}' \
# >| $IN_BED

## Use the above bed file to write a HC bam file for variants only using same parameters used to generate GVCF

$JAVA_1_7/java -jar $GATK_DIR/GenomeAnalysisTK.jar \
-T HaplotypeCaller \
-R $REF_GENOME \
--input_file $CORE_PATH/$PROJECT/Release_Data/rawdataset_to_PI_NCBI/BAM/$SM_TAG".bam" \
--dbsnp $DBSNP \
-L $IN_BED \
--emitRefConfidence GVCF \
--variant_index_type LINEAR \
--variant_index_parameter 128000 \
-pairHMM VECTOR_LOGLESS_CACHING \
--max_alternate_alleles 3 \
--bamOutput $CORE_PATH/$PROJECT/HC_BAM/$SM_TAG".HC.VariantOnly.bam" \
-o $CORE_PATH/$PROJECT/HC_BAM/$SM_TAG".HC.VariantOnly.vcf"

bgzip-0.2.6 -c $CORE_PATH/$PROJECT/HC_BAM/$SM_TAG".HC.VariantOnly.vcf" \
>| $CORE_PATH/$PROJECT/HC_BAM/$SM_TAG".HC.VariantOnly.vcf.gz"

tabix-0.2.6 -f -p vcf $CORE_PATH/$PROJECT/HC_BAM/$SM_TAG".HC.VariantOnly.vcf.gz"

## Use the above bed file to write a HC bam file for variants and reference using same parameters used to generate GVCF

$JAVA_1_7/java -jar $GATK_DIR/GenomeAnalysisTK.jar \
-T HaplotypeCaller \
-R $REF_GENOME \
--input_file $CORE_PATH/$PROJECT/Release_Data/rawdataset_to_PI_NCBI/BAM/$SM_TAG".bam" \
--dbsnp $DBSNP \
-L $IN_BED \
--emitRefConfidence GVCF \
--variant_index_type LINEAR \
--variant_index_parameter 128000 \
-pairHMM VECTOR_LOGLESS_CACHING \
-forceActive \
-disableOptimizations \
--max_alternate_alleles 3 \
--bamOutput $CORE_PATH/$PROJECT/HC_BAM/$SM_TAG".HC.ForceActive.bam" \
-o $CORE_PATH/$PROJECT/HC_BAM/$SM_TAG".HC.ForceActive.HC.vcf"

bgzip-0.2.6 -c $CORE_PATH/$PROJECT/HC_BAM/$SM_TAG".HC.ForceActive.vcf" \
>| $CORE_PATH/$PROJECT/HC_BAM/$SM_TAG".HC.ForceActive.vcf.gz"

tabix-0.2.6 -f -p vcf $CORE_PATH/$PROJECT/HC_BAM/$SM_TAG".HC.ForceActive.vcf.gz"

## Use the above bed file to write a HC bam file for variants,reference and all possible haplotypes using same parameters used to generate GVCF

$JAVA_1_7/java -jar $GATK_DIR/GenomeAnalysisTK.jar \
-T HaplotypeCaller \
-R $REF_GENOME \
--input_file $CORE_PATH/$PROJECT/Release_Data/rawdataset_to_PI_NCBI/BAM/$SM_TAG".bam" \
--dbsnp $DBSNP \
-L $IN_BED \
--emitRefConfidence GVCF \
--variant_index_type LINEAR \
--variant_index_parameter 128000 \
-pairHMM VECTOR_LOGLESS_CACHING \
-forceActive \
-disableOptimizations \
-bamWriterType ALL_POSSIBLE_HAPLOTYPES \
--max_alternate_alleles 3 \
--bamOutput $CORE_PATH/$PROJECT/HC_BAM/$SM_TAG".HC.ForceActive_AllPossible.bam" \
-o $CORE_PATH/$PROJECT/HC_BAM/$SM_TAG".HC.ForceActive_AllPossible.vcf"

bgzip-0.2.6 -c $CORE_PATH/$PROJECT/HC_BAM/$SM_TAG".HC.ForceActive_AllPossible.vcf" \
>| $CORE_PATH/$PROJECT/HC_BAM/$SM_TAG".HC.ForceActive_AllPossible.vcf.gz"

tabix-0.2.6 -f -p vcf $CORE_PATH/$PROJECT/HC_BAM/$SM_TAG".HC.ForceActive_AllPossible.vcf.gz"
