#!/bin/bash -x
set -euo pipefail
#working the nudup to get the log file for the PCR duplication rates
#Default is 8 bases, the script obtains it from the readname
bam=$(readlink -e $1)
paired=$2
pairopt=""
if (( $paired == 1 )); then
    pairopt="-2"
fi

SID=$(basename $(dirname $bam))
set +e #head has a problem with this
len=$(samtools view $bam |head -1 |awk '{umi=gensub("^.*:","",1,$1); print length(umi)}')
set -e

cd star_align/$SID

tmpdir=../../tmpdir #this may avoid the nudup.py named pipe problems
mkdir -p $tmpdir
python2 $MOTRPAC_root/nugen/nudup.py $pairopt -s $len -l $len --rmdup-only -o $SID -T $tmpdir $bam

#remove these files
rm $SID.sorted.dedup.bam
