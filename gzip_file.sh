# ---qsub parameter settings---
# --these can be overrode at qsub invocation--

# tell sge to execute in bash
#$ -S /bin/bash 

# tell sge to submit any of these queue when available
#$ -q bigdata.q,prod.q,rnd.q,c6320.q,lemon.q

# tell sge that you are in the users current working directory
#$ -cwd

# tell sge to export the users environment variables
#$ -V

# tell sge to submit at this priority setting
#$ -p -1022

# tell sge to output both stderr and stdout to the same file
#$ -j y

# export all variables, useful to find out what compute node the program was executed on
# redirecting stderr/stdout to file as a log.

INFILE=$1 # Input fastq file
	INFILE_DIR=$(dirname $INFILE)

FASTQ_FILE_MD5=$(md5sum $INFILE | awk '{print $1}')

gzip -c $INFILE \
>| $INFILE".gz"

GZIP_FASTQ_FILE_MD5=$(zcat $INFILE".gz" | md5sum | awk '{print $1}')

FINAL_MD5=$(md5sum $INFILE".gz")

	if [[ $FASTQ_FILE_MD5 = $GZIP_FASTQ_FILE_MD5 ]]
		then
			rm -rvf "$INFILE"
			echo $FINAL_MD5 >> $INFILE_DIR/../gzip_md5.txt
			echo $FASTQ_FILE_MD5 $GZIP_FASTQ_FILE_MD5 >> $INFILE_DIR/../md5_validation.txt
		else
			printf "$INFILE did not compress successfully" | mail -s "UH-OH A BOO-BOO HAPPENED" khetric1@jhmi.edu 
	fi
