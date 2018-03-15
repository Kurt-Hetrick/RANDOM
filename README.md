RANDOM SCRIPTS
=======

## MD5_RECURSIVE_PARALLEL.sh

Uses [gnu parallel](https://www.gnu.org/software/parallel/) to fork out concurrent instances of md5sum on a directory (and all of the its subdirectories) that you point it to.

By default it uses up to 75% of the available cpu processors, but this is configurable if you supply a number as a second argument.

The output will be written into the directory that you point it to as;

md_target-dirctory_Day Month Date hh:mm:ss zone yyyy.txt

example:

`MD5_RECURSIVE_PARALLEL.sh /path/to/directory`

* will utilize 75% of the total cpu processors on the server

`MD5_RECURSIVE_PARALLEL.sh /path/to/directory 50`

* will utilize 50% of the total cpu processors on the server

## Variant_Summary_Stat_To_Text.sh

takes the 6 output csv files from Hua's summary stat program that is part of the CMG grant release and pulls out chromosome, position, observed GT if bialllic and then concatenates All of the allelels delimited by a underscore and changes the field delimiter to tab.

Assumes files are prefixed with _SummaryStat_INDEL_ and _SummaryStat_SNV_

example;

`Variant_Summary_Stat_To_Text.sh /path/to/directory`
