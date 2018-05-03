#!/bin/bash

PROJECT=$1

CORE_PATH="/isilon/sequencing/Seq_Proj/"

ls $CORE_PATH/$PROJECT/REPORTS/ANNOVAR/*txt \
| awk '{split($1,SMtag,"/");print "awk \x27 BEGIN {FS=\x22\x5Ct\x22} \
NR>6 \
{total_snv+=($10~\x22Snv\x22)} \
{total_indel+=($10~\x22Indel\x22)} \
{snv_126+=($10~\x22Snv\x22&&$55~\x22rs\x22)} \
{indel_126+=($10~\x22Indel\x22&&$55~\x22rs\x22)} \
{snv_131+=($10~\x22Snv\x22&&$57~\x22rs\x22)} \
{indel_131+=($10!~\x22Snv\x22&&$57~\x22rs\x22)} \
END {print \x22"SMtag[9]"\x22,\
(snv_126/total_snv*100),\
(snv_131/total_snv*100),\
(indel_126),\
(indel_131),\
(total_indel),\
(indel_126/total_indel*100),\
(indel_131/total_indel*100)}\x27",\
"'$CORE_PATH'""/""'$PROJECT'""/REPORTS/ANNOVAR/"SMtag[9]}' \
| bash \
| sed 's/_MS_OnBait_ANNOVAR_REPORT.txt//g' \
| sed 's/ /,/g' \
| awk 'BEGIN {print "SM_TAG"",""PERCENT_SNV_ON_BAIT_SNP126"",""PERCENT_SNV_ON_BAIT_SNP131"","\
"CT_INDEL_126"",""CT_INDEL_131"",""CT_TOTAL_INDEL"",""PERCENT_INDEL_ON_BAIT_SNP126"",""PERCENT_INDEL_ON_BAIT_SNP131"} \
{print $1","$2","$3","$4","$5","$6","$7","$8}' \
>| $CORE_PATH/$PROJECT/TEMP/ANNOVAR_METRICS.csv
