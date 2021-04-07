# HAST-SV-FILTER

## Introduction

Filter the VCF file called from HAST assembly to reduce the false-positive SVs.

## Dependence
1.JDK  
2.bgzip  
3.tabix  
4.samtools(ver1.9)  

Modify config.sh before runnning this pipeline.

## Installation

```
cd src && make 
```

## Usage 
```
Usage	:
	./filter.sh [options] -bam <bamfile> -vcf <vcffile> -prefix <prefix>
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
