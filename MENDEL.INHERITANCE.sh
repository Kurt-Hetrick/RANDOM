#$ -S /bin/bash
#$ -q rnd.q,prod.q,test.q
#$ -cwd
#$ -V
#$ -p -1000

set

VCF_tools_dir="/isilon/sequencing/Kurt/Programs/VCFtools/vcftools_0.1.10/bin"
PLINK_DIR="/isilon/sequencing/Kurt/Programs/PLINK/plink-1.07-x86_64"
CORE_PATH="/isilon/sequencing/Seq_Proj/"

# Elizabeth's data/scripts Z:\ep\macrogen\pcrfree

# There is a conditional statement in the submission that fields 3 and 4 != zero in order to for this to be executed.

PROJECT=$1 # The Seq Proj Folder
IN_VCF=$2 # The MultiSample VCF
FAM=$3 # Field 1 from .ped file
CHILD=$4 # Field 2 from .ped file
DAD=$5 # Field 3 .ped file
MOM=$6 # Field 4 .ped file
CHILD_SEX=$7 # Field 5 from .ped file

mkdir -p $CORE_PATH/$PROJECT/MENDEL_CHECK/TEMP/

# Yank out trio from multi-sample vcf for passing SNVs only

$VCF_tools_dir/vcftools \
--vcf $CORE_PATH/$PROJECT/MULTI_SAMPLE/$IN_VCF \
--indv $CHILD \
--indv $MOM \
--indv $DAD \
--remove-indels \
--remove-filtered-all \
--plink \
--out $CORE_PATH/$PROJECT/MENDEL_CHECK/TEMP/"SNV_"$FAM"_"$CHILD"_"$MOM"_"$DAD

# Yank out trio from multi-sample vcf for passing INDELs only

$VCF_tools_dir/vcftools \
--vcf $CORE_PATH/$PROJECT/MULTI_SAMPLE/$IN_VCF \
--indv $CHILD \
--indv $MOM \
--indv $DAD \
--keep-only-indels \
--remove-filtered-all \
--plink \
--out $CORE_PATH/$PROJECT/MENDEL_CHECK/TEMP/"INDEL_"$FAM"_"$CHILD"_"$MOM"_"$DAD

# create a pedigree file for the trio

echo $FAM $CHILD $MOM $DAD $CHILD_SEX -9 >| $CORE_PATH/$PROJECT/MENDEL_CHECK/TEMP/"SNV_"$FAM"_"$CHILD"_"$MOM"_"$DAD".temp.ped"

echo $FAM $MOM 0 0 2 -9 >> $CORE_PATH/$PROJECT/MENDEL_CHECK/TEMP/"SNV_"$FAM"_"$CHILD"_"$MOM"_"$DAD".temp.ped"

echo $FAM $DAD 0 0 1 -9 >> $CORE_PATH/$PROJECT/MENDEL_CHECK/TEMP/"SNV_"$FAM"_"$CHILD"_"$MOM"_"$DAD".temp.ped"

# sort the above pedigree file for the trio

sort -t " " -k 2 $CORE_PATH/$PROJECT/MENDEL_CHECK/TEMP/"SNV_"$FAM"_"$CHILD"_"$MOM"_"$DAD".temp.ped" \
>| $CORE_PATH/$PROJECT/MENDEL_CHECK/TEMP/"SNV_"$FAM"_"$CHILD"_"$MOM"_"$DAD".temp.sorted.ped"

# repopulate "SNV_"$FAM"_"$CHILD"_"$MOM"_"$DAD.ped with actual ped info from ped file

cut -f 7- $CORE_PATH/$PROJECT/MENDEL_CHECK/TEMP/"SNV_"$FAM"_"$CHILD"_"$MOM"_"$DAD".ped" \
| paste $CORE_PATH/$PROJECT/MENDEL_CHECK/TEMP/"SNV_"$FAM"_"$CHILD"_"$MOM"_"$DAD".temp.sorted.ped" - \
>| $CORE_PATH/$PROJECT/MENDEL_CHECK/TEMP/"SNV_"$FAM"_"$CHILD"_"$MOM"_"$DAD".fixed.ped"

# repopulate "INDEL_"$FAM"_"$CHILD"_"$MOM"_"$DAD.ped with actual ped info from ped file

cut -f 7- $CORE_PATH/$PROJECT/MENDEL_CHECK/TEMP/"INDEL_"$FAM"_"$CHILD"_"$MOM"_"$DAD".ped" \
| paste $CORE_PATH/$PROJECT/MENDEL_CHECK/TEMP/"SNV_"$FAM"_"$CHILD"_"$MOM"_"$DAD".temp.sorted.ped" - \
>| $CORE_PATH/$PROJECT/MENDEL_CHECK/TEMP/"INDEL_"$FAM"_"$CHILD"_"$MOM"_"$DAD".fixed.ped"

# Delete the old ped files

rm -rvf $CORE_PATH/$PROJECT/MENDEL_CHECK/TEMP/"SNV_"$FAM"_"$CHILD"_"$MOM"_"$DAD".ped"

rm -rvf $CORE_PATH/$PROJECT/MENDEL_CHECK/TEMP/"INDEL_"$FAM"_"$CHILD"_"$MOM"_"$DAD".ped"

# rename the new ped file back to the old ped file names

mv -v $CORE_PATH/$PROJECT/MENDEL_CHECK/TEMP/"SNV_"$FAM"_"$CHILD"_"$MOM"_"$DAD".fixed.ped" \
$CORE_PATH/$PROJECT/MENDEL_CHECK/TEMP/"SNV_"$FAM"_"$CHILD"_"$MOM"_"$DAD".ped"

mv -v $CORE_PATH/$PROJECT/MENDEL_CHECK/TEMP/"INDEL_"$FAM"_"$CHILD"_"$MOM"_"$DAD".fixed.ped" \
$CORE_PATH/$PROJECT/MENDEL_CHECK/TEMP/"INDEL_"$FAM"_"$CHILD"_"$MOM"_"$DAD".ped"

# run plink to generate missing statistics

$PLINK_DIR/plink-1.07 \
--noweb \
--file $CORE_PATH/$PROJECT/MENDEL_CHECK/TEMP/"SNV_"$FAM"_"$CHILD"_"$MOM"_"$DAD \
--missing \
--out $CORE_PATH/$PROJECT/MENDEL_CHECK/TEMP/"SNV_"$FAM"_"$CHILD"_"$MOM"_"$DAD

$PLINK_DIR/plink-1.07 \
--noweb \
--file $CORE_PATH/$PROJECT/MENDEL_CHECK/TEMP/"INDEL_"$FAM"_"$CHILD"_"$MOM"_"$DAD \
--missing \
--out $CORE_PATH/$PROJECT/MENDEL_CHECK/TEMP/"INDEL_"$FAM"_"$CHILD"_"$MOM"_"$DAD

# run plink to count the number of mendel errors

$PLINK_DIR/plink-1.07 \
--noweb \
--file $CORE_PATH/$PROJECT/MENDEL_CHECK/TEMP/"SNV_"$FAM"_"$CHILD"_"$MOM"_"$DAD \
--mendel \
--out $CORE_PATH/$PROJECT/MENDEL_CHECK/TEMP/"SNV_"$FAM"_"$CHILD"_"$MOM"_"$DAD

$PLINK_DIR/plink-1.07 \
--noweb \
--file $CORE_PATH/$PROJECT/MENDEL_CHECK/TEMP/"INDEL_"$FAM"_"$CHILD"_"$MOM"_"$DAD \
--mendel \
--out $CORE_PATH/$PROJECT/MENDEL_CHECK/TEMP/"INDEL_"$FAM"_"$CHILD"_"$MOM"_"$DAD

# Sort the imiss files

( head -n 1 $CORE_PATH/$PROJECT/MENDEL_CHECK/TEMP/"SNV_"$FAM"_"$CHILD"_"$MOM"_"$DAD".imiss"; \
awk 'NR>1' $CORE_PATH/$PROJECT/MENDEL_CHECK/TEMP/"SNV_"$FAM"_"$CHILD"_"$MOM"_"$DAD".imiss" | sort -k 2) \
>| $CORE_PATH/$PROJECT/MENDEL_CHECK/TEMP/"SNV_"$FAM"_"$CHILD"_"$MOM"_"$DAD".sorted.imiss"

( head -n 1 $CORE_PATH/$PROJECT/MENDEL_CHECK/TEMP/"INDEL_"$FAM"_"$CHILD"_"$MOM"_"$DAD".imiss"; \
awk 'NR>1' $CORE_PATH/$PROJECT/MENDEL_CHECK/TEMP/"INDEL_"$FAM"_"$CHILD"_"$MOM"_"$DAD".imiss" | sort -k 2) \
>| $CORE_PATH/$PROJECT/MENDEL_CHECK/TEMP/"INDEL_"$FAM"_"$CHILD"_"$MOM"_"$DAD".sorted.imiss"

# Sort the imendel files

( head -n 1 $CORE_PATH/$PROJECT/MENDEL_CHECK/TEMP/"SNV_"$FAM"_"$CHILD"_"$MOM"_"$DAD".imendel"; \
awk 'NR>1' $CORE_PATH/$PROJECT/MENDEL_CHECK/TEMP/"SNV_"$FAM"_"$CHILD"_"$MOM"_"$DAD".imendel" | sort -k 2) \
>| $CORE_PATH/$PROJECT/MENDEL_CHECK/TEMP/"SNV_"$FAM"_"$CHILD"_"$MOM"_"$DAD".sorted.imendel"

( head -n 1 $CORE_PATH/$PROJECT/MENDEL_CHECK/TEMP/"INDEL_"$FAM"_"$CHILD"_"$MOM"_"$DAD".imendel"; \
awk 'NR>1' $CORE_PATH/$PROJECT/MENDEL_CHECK/TEMP/"INDEL_"$FAM"_"$CHILD"_"$MOM"_"$DAD".imendel" | sort -k 2) \
>| $CORE_PATH/$PROJECT/MENDEL_CHECK/TEMP/"INDEL_"$FAM"_"$CHILD"_"$MOM"_"$DAD".sorted.imendel"

# join the two files together to calculate the mendel error rate for SNVs

awk 'BEGIN {print "FID","IID","RELATION","GENDER"} $3!="0"&&$4!="0"&&$5=="1" {print $1,$2,"CHILD","M"} $3!="0"&&$4!="0"&&$5=="2" {print $1,$2,"CHILD","F"} \
$3=="0"&&$4=="0"&&$5=="1" {print $1,$2,"DAD","M"} $3=="0"&&$4=="0"&&$5=="2" {print $1,$2,"MOM","F"}' $CORE_PATH/$PROJECT/MENDEL_CHECK/TEMP/"SNV_"$FAM"_"$CHILD"_"$MOM"_"$DAD".temp.sorted.ped" \
| join -j 2 -o 1.1 0 1.3 1.4 2.4 2.5 2.6 - $CORE_PATH/$PROJECT/MENDEL_CHECK/TEMP/"SNV_"$FAM"_"$CHILD"_"$MOM"_"$DAD".sorted.imiss" \
| join -j 2 -o 1.1 0 1.3 1.4 1.5 1.6 1.7 2.3 - $CORE_PATH/$PROJECT/MENDEL_CHECK/TEMP/"SNV_"$FAM"_"$CHILD"_"$MOM"_"$DAD".sorted.imendel" \
| awk 'BEGIN {print "TYPE","FID","IID","RELATION","GENDER","N_MISS","N_GENO","F_MISS","N_M_ERROR","F_M_ERROR"} NR>1 {print "SNV",$1,$2,$3,$4,$5,$6,$7,$8,($8/$6)}' \
| sed 's/ /\t/g' \
>| $CORE_PATH/$PROJECT/MENDEL_CHECK/TEMP/"SNV_PASS_"$FAM"_"$CHILD"_"$MOM"_"$DAD".missing.mendel_error.txt"

# join the two files together to calculate the mendel error rate for INDELs

awk 'BEGIN {print "FID","IID","RELATION","GENDER"} $3!="0"&&$4!="0"&&$5=="1" {print $1,$2,"CHILD","M"} $3!="0"&&$4!="0"&&$5=="2" {print $1,$2,"CHILD","F"} \
$3=="0"&&$4=="0"&&$5=="1" {print $1,$2,"DAD","M"} $3=="0"&&$4=="0"&&$5=="2" {print $1,$2,"MOM","F"}' $CORE_PATH/$PROJECT/MENDEL_CHECK/TEMP/"SNV_"$FAM"_"$CHILD"_"$MOM"_"$DAD".temp.sorted.ped" \
| join -j 2 -o 1.1 0 1.3 1.4 2.4 2.5 2.6 - $CORE_PATH/$PROJECT/MENDEL_CHECK/TEMP/"INDEL_"$FAM"_"$CHILD"_"$MOM"_"$DAD".sorted.imiss" \
| join -j 2 -o 1.1 0 1.3 1.4 1.5 1.6 1.7 2.3 - $CORE_PATH/$PROJECT/MENDEL_CHECK/TEMP/"INDEL_"$FAM"_"$CHILD"_"$MOM"_"$DAD".sorted.imendel" \
| awk 'BEGIN {print "TYPE","FID","IID","RELATION","GENDER","N_MISS","N_GENO","F_MISS","N_M_ERROR","F_M_ERROR"} NR>1 {print "INDEL",$1,$2,$3,$4,$5,$6,$7,$8,($8/$6)}' \
| sed 's/ /\t/g' \
>| $CORE_PATH/$PROJECT/MENDEL_CHECK/TEMP/"INDEL_PASS_"$FAM"_"$CHILD"_"$MOM"_"$DAD".missing.mendel_error.txt"

# Cat the two files together

(cat $CORE_PATH/$PROJECT/MENDEL_CHECK/TEMP/"SNV_PASS_"$FAM"_"$CHILD"_"$MOM"_"$DAD".missing.mendel_error.txt" ; \
awk 'NR>1' $CORE_PATH/$PROJECT/MENDEL_CHECK/TEMP/"INDEL_PASS_"$FAM"_"$CHILD"_"$MOM"_"$DAD".missing.mendel_error.txt") \
>| $CORE_PATH/$PROJECT/MENDEL_CHECK/"PASS_"$FAM"_"$CHILD"_"$MOM"_"$DAD".missing.mendel_error.txt"

# join the two files together to calculate the mendel error rate
# Can't remember why I have this section commented out at the moment, but it looks like something I was using for testing.

# join -j 2 -o 1.1 0 2.4 2.5 2.6 1.3 $CORE_PATH/$PROJECT/MENDEL_CHECK/TEMP/"SNV_"$FAM"_"$CHILD"_"$MOM"_"$DAD".imendel" $CORE_PATH/$PROJECT/MENDEL_CHECK/TEMP/"SNV_"$FAM"_"$CHILD"_"$MOM"_"$DAD".imiss" \
# | awk 'BEGIN {print "TYPE","FID","IID","N_MISS","N_GENO","F_MISS","N_M_ERROR","F_M_ERROR"} NR>1 {print "SNV",$1,$2,$3,$4,$5,$6,($6/$4)}' \
# | sed 's/ /\t/g' \
# >| $CORE_PATH/$PROJECT/MENDEL_CHECK/"SNV_PASS_"$FAM"_"$CHILD"_"$MOM"_"$DAD".missing.mendel_error.txt"
