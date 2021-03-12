# HAST-SV-FILTER

## Introduction

Filter the VCF file called from HAST assembly to reduce the false-positive SVs.

## Usage 
```
Usage	:
	./filter_truvari.sh [options] -bam <bamfile> -vcf <vcffile> -prefix <prefix>
Options	:
	-threshold1	threshold1[65];
	-threshold2	threshold2[300];
	-threshold3	threshold3[10];
	-prec		precentage[70];
	TRUVARI:
	-truvari	(Y/N)[N]
	-ref		ref.fasta
	-tru_sv		truth_sv.vcf.gz
	-tru_region	truth_sv.bed
  ```
