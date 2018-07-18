#!/bin/bash

# INPUT ARGUMENTS

	DUPS_FILE=$1 # FULL PATH
	MASTER_KEY=$2 # FULL PATH

# OTHER VARIABLES

	OUTFILE_PREFIX=(`basename $DUPS_FILE .csv`)

	TIMESTAMP=`date '+%F.%H-%M-%S'`

# CMD LINE

	sed 's/\r//g' $DUPS_FILE \
		| awk 'BEGIN {FS=","} NR>1 {print $1,$2}' \
		| sed 's/ /\n/g' \
		| awk '{print "grep -w",$1,"'$MASTER_KEY'"}' \
		| bash \
		| cut -d "," -f 3 \
		| paste - - \
		| awk 'BEGIN {print "Subject ID 1""\t""Subject ID 2"} {print $0}' \
		| sed 's/\t/,/g' \
		| paste - $DUPS_FILE \
		| sed 's/\t/,/g' \
		| awk 'BEGIN {FS=",";OFS=","} {print $1,$2,$5,$6}' \
	>| $HOME/$OUTFILE_PREFIX"_SM_TAG"-$TIMESTAMP".csv"

# ECHO OUTPUT LOCATION

	echo DUPLICATE FILE WITH SM TAGS HAS BEEN WRITTEN TO $HOME/$OUTFILE_PREFIX"_SM_TAG"-$TIMESTAMP".csv"
