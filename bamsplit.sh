#!/bin/bash

##need bam for $1, and unzipped pairs for $2

bam=$1
pairs=$2
out_short=`echo $bam|sed 's/.bam/_short/g'`
out_long=`echo $bam|sed 's/.bam/_long/g'`

samtools view -h $bam > ${bam}.sam
awk -v short=$out_short -v long=$out_long 'BEGIN{OFS="\t"}/^#/{next}(NR==FNR){if($9<30||$10<30){next}if($2!=$4){next}if($5-$3<=1000&&$6=="+"&&$7=="-"){a[$1]++;next}if($5-$3>=1500){b[$1]++;next}}/^@/{print $0 > short; print $0 > long ;next}{$2+=2}($1 in a){print $0 > short}($1 in b){print $0 > long}' $pairs ${bam}.sam 

samtools sort -m 6G -@ 16 -O bam $out_short > ${out_short}_1.bam
samtools sort -m 6G -@ 16 -O bam  $out_long > ${out_long}_1.bam
gatk --java-options "-Xmx64G" AddOrReplaceReadGroups -I ${out_short}_1.bam  -O ${out_short}.bam --RGID 4 --RGLB lib1 --RGPL Illumina --RGPU unit1 --RGSM 20
gatk --java-options "-Xmx64G" AddOrReplaceReadGroups -I ${out_long}_1.bam  -O ${out_long}.bam --RGID 4 --RGLB lib1 --RGPL Illumina --RGPU unit1 --RGSM 20
rm ${out_short}
rm ${out_long}
rm ${out_short}_1.bam
rm ${out_long}_1.bam
rm ${bam}.sam



