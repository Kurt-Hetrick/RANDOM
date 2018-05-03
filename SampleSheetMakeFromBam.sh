BAM_PATH=$1

module load samtools


ls $BAM_PATH/*bam \
| awk '{print "samtools view -H",$1,"| grep ^@RG"}' \
| bash \
| sed 's/:/\t/g' \
| awk 'BEGIN {OFS=","} {split($7,foo,"_"); split($13,bar,"T"); split(bar[1],foobar,"-"); print "Haiman_ProstateCa_SeqWholeExome_080814_1_KURT",foo[1],foo[2],foo[3],$5,$9,foobar[3]"/"foobar[2]"/"foobar[1],$17,$19,$11,"do_not_care","/mnt/research/tools/PIPELINE_FILES/bwa_mem_0.7.5a_ref/human_g1k_v37_decoy.fasta","knh","-2","/mnt/research/active/Haiman_ProstateCa_SeqWholeExome_080814_1_KURT/BED_Files/TS_TV_BED_Files_AgilentV6plusUTR_S07604624_merged_noCHR_170825.bed","/mnt/research/active/Haiman_ProstateCa_SeqWholeExome_080814_1_KURT/BED_Files/Baits_BED_Files_AgilentV6plusUTR_S07604624_merged_noCHR_170825.bed","/mnt/research/active/Haiman_ProstateCa_SeqWholeExome_080814_1_KURT/BED_Files/Targets_BED_Files_AgilentV6plusUTR_S07604624_merged_noCHR_170825.bed","/mnt/research/tools/PIPELINE_FILES/GATK_resource_bundle/2.8/b37/dbsnp_138.b37.vcf","/mnt/research/tools/PIPELINE_FILES/GATK_resource_bundle/2.8/b37/1000G_phase1.indels.b37.vcf;/mnt/research/tools/PIPELINE_FILES/GATK_resource_bundle/2.8/b37/Mills_and_1000G_gold_standard.indels.b37.vcf"}' \
| awk 'BEGIN {print "Project,FCID,Lane,Index,Platform,Library_Name,Date,SM_Tag,Center,Description,Seq_Exp_ID,Genome_Ref,Operator,Extra_VCF_Filter_Params,TS_TV_BED_File,Baits_BED_File,Targets_BED_File,KNOWN_SITES_VCF,KNOWN_INDEL_FILES"} \
{print $0}' \
> /mnt/research/active/Haiman_ProstateCa_SeqWholeExome_080814_1_KURT/Haiman_SampleSheet_22Dec2017.csv
