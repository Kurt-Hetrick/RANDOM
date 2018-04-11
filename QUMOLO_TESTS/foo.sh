awk 'BEGIN {FS=",";OFS=","} {print "QUMOLO",$0,($6-$5)/60}' /drives/x/Seq_Proj/Hu_EnamelDefects_SeqWholeExome_020615_3/REPORTS/Hu_EnamelDefects_SeqWholeExome_020615_3.WALL.CLOCK.TIMES.fixed.csv \
>> /drives/z/Seq_Proj/Hu_EnamelDefects_SeqWholeExome_020615_3_TEST/REPORTS/Hu_EnamelDefects_SeqWholeExome_020615_3_TEST.WALL.CLOCK.TIMES.fixed.csv
