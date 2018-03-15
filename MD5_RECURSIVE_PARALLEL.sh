#!/bin/bash

DIRECTORY_PATH=$1
PCT_CPU_PROC_TO_USE=$2

if [[ -z "$PCT_CPU_PROC_TO_USE" ]]
	then
	PCT_CPU_PROC_TO_USE=75
fi

module load parallel/20161222

TIMESTAMP=`date '+%F.%H-%M-%S'`

LAST_FOLDER=`basename $DIRECTORY_PATH`

find $DIRECTORY_PATH -type f \
| cut -f 2 \
| parallel --no-notice --eta --jobs $PCT_CPU_PROC_TO_USE"%" md5sum {} \
> $DIRECTORY_PATH/"md5_"$LAST_FOLDER"_"$TIMESTAMP".txt"
