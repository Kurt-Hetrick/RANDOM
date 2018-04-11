# ---qsub parameter settings---
# --these can be overrode at qsub invocation--

# tell sge to execute in bash
#$ -S /bin/bash 

# tell sge that you are in the users current working directory
#$ -cwd

# tell sge to export the users environment variables
#$ -V

# tell sge to output both stderr and stdout to the same file
#$ -j y

# export all variables, useful to find out what compute node the program was executed on
# redirecting stderr/stdout to file as a log.

set

echo

THREADS=$1
INSTANCE=$2
TEST_TYPE=$3 # (SINGLE OR FLOOD)
PLATFORM=$4 # (QUMOLO OR ISILON)
JOB_COUNT=$5
QUEUE_SLOTS=$6
TOTAL_SLOTS=$7

if [ $PLATFORM == 'ISILON' ]
then
CORE_PATH="/isilon/sequencing/Seq_Proj/"
else
CORE_PATH="/jhg-qumulo/Sequencing/Seq_Proj/"
fi

# if [ $PLATFORM == 'ISILON' ]
# then
# SAMTOOLS_DIR="/isilon/sequencing/Seq_Proj/"
# else
# SAMTOOLS_DIR="/jhg-qumulo/Sequencing/Seq_Proj/"
# fi

if [ $PLATFORM == 'ISILON' ]
then
TEMP="/isilon/sequencing/Kurt/QUMOLO_TESTS/"
else
TEMP="/jhg-qumulo/Sequencing/Seq_Proj/QUMOLO_TESTS/"
fi

HOSTNAME=`hostname`

mkdir -p $TEMP/QUMOLO_TESTS/$HOSTNAME/$INSTANCE

START_SAMTOOLS_SORT=`date '+%s'`

samtools sort -n --threads $THREADS \
$CORE_PATH/Haiman_ProstateCa_SeqWholeExome_080814_1/BAM/AGGREGATE/102485-0224132002.bam \
-o $TEMP/QUMOLO_TESTS/$HOSTNAME/$INSTANCE/foo.bam

END_SAMTOOLS_SORT=`date '+%s'`

echo SAMTOOLS_SORT"," $HOSTNAME"," $INSTANCE"," $THREADS ","$TEST_TYPE","$PLATFORM","$JOB_COUNT","$QUEUE_SLOTS","$TOTAL_SLOTS","$START_SAMTOOLS_SORT","$END_SAMTOOLS_SORT \
>> /isilon/sequencing/Kurt/QUMOLO_TESTS/BWA_MEM.WALL_CLOCK_TIMES.csv
