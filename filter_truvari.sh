#!/bin/bash
#updatedate:2021-03-15

function usage(){
echo """
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
"""
}

if [[ $# == 0 ]] ; then
usage
exit 1
fi

##paras
loc=`dirname $0`
src=${loc}/src/
bamfile=
vcffile=
threshold1="65"
threshold2="300"
threshold3="10"
perc="70"
prefix="out"
truvari_step="N"
ref=
tru_sv=
tru_region=

while [[ $# > 0 ]]
do
  case $1 in
  "-h")
  usage
  exit 0
  ;;
  "-vcf")
  vcffile=$2
  shift
  ;;
  "-bam")
  bamfile=$2
  shift
  ;;
  "-threshold1")
  threshold1=$2
  shift
  ;;
  "-threshold2")
  threshold2=$2
  shift
  ;;
  "-threshold3")
  threshold3=$2
  shift
  ;;
  "-perc")
  perc=$2
  shift
  ;;
  "-prefix")
  prefix=$2
  shift
  ;;
  "-truvari")
  if [[ $2 == "Y" ]] ; then
  truvari_step="Y"
  fi
  shift
  ;;
  "-ref")
  ref=$2
  shift
  ;;
  "-tru_sv")
  tru_sv=$2
  shift
  ;;
  "-tru_region")
  tru_region=$2
  shift
  ;;
  esac
  shift
done

function check_bam_file_exist(){
bamfile=$1
if [[ ! -e ${bamfile} ]] ; then
echo "BAM FILE : [${bamfile}] is not exist !"
usage
exit 1 
fi
}

function check_vcf_file_exist(){
vcffile=$1
if [[ ! -e ${vcffile} ]] ; then
echo "VCF FILE : [${vcffile}] is not exist !"
usage
exit 1
fi
}

##check file
check_bam_file_exist ${bamfile}
check_vcf_file_exist ${vcffile}

echo "CMD :$0 $*"

echo "Starting..."

echo "
source ${loc}/config.sh
"
source ${loc}/config.sh

##get chromosome info
echo "
samtools view -H ${bamfile}
"
samtools view -H ${bamfile} >samheader

echo "
java -jar ${src}/chromosome_info_extract.jar samheader
"
java -jar ${src}/chromosome_info_extract.jar samheader >chromosome_info.sh

chmod u+x chromosome_info.sh

echo "
source chromosome_info.sh
"
source chromosome_info.sh

##########mainsrcipt############
awk '
{
split($1,a1,"");
if(a1[1] == "#"){
print $0
}
}
' ${vcffile}>vcfheader

##SV type classification
awk '
{
split($1,a1,"");
if(a1[1] != "#"){
print $0
}
}
' ${vcffile} | awk '/DEL/{print $0}' >${prefix}.del.vcf

awk '
{
split($1,a1,"");
if(a1[1] != "#"){
print $0
}
}
' ${vcffile} | awk '/INS/{print $0}' >${prefix}.ins.vcf

##vcf2bed(del-vcf only)
awk '
{
if(length($4)>50&&length($5)==1) {
    printf("%s\t%s\t%s\t%s\n",$1,$2,$2+length($4),$3);
   } 
}
' ${prefix}.del.vcf >${prefix}.del.bed

##del-filter
echo "
processing deletion...
"
function del_filter(){

bamfile=$1
bedfile=$2
prefix=$3
index=$4
threshold1=$5
threshold2=$6

while read line
do
  arr=(${line//\t/})
  ch_id=${arr[0]}
  _start=${arr[1]}
  _end=${arr[2]}
  sv_id=${arr[3]}
  len=$[${_end}-${_start}]
  _start_upstream=$[${_start}-${len}*${perc}/100]
  _end_downstream=$[${_end}+${len}*${perc}/100]
  if [[ ${_start_unstream} -lt 0 ]] ;then
      _start_upstream=1
  fi
  if [[ ${_end_downstream} -gt ${chr_len[${ch_id}]} && ${chr_len[${ch_id}]} != 0 ]] ;then
      _end_downstream=${chr_len[${ch_id}]}
  fi
  echo "
  samtools depth -a -r ${ch_id}:${_start_upstream}-${_end_downstream} ${bamfile}
  " >> ${index}.process_log
  samtools depth -a -r ${ch_id}:${_start_upstream}-${_end_downstream} ${bamfile} >${index}.${prefix}.cov
  echo "
  java -jar ${src}/region_depth_avg.jar ${index}.${prefix}.cov ${ch_id} ${_start} ${_end} ${_start_upstream} ${_end_downstream} ${sv_id} ${threshold1} ${threshold2}
  " >> ${index}.process_log
  java -jar ${src}/region_depth_avg.jar ${index}.${prefix}.cov ${ch_id} ${_start} ${_end} ${_start_upstream} ${_end_downstream} ${sv_id} ${threshold1} ${threshold2} >>${index}.${prefix}.del.filtered.bed
done <${bedfile}

rm ${index}.${prefix}.cov
}

##pipeline optimize
sv_num=`wc -l ${prefix}.del.bed | awk '{print $1}'`
split_num=$[sv_num / 2000 + 1]

for (( a = 1 ; a <= split_num ; a++ )){
awk '
{
if(NR>2000*($a-1) && NR<=2000*$a){
print $0
}
}
' ${prefix}.del.bed >${a}.${prefix}.del.bed
}

for (( a = 1 ; a <= split_num ; a++ )){
del_filter ${bamfile} ${a}.${prefix}.del.bed ${prefix} ${a} ${threshold1} ${threshold2} &
}
wait

cat *.${prefix}.del.filtered.bed >${prefix}.del.filtered.bed

echo "deletion SVs filtering finished..."

##ins-filter
echo "
processing insertion...
"

echo "
awk -f ${src}/ins_filter.script.awk T=${threshold3} ${prefix}.ins.vcf
"
awk -f ${src}/ins_filter.script.awk T=${threshold3} ${prefix}.ins.vcf >${prefix}.ins.filtered.txt

##extract SVs from ori vcffile(del only)
echo "
java -jar ${src}/extract.jar ${prefix}.del.filtered.bed ${vcffile}
"
java -jar ${src}/extract.jar ${prefix}.del.filtered.bed ${vcffile} >${prefix}.del.filtered.vcf

##(ins only)
cat vcfheader ${prefix}.ins.filtered.txt >${prefix}.ins.filtered.vcf

##truvari step
if [[ ${truvari_step} == "Y" ]] ; then
echo "
bgzip ${prefix}.del.filtered.vcf
"
bgzip ${prefix}.del.filtered.vcf

echo "
bgzip ${prefix}.ins.filtered.vcf
"
bgzip ${prefix}.ins.filtered.vcf

echo "
tabix -p vcf ${prefix}.del.filtered.vcf.gz
"
tabix -p vcf ${prefix}.del.filtered.vcf.gz

echo "
tabix -p vcf ${prefix}.ins.filtered.vcf.gz
"
tabix -p vcf ${prefix}.ins.filtered.vcf.gz

echo "
bash ${loc}/truvari.sh ${prefix}.del.filtered.vcf.gz ${ref} ${tru_sv} ${tru_region} ${prefix}.del.truvari.out
"
bash ${loc}/truvari.sh ${prefix}.del.filtered.vcf.gz ${ref} ${tru_sv} ${tru_region} ${prefix}.del.truvari.out 2>>truvari_log

echo "
bash ${loc}/truvari.sh ${prefix}.ins.filtered.vcf.gz ${ref} ${tru_sv} ${tru_region} ${prefix}.ins.truvari.out
"
bash ${loc}/truvari.sh ${prefix}.ins.filtered.vcf.gz ${ref} ${tru_sv} ${tru_region} ${prefix}.ins.truvari.out 2>>truvari_log
fi

rm vcfheader
rm samheader

echo "Done!"
