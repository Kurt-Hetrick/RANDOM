#! /bin/bash

###################
# INPUT VARIABLES #
###################

	SAMPLE_SHEET=$1 # full/relative path to the sample sheet
	PRIORITY=$2 # default is -12. do not supply this argument unless you want to change from the default. range is -1 to -1023.

		if [[ ! $PRIORITY ]]
			then
			PRIORITY="-11"
		fi

###########################
# CORE VARIABLES/SETTINGS #
###########################

	# CHANGE SCRIPT DIR TO WHERE YOU HAVE HAVE THE SCRIPTS BEING SUBMITTED

		SUBMITTER_SCRIPT_PATH=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )

		SCRIPT_DIR="$SUBMITTER_SCRIPT_PATH"

	# gcc is so that it can be pushed out to the compute nodes via qsub (-V)
	module load gcc/7.2.0
	module load datamash

	# Directory where sequencing projects are located
	CORE_PATH="/mnt/research/active"

	 # Use bigmem.q for ANNOVAR in addition to everything else
	ANNOVAR_QUEUE_LIST=`qstat -f -s r \
		| egrep -v "^[0-9]|^-|^queue|^ " \
		| cut -d @ -f 1 \
		| sort \
		| uniq \
		| egrep -v "all.q|cgc.q|programmers.q|qtest.q|uhoh.q|test.q" \
		| datamash collapse 1 \
		| awk '{print $1}'`

	# explicitly setting this b/c not everybody has had the $HOME directory transferred and I'm not going to through
	# and figure out who does and does not have this set correctly
	umask 0007

	# grab email addy

		SEND_TO=`cat $SCRIPT_DIR/email_lists.txt`

#####################
# PIPELINE PROGRAMS #
#####################

	CIDRSEQSUITE_ANNOVAR_JAVA="/mnt/linuxtools/JAVA/jdk1.8.0_73/bin"
	CIDRSEQSUITE_DIR_4_0="/mnt/research/tools/LINUX/CIDRSEQSUITE/Version_4_0"
	CIDRSEQSUITE_PROPS_DIR="/mnt/research/tools/LINUX/00_GIT_REPO_KURT/CIDR_SEQ_CAPTURE_JOINT_CALL/CMG"
	# cp -p /u01/home/hling/cidrseqsuite.props.HGMD /mnt/research/tools/LINUX/00_GIT_REPO_KURT/CIDR_SEQ_CAPTURE_JOINT_CALL/STD_VQSR/cidrseqsuite.props
	# 14 June 2018

#######################################################################
#######################################################################
################### Start of Sample Breakouts #########################
#######################################################################
#######################################################################


	# for each unique sample id in the sample sheet grab the bed files, ref genome, project and store as an array

		CREATE_SAMPLE_INFO_ARRAY ()
			{
				SAMPLE_INFO_ARRAY=(`sed 's/\r//g' $SAMPLE_SHEET \
					| awk 'BEGIN{FS=","} NR>1 {print $1,$8}' \
					| sed 's/,/\t/g' \
					| sort -k 2,2 \
					| uniq \
					| awk '$2=="'$SAMPLE'" {print $1,$2}'`)

				PROJECT_SAMPLE=${SAMPLE_INFO_ARRAY[0]}
				SM_TAG=${SAMPLE_INFO_ARRAY[1]}

				UNIQUE_ID_SM_TAG=$(echo $SM_TAG | sed 's/@/_/g') # If there is an @ in the qsub or holdId name it breaks
				BARCODE_2D=$(echo $SM_TAG | awk '{n=split($1,SM_TAG,/[@-]/); print SM_TAG[n]}') # SM_TAG = RIS_ID[@-]BARCODE_2D
			}

	# for each sample make a bunch directories if not already present in the samples defined project directory
	# shouldn't need this anymore $SM_TAG"_SCATTER"

		MAKE_PROJ_DIR_TREE ()
			{
				mkdir -p \
				$CORE_PATH/$PROJECT_SAMPLE/TEMP/$SM_TAG"_ANNOVAR" \
				$CORE_PATH/$PROJECT_SAMPLE/LOGS/$SM_TAG \
				$CORE_PATH/$PROJECT_SAMPLE/REPORTS/ANNOVAR
			}

		SETUP_AND_RUN_ANNOVAR ()
			{
				echo \
				qsub \
					-S /bin/bash \
					-cwd \
					-V \
					-q $ANNOVAR_QUEUE_LIST \
					-p $PRIORITY \
					-j y \
					-pe slots 5 \
					-R y \
				-N SETUP_AND_RUN_ANNOVAR_$UNIQUE_ID_SM_TAG \
					-o $CORE_PATH/$PROJECT_SAMPLE/LOGS/$SM_TAG/SETUP_AND_RUN_ANNOVAR_$SM_TAG".log" \
				$SCRIPT_DIR/SETUP_AND_RUN_ANNOVAR.sh \
					$PROJECT_SAMPLE \
					$SM_TAG \
					$CIDRSEQSUITE_ANNOVAR_JAVA \
					$CIDRSEQSUITE_DIR_4_0 \
					$CORE_PATH \
					$CIDRSEQSUITE_PROPS_DIR
			}

##########################################################################
######################End of Functions####################################
##########################################################################

# build hold id for qc report prep per sample, per project

	BUILD_HOLD_ID_PATH_PROJECT_WRAP_UP ()
	{
		HOLD_ID_PATH="-hold_jid "

		for SAMPLE in $(awk 1 $SAMPLE_SHEET \
			| sed 's/\r//g; /^$/d; /^[[:space:]]*$/d; /^,/d' \
			| awk 'BEGIN {FS=","} $1=="'$PROJECT'" {print $8}' \
			| sort \
			| uniq);
		do
			CREATE_SAMPLE_INFO_ARRAY
			HOLD_ID_PATH=$HOLD_ID_PATH"SETUP_AND_RUN_ANNOVAR_$UNIQUE_ID_SM_TAG"","
			HOLD_ID_PATH=`echo $HOLD_ID_PATH | sed 's/@/_/g'`
		done
	}

for SAMPLE in $(awk 'BEGIN {FS=","} NR>1 {print $8}' $SAMPLE_SHEET | sort | uniq )
	do
		CREATE_SAMPLE_INFO_ARRAY
		MAKE_PROJ_DIR_TREE
		SETUP_AND_RUN_ANNOVAR
		echo sleep 0.1s
done

# run end project functions (qc report, file clean-up) for each project

	PROJECT_WRAP_UP ()
	{
		echo \
		qsub \
			-S /bin/bash \
			-cwd \
			-V \
			-q $ANNOVAR_QUEUE_LIST \
			-p -1 \
			-j y \
			-m e \
			-M $SEND_TO \
		-N SEND_EMAIL_SS_ANNOVAR \
			-o $SCRIPT_DIR/../LOGS/ \
		$HOLD_ID_PATH \
		$SCRIPT_DIR/SEND_EMAIL_SS_ANNOVAR.sh \
			$SAMPLE_SHEET \
			$SEND_TO
	}

# final loop

for PROJECT in $(awk 1 $SAMPLE_SHEET \
			| sed 's/\r//g; /^$/d; /^[[:space:]]*$/d; /^,/d' \
			| awk 'BEGIN {FS=","} NR>1 {print $1}' \
			| sort \
			| uniq);
	do
		BUILD_HOLD_ID_PATH_PROJECT_WRAP_UP
		PROJECT_WRAP_UP
done

# email when finished submitting

	SUBMITTER_ID=`whoami`

	PERSON_NAME=`getent passwd | awk 'BEGIN {FS=":"} $1=="'$SUBMITTER_ID'" {print $5}'`

	printf "$SAMPLE_SHEET\nhas finished submitting at\n`date`\nby `whoami`" \
		| mail -s "$PERSON_NAME has submitted SUBMIT_SS_ANNOVAR.sh" \
			$SEND_TO
