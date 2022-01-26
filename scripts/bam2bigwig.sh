#!/bin/bash

# convert a single BAM to bigwig format
# usage: bash bam2bigwig.sh /path/to/90251015803.Aligned.sortedByCoord.out /path/to/bigwigs
# this command will generate /path/to/bigwigs/90251015803.bw 
#
# dependencies: samtools, deeptools

bam=$1
outdir=$2

prefix=$(basename "${bam}" | sed "s/\.Aligned.*//")
samtools index "${bam}"
bamCoverage -b "${bam}" -o "${outdir}"/"${prefix}".bw
