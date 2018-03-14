#!/bin/bash

set -o pipefail

input_directory=$1

# reformat indel files

for summary_stat_indel_csv in $(ls $input_directory/SummaryStat_INDEL*csv);
	do
		echo working on $summary_stat_indel_csv at `date`
		echo

		dir_name=$(dirname $summary_stat_indel_csv)

		foo_name=$(basename $summary_stat_indel_csv .csv)

		(awk 'BEGIN {FS=",";OFS="\t"} NR==1 {print $2, $3, $13, $23 "_" $24 "_" $25 "_" $26 "_" $27 "_" $28 "_" $29}' \
			$summary_stat_indel_csv ; \
			awk 'BEGIN {FS=",";OFS="\t"} \
			NR>1 \
			{if ($25=="") print $2 , $3 , $13 , $23 "_" $24 ; \
				else if ($26==""&&$25!="") print $2 , $3 , $13 , $23 "_" $24 "_" $25 ; \
				else if ($27==""&&$26!="") print $2 , $3 , $13 , $23 "_" $24 "_" $25 "_" $26 ; \
				else if ($28==""&&$27!="") print $2 , $3 , $13 , $23 "_" $24 "_" $25 "_" $26 "_" $27 ; \
				else if ($29==""&&$28!="") print $2 , $3 , $13 , $23 "_" $24 "_" $25 "_" $26 "_" $27 "_" $28 ; \
			else print $2 , $3 , $13 , $23 "_" $24 "_" $25 "_" $26 "_" $27 "_" $28 "_" $29 }' \
			$summary_stat_indel_csv) \
		>| $dir_name/$foo_name".4col.txt"

		echo wrote $dir_name/$foo_name".4col.txt" at `date`
		echo

	done

# reformat snv files

for summary_stat_snv_csv in $(ls $input_directory/SummaryStat_SNV*csv);
	do
		echo working on $summary_stat_snv_csv at `date`
		echo

		dir_name=$(dirname $summary_stat_snv_csv)

		foo_name=$(basename $summary_stat_snv_csv .csv)

		(awk 'BEGIN {FS=",";OFS="\t"} NR==1 {print $2, $3, $13, $20 "_" $21 "_" $22 "_" $23 }' \
			$summary_stat_snv_csv ; \
			awk 'BEGIN {FS=",";OFS="\t"} \
			NR>1 \
			{if ($22=="") print $2 , $3 , $13 , $20 "_" $21 ; \
				else if ($23==""&&$22!="") print $2 , $3 , $13 , $20 "_" $21 "_" $22 ; \
			else print $2 , $3 , $13 , $20 "_" $21 "_" $22 "_" $23 }' \
			$summary_stat_snv_csv) \
		>| $dir_name/$foo_name".4col.txt"

		echo wrote $dir_name/$foo_name".4col.txt" at `date`
		echo

	done
