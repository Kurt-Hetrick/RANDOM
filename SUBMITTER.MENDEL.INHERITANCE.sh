#!/bin/bash

PROJECT=$1 # the name of the project
MULTI_VCF=$2 # the name of the vcf file
PED_FILE=$3 # the full path and name of the ped file

awk '$3!="0"&&$4!="0"' $PED_FILE \
| awk '{print "qsub","-N","MENDEL_CHECK_"$1,\
"-o","/mnt/research/active/""'$PROJECT'""/LOGS/MENDEL_CHECK_"$1"_"$2"_"$3"_"$4".log",\
"-e","/mnt/research/active/""'$PROJECT'""/LOGS/MENDEL_CHECK_"$1"_"$2"_"$3"_"$4".log",\
"/mnt/research/tools/LINUX/00_GIT_REPO_KURT/RANDOM/MENDEL.INHERITANCE.sh",\
"'$PROJECT'","'$MULTI_VCF'",$1,$2,$3,$4,$5"\n""sleep 3s"}'
