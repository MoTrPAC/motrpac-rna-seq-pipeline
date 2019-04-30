import simplejson
filelist=["sinai_batch1aa","sinai_batch1ab","sinai_batch1ac","sinai_batch1ad"]
for i in filelist:
  f=open(i+"_rnaseq.json","w")
  r1 = [line.strip("\n") for line in open(i)]
  r2 = [line.strip("\n").replace("_R1.fastq","_R2.fastq") for line in open(i)]
  i1 = [line.strip("\n").replace("_R1.fastq","_I1.fastq") for line in open(i)]
  prefix = [line.strip("\n").split("/")[-1].split("_R1.fastq.gz")[0] for line in open(i)]
  d = {"rnaseq_pipeline.fastq1": r1 ,\
  "rnaseq_pipeline.fastq2" : r2 ,\
  "rnaseq_pipeline.fastq_index": i1,\
  "rnaseq_pipeline.sample_prefix" : prefix ,\
  "rnaseq_pipeline.preTrimFastQC.outdir" : "fastqc_raw",\
  "rnaseq_pipeline.index_adapter" : "AGATCGGAAGAGC",\
  "rnaseq_pipeline.univ_adapter" : "AGATCGGAAGAGC",\
  "rnaseq_pipeline.minimumLength" : "20",\
  "rnaseq_pipeline.postTrimFastQC.outdir" : "fastqc_trim",\
  "rnaseq_pipeline.star_align.star_index" : "gs://***REMOVED***/references/rn/v96/star_2.7.0d_04-20-19/sorted/Rnor6_v96_star_index.tar.gz",\
  "rnaseq_pipeline.rsem_quant.rsem_reference" : "gs://***REMOVED***/references/rn/v96/rsem/sorted/rn6_rsem_reference.tar.gz",\
  "rnaseq_pipeline.rnaqc.ref_flat" : "gs://***REMOVED***/references/rn/v96/sorted/refFlat_rn6_v96.txt",\
  "rnaseq_pipeline.featurecounts.gtf_file" : "gs://***REMOVED***/references/rn/v96/sorted/Rattus_norvegicus.Rnor_6.0.96.gtf",\
  "rnaseq_pipeline.bowtie2_globin.genome_dir" : "rn_globin",\
  "rnaseq_pipeline.bowtie2_globin.genome_dir_tar": "gs://***REMOVED***/references/rn/bowtie2_index/rn_globin.tar.gz",\
  "rnaseq_pipeline.bowtie2_rrna.genome_dir" : "rn_rRNA",\
  "rnaseq_pipeline.bowtie2_rrna.genome_dir_tar": "gs://***REMOVED***/references/rn/bowtie2_index/rn_rRNA.tar.gz",\
  "rnaseq_pipeline.bowtie2_phix.genome_dir" : "phix",\
  "rnaseq_pipeline.bowtie2_phix.genome_dir_tar": "gs://***REMOVED***/references/rn/bowtie2_index/phix.tar.gz",\
  "rnaseq_pipeline.script": "gs://***REMOVED***/scripts/rnaseq_qc.py",\
  "rnaseq_pipeline.num_threads" : "4",\
  "rnaseq_pipeline.num_preempt" : "0",\
  "rnaseq_pipeline.memory" : "16000",\
  "rnaseq_pipeline.cpus" : "4",\
  "rnaseq_pipeline.docker" : "gcr.io/***REMOVED***/motrpac_rnaseq:v0.1_04_20_19",\
  "rnaseq_pipeline.disk_space" : "100"}

  simplejson.dump(d, f)
  f.close()

#>>> r1="gs://***REMOVED***-transfer-sinai/rna-seq/PASS1A/80000885506_R1.fastq.gz"
#>>> r2=r1.replace("_R1.fastq.gz","_R2.fastq.gz")
#>>> r2
#'gs://***REMOVED***-transfer-sinai/rna-seq/PASS1A/80000885506_R2.fastq.gz'
#>>> i1=r1.replace("_R1.fastq.gz","_I1.fastq.gz")
#>>> i1
#'gs://***REMOVED***-transfer-sinai/rna-seq/PASS1A/80000885506_I1.fastq.gz'
#>>> a='gs://***REMOVED***-transfer-sinai/rna-seq/PASS1A/90028013001_I1.fastq.gz'
#>>> a.split("/")
#['gs:', '', '***REMOVED***-transfer-sinai', 'rna-seq', 'PASS1A', '90028013001_I1.fastq.gz']
#>>> a.split("/")[-1]
#'90028013001_I1.fastq.gz'
#>>> a.split("/")[-1].split("_I1.fastq.gz")[0]
#'90028013001'
#gs://***REMOVED***/references/rn/v96/star_2.7.0d_04-20-19/sorted/Rnor6_v96_star_index.tar.gz
