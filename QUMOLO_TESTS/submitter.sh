#!/bin/bash

SCRIPT=$1
QUEUE=$2
THREADS=$3
TEST_TYPE=$4 # FLOOD OR SINGLE
PLATFORM=$5 # ISILON OR QUMOLO
QUEUE_SLOTS=$6 # 4,3,2 OR 1

mkdir -p /isilon/sequencing/Kurt/QUMOLO_TESTS/
mkdir -p /jhg-qumulo/Sequencing/Seq_Proj/QUMOLO_TESTS/

if [ $PLATFORM == 'ISILON' ]
then
TEMP="/isilon/sequencing/Kurt/QUMOLO_TESTS"
else
TEMP="/jhg-qumulo/Sequencing/Seq_Proj/QUMOLO_TESTS"
fi

TOTAL_SLOTS=`qstat -g c | awk 'NR>2' | sed -r 's/[[:space:]]+/\t/g' | egrep -v "all.q|programmers.q|cgc.q" | awk '{t+=$6} END {print t}'`

JOB_COUNT=`expr $TOTAL_SLOTS / $QUEUE_SLOTS`

TEST_CONDITION ()
{
echo \
qsub \
-q $QUEUE \
-o $TEMP/LOGS \
-pe slots $QUEUE_SLOTS \
$SCRIPT \
$THREADS \
$INSTANCE \
$TEST_TYPE \
$PLATFORM \
$JOB_COUNT \
$QUEUE_SLOTS \
$TOTAL_SLOTS
}

if [ $TEST_TYPE == 'SINGLE' ]
then
for INSTANCE in $(eval echo {1..1})
	do
	TEST_CONDITION
	echo sleep 0.1s
	done
else
for INSTANCE in $(eval echo {1..$JOB_COUNT})
	do
	TEST_CONDITION
	echo sleep 0.1s
	done
fi

# for INSTANCE in $(eval echo {1..$JOB_COUNT})
# 	do
# 	TEST_CONDITION
# 	echo sleep 0.1s
# 	done
