# MoTrPAC differential intron excision pipeline

## 1. Install dependencies  

### 1.1 Install a new conda module  
This does not apply to the BIC. The BIC should be able to use the same environment and software versions used for the MoTrPAC RNA-seq pipeline, but I'm leaving this here for reference.  

Follow [these instructions](https://conda.io/projects/conda/en/latest/user-guide/install/linux.html) to install `miniconda/3` if it is not already on your system. Then create a new environment as follows. Only do this once.  
```bash
conda activate
conda create -n my_leafcutter \
	python=3.6.6 \
    snakemake=5.23.0 \
    star=2.7.0d \
    cutadapt=1.18 \
    samtools=1.3.1 
```

### 1.2. Download `leafcutter`
Download the `leafcutter` code from GitHub.  
```bash
git clone https://github.com/davidaknowles/leafcutter
```
Remove the last line in `scripts/bam2junc.sh` which sometimes triggers an error in Snakemake (probably due to file latency issues). **Only run this line once.** Alternatively, manually comment out the last line.  
```bash
# remove the last line of scripts/bam2junc.sh, which is "rm $bedfile"
sed -i '$d' scripts/bam2junc.sh 
```

## 2. Prepare `config` files 
See the example `config/gastrocnemius.config`. Config files are in JSON format, and the following variables must be defined:  
- `"base"`: Root directory for outputs of this pipeline. Should be tissue-specific, i.e. the outputs for each tissue should be in separate folders.  
- `"leafcutter_src"`: Path to the `leafcutter` code downloaded in step 1.2, e.g. `/path/to/leafcutter`.  
- `"tissue"`: Tissue string. For each of downstream processing, this string should match values in the `pass1bf0521`/`Specimen.Processing.sampletypedescription` column in the PASS1B-06 phenotypic data with the following modifications: all characters should be lowercase, and spaces should be replaced with `_`, i.e.:
  ```
	adrenals
	aorta
	brown_adipose
	colon
	cortex
	gastrocnemius
	heart
	hippocampus
	hypothalamus
	kidney
	liver
	lung
	ovaries
	paxgene_rna
	small_intestine
	spleen
	testes
	vastus_lateralis
	white_adipose
  ```
- `"fastq_dir"`: Path to a directory with raw FASTQ files **just for this tissue**, e.g. `/path/to/fastq_raw/gastrocnemius`. The BIC can modify this code to skip the `cudadapt` trimming step and instead input the path to the trimmed FASTQ files for this tissue.  
- `"sj_tab_dir"`: Path to a directory with `*SJ.tab.out` files **just for this tissue**. It is not necessary or ideal to use the `*SJ.tab.out` files from other tissues since other tissues will express different genes and detect junctions that are not relevant for the tissue of interest.  
- `"genome_index"`: Path to the rn6 STAR index already used in the MoTrPAC RNA-seq pipeline, e.g. `path/to/to/rn6_ensembl_r96/star_index`.  

## 3. Run the pipeline  
Note that if you do not first make a `log/cluster` subdirectory in your specified `outdir`, as shown in the code below, SLURM will throw an error when you start the Snakemake pipeline because it will not be able to find the path in which to write the SLURM log file. 
```bash
# start a screen session
# load the environment
conda activate my_leafcutter 
# submit snakemake via sbatch 
base=/projects/motrpac/PASS1B/RNA/NOVASEQ_BATCH1/differential_splicing
tissue=gastrocnemius
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
```

## 4. Main output files
There are two important output files for each tissue:
- `intron_cluster/{tissue}_perind.counts.gz`
- `intron_cluster/{tissue}_perind_numers.counts.gz`
These files should be included in future data releases for people to be able to perform differential intron excision analysis following the rest of the [`leafcutter` vignette](https://davidaknowles.github.io/leafcutter/articles/Usage.html#step-3--differential-intron-excision-analysis).
