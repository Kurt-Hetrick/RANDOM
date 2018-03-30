#!/bin/bash

QC_REPORT=$1

sed 's/\r//g' $QC_REPORT >| $QC_REPORT".unix.csv"

qc_report_name=$(basename $QC_REPORT .csv)
qc_report_path=$(dirname $QC_REPORT)

awk 'BEGIN {FS=",";OFS="\t"} NR>1 \
{if ($67>=50&&$77>=0.95&&$78>=0.90) print $2,"3" ; \
else if ($67>=50&&$77>=0.95&&$78<0.90) print $2,"2" ; \
else if ($67>=50&&$77<0.95&&$78>=0.90) print $2,"2" ; \
else if ($67<50&&$77>=0.95&&$78>=0.90) print $2,"2" ; \
else if ($67>=50&&$77<0.95&&$78<0.90) print $2,"1" ; \
else if ($67<50&&$77>=0.95&&$78<0.90) print $2,"1" ; \
else if ($67<50&&$77<0.95&&$78>=0.90) print $2,"1" ; \
else print $2,"0"}' \
$QC_REPORT".unix.csv" \
| awk 'BEGIN {print "COVERAGE_BIN"} {print $2}' \
| paste -d , $QC_REPORT".unix.csv" - \
>| $qc_report_path/$qc_report_name".COVERAGE_BIN.csv"

rm -rvf $QC_REPORT".unix.csv"
