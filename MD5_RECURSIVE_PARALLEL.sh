#!/bin/bash

RELEASE_DIR=$1

GNU_PARALLEL_DIR="/isilon/sequencing/Kurt/Programs/PATH/parallel"

TIMESTAMP=`date '+%F.%H-%M-%S'`

find $RELEASE_DIR -type f | cut -f 2 | parallel --no-notice --eta --jobs 75% md5sum {} \
> $RELEASE_DIR/"md5_release_"$TIMESTAMP".txt"
