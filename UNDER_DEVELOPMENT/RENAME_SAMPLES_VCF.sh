# ---qsub parameter settings---
# --these can be overrode at qsub invocation--

# tell sge to execute in bash
#$ -S /bin/bash

# tell sge that you are in the users current working directory
#$ -cwd

# tell sge to export the users environment variables
#$ -V

# tell sge to submit at this priority setting
#$ -p -5

# tell sge to output both stderr and stdout to the same file
#$ -j y

# export all variables, useful to find out what compute node the program was executed on

	set

	echo

# INPUT VARIABLES

	INPUT_VCF=$1 # can be compressed or uncompressed
		INPUT_VCF_BASENAME=$(basename $INPUT_VCF .vcf.gz)
		INPUT_VCF_DIR=$(dirname $INPUT_VCF)
	INPUT_KEY=$2 # should be comma-delimited file with no header. needs to be old name in field #1 and then new name in field #2
		INPUT_KEY_BASENAME=$(basename $INPUT_KEY .csv)
		INPUT_KEY_DIR=$(dirname $INPUT_KEY)
	THREADS=$3 # optional 3rd argument

		# if there is no 3rd argument present then use the number for priority
			if [[ ! $THREADS ]]
				then
				THREADS="4"
			fi

# turn key into white-space delimted text file

	awk 1 $INPUT_KEY \
		| sed 's/\r//g; /^$/d; /^[[:space:]]*$/d' \
		| sed 's/,/ /g' \
	>| $INPUT_KEY_DIR/$INPUT_KEY_BASENAME".txt"

# rehead vcf

bcftools \
reheader \
--samples $INPUT_KEY_DIR/$INPUT_KEY_BASENAME".txt" \
--output $INPUT_VCF_BASENAME/$INPUT_VCF_BASENAME"_reheader.vcf.gz" \
$INPUT_VCF

	# check the exit signal at this point.

		SCRIPT_STATUS=`echo $?`

# if bad things happen mail kurt and user.
# if good things happen email user that it is done and where file is

# grab submitter's name

	PERSON_NAME=`getent passwd | awk 'BEGIN {FS=":"} $1=="'$SUBMITTER_ID'" {print $5}'`

# EMAIL WHEN DONE SUBMITTING

		if [ $SCRIPT_STATUS -ne 0 ]
			then
				printf "SOMETHING BAD HAPPENED TO REWRITING $INPUT_VCF" \
					| mail -s "Kurt has been notified. $INPUT_VCF. JOB ID: $SGE_JOB_ID. IF DONE INTERACTIVELY PLEASE EMAIL KURT ERROR MESSAGE" \
						$PERSON_NAME@jhmi.edu,khetric1@jhmi.edu
			else
				echo $INPUT_VCF_BASENAME/$INPUT_VCF_BASENAME"_reheader.vcf.gz" has been created \
					| mail -s "$INPUT_VCF header has been rewritten $INPUT_VCF_BASENAME/$INPUT_VCF_BASENAME"_reheader.vcf.gz"" \
						$PERSON_NAME@jhmi.edu		
		fi

exit $SCRIPT_STATUS
