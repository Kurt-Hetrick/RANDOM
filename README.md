RANDOM SCRIPTS
=======

## MD5_RECURSIVE_PARALLEL.sh

Uses [gnu parallel](https://www.gnu.org/software/parallel/) (1). to fork out concurrent instances of md5sum on a directory (and all of the its subdirectories) that you point it to.

By default it uses up to 75% of the available cpu processors, but this is configurable if you supply a number as a second argument.

The output will be written into the directory that you point it to as;

**md_target-directory_Day Month Date hh:mm:ss zone yyyy.txt**

example:

`MD5_RECURSIVE_PARALLEL.sh /path/to/directory`

* will utilize 75% of the total cpu processors on the server

`MD5_RECURSIVE_PARALLEL.sh /path/to/directory 50`

* will utilize 50% of the total cpu processors on the server

**the bigger the machine, the faster your md5sum will run. you should use qlogin into a server and request multiple slots.**

* sunrhel4 is the biggest (this has 80 total cpu processors on here)

`qlogin -q rhel7.q -pe slots 8`

* sunrhel3 and DellR730 are the same size (48 cpu processors) although the DellR730 should be faster overall, but if you don't really care as long as you get one of the big servers then you can do

`qlogin -q rhel7.q,bigdata.q,bigmem.q -pe slots 8`

## Variant_Summary_Stat_To_Text.sh

takes the 6 output csv files from Hua's summary stat program that is part of the CMG grant release and pulls out chromosome, position, observed GT if biallelic and then concatenates All of the alleles delimited by a underscore and changes the field delimiter to tab.

Assumes files are prefixed with _SummaryStat_INDEL_ and _SummaryStat_SNV_

example;

`Variant_Summary_Stat_To_Text.sh /path/to/directory`

## Haiman_Coverage_Metric_Binner.sh

takes a qc report, for each sample determines if they meet the following metrics

1. mean target >= 50x
2. 95% pct of target bases > 10x
3. 90% pct of target bases > 20x

appends new column to the end of the qc report. creates a new qc report with "COVERAGE_BIN.csv" appended to the file name.

3 means it meets all 3; 0 means it meets none of them

_usage_

`Haiman_Coverage_Metric_Binner.sh /path/to/qc_report`

_example_

`/mnt/research/tools/LINUX/00_GIT_REPO_KURT/RANDOM/Haiman_Coverage_Metric_Binner.sh /mnt/research/active/Haiman_ProstateCa_SeqWholeExome_080814_1/REPORTS/QC_Reports/Haiman_AllSamples_MEH.csv`

## DUP_FILE_LOCAL_TO_SM_CONVERTER.sh

takes the dups file and the master sample key and converts the local id to sm tag.

writes the new file to your home directory

_usage_

`DUP_FILE_LOCAL_TO_SM_CONVERTER.sh /path/to/dup_file /path/to/master_key`

## SELECT_SAMPLES_FROM_MS_VCF.sh

takes a list of samples from a file (1 per row) and makes a vcf file containing only those samples

file containing sample ids must have a .args file name extension

input vcf can be uncompressed or compressed if indexed (has a paired .tbi file)

removes loci that are not variant for the samples being extracted.

removes unused alternate alleles that are not present in the samples being extracted.

writes the new file in the same directory as the input vcf where samples are being extracted from

this assumes by default that the 1kg version of GRCh37 is what the reference genome was, if another genome is used you can add the path to the other genome at the end of the command line (see below)

_usage_

`SELECT_SAMPLES_FROM_MS_VCF.sh /path/to/sample_list.args /path/to/original.vcf{.gz} new_vcf_file_name_prefix {/path/to/different_reference_genome.fasta}`

NOTE: {/path/to/different_reference_genome.fasta} means that this is an optional argument. You only need to supply it if the vcf file was called using a different reference genome than the 1000 genomes phase 2 version of GRCh37 (human_g1k_v37_decoy.fasta). Also both .fasta and .fa extensions are allowed.

_example_

`/mnt/research/tools/LINUX/00_GIT_REPO_KURT/RANDOM/SELECT_SAMPLES_FROM_MS_VCF.sh /mnt/research/active/test.args /mnt/research/active/original.vcf test`

---

REFERENCES
=======

1. O. Tange (2011): GNU Parallel - The Command-Line Power Tool, ;login: The USENIX Magazine, February 2011:42-47.

