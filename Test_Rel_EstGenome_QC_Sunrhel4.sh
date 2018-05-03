#!/bin/csh

/isilon/home/hling/Seq_Programs/PRIMUS_v1.8.0/bin/run_PRIMUS.pl  \
	--file /isilon/sequencing/Seq_Proj/Foroud_Landers_PD_SeqWholeExome_121914_1/Working_HL/PRIMUS/Input/baseGT_bin.QC --genome \
	--degree_rel_cutoff 2 --verbose 2 --plink_ex /isilon/sequencing/Kurt/Programs/PATH/plink2 --smartpca_ex /isilon/home/hling/Seq_Programs/EIG6.0.1/bin/smartpca \
	-o /isilon/sequencing/Seq_Proj/Foroud_Landers_PD_SeqWholeExome_121914_1/Working_HL/PRIMUS/Output/EstGenome_QC_Sunrhel4
	
