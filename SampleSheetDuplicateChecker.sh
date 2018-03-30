#!/bin/bash

SAMPLE_SHEET=$1 # sample sheet for the samples that you want to include in this batch
GVCF_LIST=$2 # this is the gvcf list from the last mendel release

SAMPLE_SHEET_UNIQUE_SAMPLE_COUNT=`awk 1 $SAMPLE_SHEET | sed 's/\r//g' | awk 'BEGIN {FS=","} NR>1 {print $8}' $SAMPLE_SHEET | sort | uniq | wc -l`

echo There are $SAMPLE_SHEET_UNIQUE_SAMPLE_COUNT unique samples in the sample sheet

echo

TOTAL_SAMPLE_COUNT=`awk 'BEGIN {FS=","} NR>1 {print $8}' $SAMPLE_SHEET | sort | uniq | cat $GVCF_LIST - | wc -l`

echo There are going to $TOTAL_SAMPLE_COUNT total samples in this call set

echo

echo if there any duplicate samples they will be listed below:

echo

awk 1 $SAMPLE_SHEET | sed 's/\r//g' | awk 'BEGIN {FS=","} NR>1 {print $8}' | sort | uniq | awk '{print "grep",$1,"'$GVCF_LIST'"}' | bash
