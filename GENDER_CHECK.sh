#!/bin/bash

CORE_PATH="/isilon/sequencing/Seq_Proj/"

PROJECT=$1

# Creating a gender check

ls $CORE_PATH/$PROJECT/REPORTS/GENES_COVERAGE/TARGET/*sample_interval_summary.csv \
| awk 'BEGIN {OFS="\t"} {split($1,SMtag,"/"); print "awk \x27 BEGIN {FS=\x22,\x22} NR>1 {split($1,FOO,\x22:\x22); print \x22"SMtag[10]"\x22,FOO[1],FOO[2],$2}\x27",$0}' \
| bash \
| awk 'BEGIN {OFS="\t"} $3!~"-"&&$2~/^[0-9]/ {print $1,"AUTO",$3"-"$3,$4} $3~"-"&&$2~/^[0-9]/ {print $1,"AUTO",$3,$4} $3~"-"&&$2!~"[0-9]" {print $0} $3!~"-"&&$2!~"[0-9]" {print $1,$2,$3"-"$3,$4}' \
| awk 'BEGIN {OFS="\t"} {split($3,BAR,"-"); print $1,$2,(BAR[2]-(BAR[1]-1)),$4}' \
| datamash -g 1,2 sum 3 sum 4 \
| awk 'BEGIN {OFS="\t"} {print $1,$2,$4/$3}' \
| datamash -g 1 collapse 3 \
| awk 'BEGIN {print "SM_TAG","AUTO_AVG","X_AVG","X_NORM","Y_AVG","Y_NORM"} {split($2,FOO,",");split($1,BAR,".");print BAR[1],FOO[1],FOO[2],FOO[2]/FOO[1],FOO[3],FOO[3]/FOO[1]}' \
| sed 's/ /\t/g'
