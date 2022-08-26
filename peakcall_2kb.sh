#!/bin/bash

##need sorted _long.bam and _short.bam from bamsplit

bampre=$1
long=${bampre}*_long.bam
short=${bampre}*_short.bam

pathfg=~/hg38_2kbp_100bp.bed     #a 2kbp window with 100bp sliding size for hg38 generated by bedtools
pathbg=~/hg38_50kbp_100bp.bed    #a 50kbp window with 100bp sliding size for hg38 generated by bedtools
ref=~/hg38_100bp.bed             #a 100bo window with 100bp sliding size for hg38 generated by bedtools
blacklist=~/hg38.blacklist.bed   #unzipped and sorted https://github.com/Boyle-Lab/Blacklist/blob/master/lists/hg38-blacklist.v2.bed.gz

bedtools intersect -sorted -C -a $pathfg -b $long | awk 'BEGIN{OFS="\t"}{a=int(($2+$3)/2/100)*100}($3>=a+100){print $1,a,a+100,$4}' |sort -k1,1 -k2,2n > ${bampre}_lfg2k
bedtools intersect -sorted -C -a $pathfg -b $short | awk 'BEGIN{OFS="\t"}{a=int(($2+$3)/2/100)*100}($3>=a+100){print $1,a,a+100,$4}' |sort -k1,1 -k2,2n > ${bampre}_sfg
bedtools intersect -sorted -C -a $pathbg -b $long | awk 'BEGIN{OFS="\t"}{a=int(($2+$3)/2/100)*100}($3>=a+100){print $1,a,a+100,$4}' |sort -k1,1 -k2,2n > ${bampre}_lbg2k
bedtools intersect -sorted -C -a $pathbg -b $short | awk 'BEGIN{OFS="\t"}{a=int(($2+$3)/2/100)*100}($3>=a+100){print $1,a,a+100,$4}' |sort -k1,1 -k2,2n > ${bampre}_sbg


#chr,pos,pos,lfg,lbg,sfg,sbg,expected
cat $ref |bedtools map -c 4 -a - -b  ${bampre}_lfg2k_fs | \
bedtools map -c 4 -a - -b ${bampre}_lbg2k_fs | bedtools map -c 4 -a - -b ${bampre}_sfg_fs | bedtools map -c 4 -a - -b ${bampre}_sbg_fs  | \
awk '!/\./' | awk 'BEGIN{OFS="\t"}{print $0,($6+1)/($7+1)*$5}' |bedtools intersect -sorted -v -a - -b $blacklist > ${bampre}_mapped


awk 'BEGIN{OFS="\t"}{print $1,$2,$3,$4}' ${bampre}_mapped > ${bampre}_treated2k
awk 'BEGIN{OFS="\t"}{print $1,$2,$3,$8}' ${bampre}_mapped > ${bampre}_expected2k

macs2 bdgcmp -t ${bampre}_treated2k -c ${bampre}_expected2k -p 1 -m logFE --o-prefix ${bampre}_2k
macs2 bdgcmp -t ${bampre}_treated2k -c ${bampre}_expected2k -m ppois --o-prefix ${bampre}_2k
macs2 bdgcmp -t ${bampre}_treated2k -c ${bampre}_expected2k -m qpois --o-prefix ${bampre}_2k

