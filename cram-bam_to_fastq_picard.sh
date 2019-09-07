# ---qsub parameter settings---
# --these can be overrode at qsub invocation--

# tell sge to execute in bash
#$ -S /bin/bash 

# tell sge to submit any of these queue when available
#$ -q prod.q,rnd.q,c6320.q,lemon.q,c6420.q

# tell sge that you are in the users current working directory
#$ -cwd

# tell sge to export the users environment variables
#$ -V

# tell sge to submit at this priority setting
#$ -p -1022

# tell sge to output both stderr and stdout to the same file
#$ -j y

# export all variables, useful to find out what compute node the program was executed on

	set

	echo

# software

	module load java/1.7.0_80
	module load pigz/2.3.4

	PICARD_DIR="/mnt/research/tools/LINUX/PICARD/picard-tools-1.141"
	SAMTOOLS_DIR="/mnt/linuxtools/ANACONDA/anaconda2-5.0.0.1/bin"

# input variables

	INFILE=$1 # Input CRAM File
	OUT_DIR=$2 # Output Directory for Fastq Files
	REF_GENOME=$3 # Reference genome in fasta format used for creating BAM file. Needs to be indexed with samtools faidx (would have ref.fasta.fai companion file)

	DEFAULT_REF_GENOME=/mnt/research/tools/PIPELINE_FILES/bwa_mem_0.7.5a_ref/human_g1k_v37_decoy.fasta

	if [[ ! $REF_GENOME ]]
		then
		REF_GENOME=$DEFAULT_REF_GENOME
	fi

# revert back to original quality scores if present and resort back to query name and then convert back to fastq
# See for further explanation: http://broadinstitute.github.io/picard/command-line-overview.html#SamToFastq
#Can use picard versions 1.141 or later
#If using picard 2+ java 8 is required.  Older versions work with java 7
# Using picard-1.141 or later SamToFastq to convert the CRAM file designated by the first parameter (IN_CRAM) to it's FASTQ parts broken out per read group into the specified directory (OUT_DIR) without the need to convert to an intermediate BAM file
# OUTPUT_PER_RG writes a pair of fastq files per lane and named based on the Platform Unit found in the header of the BAM file
# If platform isn't present than set RG_TAG to ID (will need to create if condition in the future)
# RG_TAG=ID \

java -jar $PICARD_DIR/picard.jar \
	RevertSam \
	INPUT=$INFILE \
	OUTPUT=/dev/stdout \
	SORT_ORDER=queryname \
	REFERENCE_SEQUENCE=$REF_GENOME \
	COMPRESSION_LEVEL=0 \
	VALIDATION_STRINGENCY=SILENT \
| java -jar $PICARD_DIR/picard.jar \
	SamToFastq \
	INPUT=/dev/stdin \
	REFERENCE_SEQUENCE=$REF_GENOME \
	OUTPUT_PER_RG=true \
	OUTPUT_DIR=$OUT_DIR \
	VALIDATION_STRINGENCY=SILENT

echo

# obtain the field number that contains the platform unit tag to pull out from

	PU_FIELD=(`$SAMTOOLS_DIR/samtools view -H \
	$INFILE \
		| grep -m 1 ^@RG \
		| sed 's/\t/\n/g' \
		| cat -n \
		| sed 's/^ *//g' \
		| awk '$2~/^PU:/ {print $1}'`)

# function to gzip with pigz using 4 threads read 1 fastq. validation with md5sum and generate md5sum for gzipped file

	GZIP_FASTQ_1 ()
	{
		echo generating md5sum for $OUT_DIR/$PLATFORM_UNIT"_1.fastq"
		FASTQ_FILE_MD5_READ_1=$(md5sum $OUT_DIR/$PLATFORM_UNIT"_1.fastq" | awk '{print $1}')
		echo

		pigz -v -p 4 -c $OUT_DIR/$PLATFORM_UNIT"_1.fastq" \
		>| $OUT_DIR/$PLATFORM_UNIT"_1.fastq.gz"
		echo

		echo validating $OUT_DIR/$PLATFORM_UNIT"_1.fastq" md5sum after gzipping
		GZIP_FASTQ_FILE_MD5_READ_1=$(zcat $OUT_DIR/$PLATFORM_UNIT"_1.fastq.gz" | md5sum | awk '{print $1}')
		echo

		echo generating md5sum for $OUT_DIR/$PLATFORM_UNIT"_1.fastq.gz"
		FINAL_MD5_READ_1=$(md5sum $OUT_DIR/$PLATFORM_UNIT"_1.fastq.gz")
		echo

			if [[ $FASTQ_FILE_MD5_READ_1 = $GZIP_FASTQ_FILE_MD5_READ_1 ]]
				then
					rm -rvf $OUT_DIR/$PLATFORM_UNIT"_1.fastq"
					echo
					echo writing md5sum to $OUT_DIR/gzip_md5.txt
					echo
					echo $FINAL_MD5_READ_1 >> $OUT_DIR/gzip_md5.txt
					echo writing md5sum validation to $OUT_DIR/md5_validation.txt
					echo $PLATFORM_UNIT"_1.fastq" $FASTQ_FILE_MD5_READ_1 $GZIP_FASTQ_FILE_MD5_READ_1 >> $OUT_DIR/md5_validation.txt
					echo
				else
					printf "$OUT_DIR/$PLATFORM_UNIT"_1.fastq" did not compress successfully on $HOSTNAME at `date`" | mail -s "UH-OH A BOO-BOO HAPPENED" khetric1@jhmi.edu 
			fi
	}

# function to gzip with pigz using 4 threads read 2 fastq. validation with md5sum and generate md5sum for gzipped file

	GZIP_FASTQ_2 ()
	{
		echo generating md5sum for $OUT_DIR/$PLATFORM_UNIT"_2.fastq"
		FASTQ_FILE_MD5_READ_2=$(md5sum $OUT_DIR/$PLATFORM_UNIT"_2.fastq" | awk '{print $1}')
		echo

		pigz -v -p 4 -c $OUT_DIR/$PLATFORM_UNIT"_2.fastq" \
		>| $OUT_DIR/$PLATFORM_UNIT"_2.fastq.gz"
		echo

		echo validating $OUT_DIR/$PLATFORM_UNIT"_2.fastq" md5sum after gzipping
		GZIP_FASTQ_FILE_MD5_READ_2=$(zcat $OUT_DIR/$PLATFORM_UNIT"_2.fastq.gz" | md5sum | awk '{print $1}')
		echo

		echo generating md5sum for $OUT_DIR/$PLATFORM_UNIT"_2.fastq.gz"
		FINAL_MD5_READ_2=$(md5sum $OUT_DIR/$PLATFORM_UNIT"_2.fastq.gz")
		echo

			if [[ $FASTQ_FILE_MD5_READ_2 = $GZIP_FASTQ_FILE_MD5_READ_2 ]]
				then
					rm -rvf $OUT_DIR/$PLATFORM_UNIT"_2.fastq"
					echo
					echo writing md5sum to $OUT_DIR/gzip_md5.txt
					echo
					echo $FINAL_MD5_READ_2 >> $OUT_DIR/gzip_md5.txt
					echo writing md5sum validation to $OUT_DIR/md_validation.txt
					echo $PLATFORM_UNIT"_2.fastq" $FASTQ_FILE_MD5_READ_2 $GZIP_FASTQ_FILE_MD5_READ_2 >> $OUT_DIR/md5_validation.txt
					echo
				else
					printf "$OUT_DIR/$PLATFORM_UNIT"_2.fastq" did not compress successfully on $HOSTNAME at `date`" | mail -s "UH-OH A BOO-BOO HAPPENED" khetric1@jhmi.edu 
			fi
	}

# loop through platform units and gzip files

	for PLATFORM_UNIT in $($SAMTOOLS_DIR/samtools view -H $INFILE | grep ^@RG | awk -v PU_FIELD="$PU_FIELD" 'BEGIN {OFS="\t"} {split($PU_FIELD,PU,":"); print PU[2]}' | sed 's/~/_/g');
		do
			GZIP_FASTQ_1
			GZIP_FASTQ_2
	done

echo DONE at `date`
