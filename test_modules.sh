#!/bin/bash

# remove all modules
module purge

# load the gcc module
module load gcc/7.2.0

# load module
# run the version
# run the help
# purge
# unload module

clear

echo module load anaconda-python/2.7
module load anaconda-python/2.7
python --version
python --help
sleep 10s
clear
module unload anaconda-python/2.7

echo module load anaconda-python/3.7
module load anaconda-python/3.7
python --version
python --help
sleep 10s
clear
echo module load anaconda-python/3.7

echo module load bcl2fastq/2.17.1.14
module load bcl2fastq/2.17.1.14
bcl2fastq --version
bcl2fastq --help
sleep 10s
clear
module unload bcl2fastq/2.17.1.14

echo module load bcl2fastq/2.20.0.422
module load bcl2fastq/2.20.0.422
bcl2fastq --version
bcl2fastq --help
sleep 10s
clear
module unload bcl2fastq/2.20.0.422

echo module load bedtools/2.26.0
module load bedtools/2.26.0
bedtools --version
bedtools --help
sleep 10s
clear
module unload bedtools/2.26.0

echo module load bwa/0.7.8
module load bwa/0.7.8
bwa
sleep 10s
clear
module unload bwa/0.7.8

echo module load cellranger/1.3.1
module load cellranger/1.3.1
cellranger --version
cellranger --help
sleep 10s
clear
module unload cellranger/1.3.1

echo module load cellranger/2.1.1
module load cellranger/2.1.1
cellranger --version
cellranger --help
sleep 10s
clear
module unload cellranger/2.1.1

echo module load datamash/1.1.0
module load datamash/1.1.0
datamash --version
datamash --help
sleep 10s
clear
module unload datamash/1.1.0

echo module load gatk/3.7
module load gatk/3.7
gatk --version
gatk --help
sleep 10s
clear
module unload gatk/3.7

echo module load gatk/nightly-2016-06-26-g15888ad
module load gatk/nightly-2016-06-26-g15888ad
gatk --version
gatk --help
sleep 10s
clear
module unload gatk/nightly-2016-06-26-g15888ad

echo module load gatk/nightly-2016-09-13-gb43f5e1
module load gatk/nightly-2016-09-13-gb43f5e1
gatk --version
gatk --help
sleep 10s
clear
module unload gatk/nightly-2016-09-13-gb43f5e1

echo module load java/1.7.0_80
module load java/1.7.0_80
java -version
java -help
sleep 10s
clear
module unload java/1.7.0_80

echo module load java/1.8.0_112
module load java/1.8.0_112
java -version
java -help
sleep 10s
clear
module unload java/1.8.0_112

echo module load king/1.9
module load king/1.9
king --version
king --help
sleep 10s
clear
module unload king/1.9

echo module load king/2.0
module load king/2.0
king --version
king --help
sleep 10s
clear
module unload king/2.0

echo module load king/2.13
module load king/2.13
king --version
king --help
sleep 10s
clear
module unload king/2.13

echo module load picard/2.1.1
module load picard/2.1.1
picard --version
picard --help
sleep 10s
clear
module unload picard/2.1.1

echo module load pigz/2.3.4
module load pigz/2.3.4
pigz --version
pigz --help
sleep 10s
clear
module unload pigz/2.3.4

echo module load plink/1.0.7
module load plink/1.0.7
plink --version --noweb
plink --help --noweb
sleep 10s
clear
module unload plink/1.0.7

echo module load plink/1.90
module load plink/1.90
plink --version
plink --help
sleep 10s
clear
module unload plink/1.90

echo module load R/3.0.1
module load R/3.0.1
R --version
R --help
sleep 10s
clear
module unload R/3.0.1

echo module load R/3.5.1
module load R/3.5.1
R --version
R --help
sleep 10s
clear
module unload R/3.5.1

echo module load samtools/0.1.18
module load samtools/0.1.18
samtools
sleep 10s
clear
module unload samtools/0.1.18

echo module load samtools/1.8
module load samtools/1.8
samtools --version
samtools --help
sleep 10s
clear
module unload samtools/1.8

echo module load sublime_text/3.3143
module load sublime_text/3.3143
sublime_text --version
sublime_text --help
sleep 10s
clear
module unload sublime_text/3.3143

echo module load tabix/0.2.6
module load tabix/0.2.6
tabix
sleep 10s
clear
module unload tabix/0.2.6

echo module load vcftools/0.1.12b
module load vcftools/0.1.12b
vcftools
sleep 10s
clear
module unload vcftools/0.1.12b

echo module load verifybamid/1.0.0
module load verifybamid/1.0.0
verifyBamID --version
verifyBamID--help
sleep 10s
clear
module unload verifybamid/1.0.0

echo module load verifyIDensity/0.1
module load verifyIDensity/0.1
verifyIDintensity --version
verifyIDintensity --help
sleep 10s
clear
module unload verifyIDensity/0.1

echo module load vt/0.5772
module load vt/0.5772
vt --version
vt --help
sleep 10s
clear
module unload vt/0.5772

echo module load xhmm/1.0
module load xhmm/1.0
xhmm --version
xhmm --help
sleep 10s
clear
module unload xhmm/1.0

echo module load merlin/1.1.2
module load merlin/1.1.2
merlin --version
merlin --help
sleep 10s
clear
module unload merlin/1.1.2

echo module load IMPUTE2/2.3.2
module load IMPUTE2/2.3.2
impute2 --version
impute2 --help
sleep 10s
clear
module unload IMPUTE2/2.3.2

echo module load parallel/20161222
module load parallel/20161222
parallel --version
parallel --help
sleep 10s
clear
module unload parallel/20161222

echo module load SHAPEIT2/2
module load SHAPEIT2/2
shapeit --version
shapeit --help
sleep 10s
clear
module unload SHAPEIT2/2

echo module load perl/5.25.9
module load perl/5.25.9
perl --version
perl --help
sleep 10s
clear
module unload perl/5.25.9

echo module load circos/0.69-4
module load circos/0.69-4
circos --version
circos --help
sleep 10s
clear
module unload circos/0.69-4

echo module load mgpileup/0.7
module load mgpileup/0.7
mgpileup --version
mgpileup --help
sleep 10s
clear
module unload mgpileup/0.7

echo module load netperf/2.7.0
module load netperf/2.7.0
netperf --version
netperf --help
sleep 10s
clear
module unload netperf/2.7.0

source ~/.bash_profile
