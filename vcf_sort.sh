#!/bin/bash

function usage(){
echo """
usage:
	./vcf_sort.sh [vcffile]	
"""
}

vcffile=$1

awk '
{
split($1,a1,"");
if(a1[1] == "#"){
print $0
}
}
' ${vcffile} >vcfheader


awk '
{
split($1,a1,"");
if(a1[1] != "#"){
print $0
}
}
' ${vcffile} >vcf.txt

sort -k1,1 -k2,2n vcf.txt >vcf.sorted.txt

cat vcfheader vcf.sorted.txt > sorted.${vcffile}

rm vcfheader
rm vcf.txt
rm vcf.sorted.txt
