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

module load bwa/0.7.8

if [ $PLATFORM == 'ISILON' ]
then
CORE_PATH="/isilon/sequencing/Seq_Proj/"
else
CORE_PATH="/jhg-qumulo/Sequencing/Seq_Proj/"
fi

FASTQ_1=`ls $CORE_PATH/Haiman_ProstateCa_SeqWholeExome_080814_1/FASTQ/CAFA9ANXX_1_ACGCTCGA_1.fastq.gz`
FASTQ_2=`ls $CORE_PATH/Haiman_ProstateCa_SeqWholeExome_080814_1/FASTQ/CAFA9ANXX_1_ACGCTCGA_2.fastq.gz`

if [ $PLATFORM == 'ISILON' ]
then
REF_GENOME="/isilon/sequencing/GATK_resource_bundle/bwa_mem_0.7.5a_ref/human_g1k_v37_decoy.fasta"
else
REF_GENOME="/jhg-qumulo/Sequencing/Seq_Proj/bwa_mem_0.7.5a_ref/human_g1k_v37_decoy.fasta"
fi

if [ $PLATFORM == 'ISILON' ]
then
TEMP="/isilon/sequencing/Kurt/QUMOLO_TESTS/"
else
TEMP="/jhg-qumulo/Sequencing/Seq_Proj/QUMOLO_TESTS/"
fi

HOSTNAME=`hostname`

mkdir -p $TEMP/QUMOLO_TESTS/$HOSTNAME/$INSTANCE

START_BWA_MEM=`date '+%s'`

bwa mem \
-t $THREADS \
$REF_GENOME \
$FASTQ_1 \
$FASTQ_2 \
>| $TEMP/QUMOLO_TESTS/$HOSTNAME/$INSTANCE/foo.sam

END_BWA_MEM=`date '+%s'`

echo BWA_MEM","$HOSTNAME","$INSTANCE","$THREADS","$TEST_TYPE","$PLATFORM","$JOB_COUNT","$QUEUE_SLOTS","$TOTAL_SLOTS","$START_BWA_MEM","$END_BWA_MEM \
>> /isilon/sequencing/Kurt/QUMOLO_TESTS/BWA_MEM.WALL_CLOCK_TIMES.csv
