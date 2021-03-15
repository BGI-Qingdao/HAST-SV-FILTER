#!/bin/bash

usage(){
echo "./truvari.sh <filter_calls> <ref.fa> <truth_sv.vcf.gz> <truth_regions> <outputdir>"
}

if [[ $# -le 4  ]]
then
usage
exit 1
fi

filter_calls=$1
ref=$2
tru_sv=$3
tru_regions=$4
out_dir=$5

echo "
truvari bench -f ${ref} -b ${tru_sv} --includebed ${tru_regions} -o ${out_dir} --passonly -r 1000 -p 0 -c ${filter_calls} 
"
truvari bench -f ${ref} -b ${tru_sv} --includebed ${tru_regions} -o ${out_dir} --passonly -r 1000 -p 0 -c ${filter_calls} 
