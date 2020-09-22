#!/bin/bash 
set -eux -o pipefail

base=$1
tissue=$2

mkdir -p ${base}/${tissue}/log/cluster

snakemake -j 999 --snakefile Snakefile \
					--cluster-config ds.slurm \
					--latency-wait 90 \
					--configfile config/${tissue}.config \
					--cluster \
					"sbatch --account={cluster.account} \
						--time={cluster.time} \
						--mem={cluster.mem} \
						--cpus-per-task={cluster.nCPUs} \
						--output={cluster.output} \
						--mail-type={cluster.mail}"
