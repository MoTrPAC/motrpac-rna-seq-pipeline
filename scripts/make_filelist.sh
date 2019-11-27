#!/bin/bash 

echo -e "\nUsage:\nmake_filelist.sh <gcp_fastq_dir> <outdir_for_split_file_list> <batch_name> <batch_size> \n"
echo -e "./make_filelist.sh gs://***REMOVED***-transfer-stanford/rna-seq/rat/batch1_20190503/fastq_raw 80 test test_b1"
#gcp_fastq_dir="gs://***REMOVED***-transfer-stanford/rna-seq/rat/batch1_20190503/fastq_raw"
#outdir="test"
#batch_name="test_b1"
#batch_size=80

gcp_fastq_dir=$1
batch_size=$2
outdir=$3
batch_name=$4

mkdir -p ${outdir}
#gsutil ls gs://***REMOVED***-transfer-stanford/rna-seq/rat/batch1_20190503/fastq_raw/*_R1.fastq.gz|grep -v "Undetermined"|split -l 80 - test/test_b1
gsutil ls ${gcp_fastq_dir}/*_R1.fastq.gz|grep -v "Undetermined"|split -l ${batch_size} - ${outdir}/${batch_name}
echo "All Done"
