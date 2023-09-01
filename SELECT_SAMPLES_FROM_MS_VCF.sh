#!/bin/bash

set

echo

# INPUT ARGUMENTS

	SAMPLE_LIST=$1 #file should have a .args extension. should only contain the sample id. 1 per row
	IN_VCF=$2 # input vcf. full path
	OUT_VCF=$3 # output vcf file name prefix.
	REF_GENOME=$4 # optional. if there is no 4th argument present then grch37 is used.

		if [[ ! ${REF_GENOME} ]]
			then
			REF_GENOME="/mnt/research/tools/PIPELINE_FILES/bwa_mem_0.7.5a_ref/human_g1k_v37_decoy.fasta"
		fi

# PROGRAM DEPENDENCIES

	JAVA_1_8="/mnt/research/tools/LINUX/JAVA/jdk1.8.0_73/bin"
	GATK_DIR_4011="/mnt/linuxtools/GATK/gatk-4.0.11.0"

# output file will be written to the same directory that the input file is located at.
	
	OUT_DIR=$(dirname $IN_VCF)

# Extract out sample

	CMD=$JAVA_1_8'/java -jar'
	CMD=${CMD}" -Dsamjdk.compression_level=6 -jar"
	CMD=$CMD' '$GATK_DIR_4011'/gatk-package-4.0.11.0-local.jar'
	CMD=$CMD' SelectVariants'
	CMD=$CMD' --reference '$REF_GENOME
	CMD=$CMD' --variant '$IN_VCF
	CMD=$CMD' --output '$OUT_DIR'/'$OUT_VCF'.vcf.gz'
	CMD=$CMD' --exclude-non-variants'
	CMD=$CMD' --remove-unused-alternates'
	CMD=$CMD' --sample-name '$SAMPLE_LIST

echo $CMD | bash

echo $OUT_VCF".vcf.gz" was written to $OUT_DIR
