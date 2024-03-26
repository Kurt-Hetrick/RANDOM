#!/bin/env bash

SAMPLE_SHEET="/mnt/research/active/Peters_CRC_SeqCustom_020317_1/Release_Prep/Peters_CRC_SeqCustom_020317_1_SAMPLE_SHEET_2020-11-13.15-36-31_forMSC_8867s.csv"

CORE_PATH="/mnt/research/active"
PROJECT_SAMPLE="Peters_CRC_SeqCustom_020317_1"

rm -rvf x_counts.txt y_counts.txt

touch x_counts.txt
touch y_counts.txt

CALCULATE_X_METRICS ()
{
	zgrep -v "^#" $CORE_PATH/$PROJECT_SAMPLE/SNV/RELEASE/FILTERED_ON_TARGET/$SM_TAG"_MS_OnTarget_SNV.vcf.gz" \
		| awk '$1=="chrX"' \
		| awk '{SNV_COUNT++NR} {DBSNP_COUNT+=($3~"rs")} {HET_COUNT+=($10 ~ /^0\/1/)} {VAR_HOM+=($10 ~ /^1\/1/)} \
			END {if (SNV_COUNT!=""&&VAR_HOM!="0") print "'$SM_TAG'",SNV_COUNT,HET_COUNT,VAR_HOM; \
			else if (SNV_COUNT!=""&&VAR_HOM=="0") print "'$SM_TAG'",SNV_COUNT,HET_COUNT,VAR_HOM; \
			else print "'$SM_TAG'","0","0","0"}' \
		| sed 's/ /\t/g' \
		>> x_counts.txt
}

CALCULATE_Y_METRICS ()
{
	zgrep -v "^#" $CORE_PATH/$PROJECT_SAMPLE/SNV/RELEASE/FILTERED_ON_TARGET/$SM_TAG"_MS_OnTarget_SNV.vcf.gz" \
		| awk '$1=="chrY"' \
		| awk '{SNV_COUNT++NR} {DBSNP_COUNT+=($3~"rs")} {HET_COUNT+=($10 ~ /^0\/1/)} {VAR_HOM+=($10 ~ /^1\/1/)} \
			END {if (SNV_COUNT!=""&&VAR_HOM!="0") print "'$SM_TAG'",SNV_COUNT,HET_COUNT,VAR_HOM; \
			else if (SNV_COUNT!=""&&VAR_HOM=="0") print "'$SM_TAG'",SNV_COUNT,HET_COUNT,VAR_HOM; \
			else print "'$SM_TAG'","0","0","0"}' \
		| sed 's/ /\t/g' \
		>> y_counts.txt
}

for SM_TAG in $(awk 'NR>1' $SAMPLE_SHEET | cut -d "," -f 8 | sort | uniq );
do
CALCULATE_X_METRICS
CALCULATE_Y_METRICS
done

join -j 1 x_counts.txt y_counts.txt \
| awk 'BEGIN {print "SM_TAG","X_TOTAL","X_HET","X_HOM","Y_TOTAL","Y_HET","Y_HOM"} {print $0}' \
| sed 's/ /\t/g' \
>| /mnt/research/active/Peters_CRC_SeqCustom_020317_1/Release_Prep/Peters_CRC_SeqCustom_020317_1_SAMPLE_SHEET_2020-11-13.15-36-31_forMSC_8867s.x_and_y_counts.txt

