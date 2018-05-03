#!/bin/bash

PROJECT=$1
MULTI_VCF=$2
PED_FILE=$3

awk '$3!="0"&&$4!="0"' $PED_FILE \
| awk '{print "qsub","-N","MENDEL_CHECK_"$1,\
"-o","/isilon/sequencing/Seq_Proj/""'$PROJECT'""/LOGS/MENDEL_CHECK_"$1"_"$2"_"$3"_"$4".log",\
"-e","/isilon/sequencing/Seq_Proj/""'$PROJECT'""/LOGS/MENDEL_CHECK_"$1"_"$2"_"$3"_"$4".log",\
"/isilon/sequencing/Kurt/NICE_SCRIPTS/MENDEL.INHERITANCE.sh",\
"'$PROJECT'","'$MULTI_VCF'",$1,$2,$3,$4,$5"\n""sleep 3s"}'
