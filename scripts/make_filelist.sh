#!/bin/bash

gcp_fastq_dir=$1
batch_size=$2
outdir=$3
batch_name=$4

if [  $# -le 3 ]
then
	echo -e "Too few arguments provided, please see the usage below."
	echo -e "\nUsage:\nmake_filelist.sh <gcp_fastq_dir> <outdir_for_split_file_list> <batch_name> <batch_size> \n"
        echo -e "./make_filelist.sh gs://motrpac-portal-transfer-stanford/rna-seq/rat/batch1_20190503/fastq_raw 80 test test_b1"
	exit 1
fi

mkdir -p ${outdir}
gsutil ls ${gcp_fastq_dir}/*_R1.fastq.gz|grep -v "Undetermined"|split -l ${batch_size} - ${outdir}/${batch_name}
echo "All Done"
