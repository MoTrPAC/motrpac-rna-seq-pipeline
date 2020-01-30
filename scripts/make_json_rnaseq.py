import os, sys, argparse, json

def main(filelist, output_path):
    for i in filelist:
      print(i)
      f=open(os.path.join(output_path, i+"_rnaseq.json"),"w")
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
          "rnaseq_pipeline.star_align.star_index" : "gs://rna-seq_araja/references/rn/v96/star_2.7.0d_04-20-19/sorted/Rnor6_v96_star_index.tar.gz",\
          "rnaseq_pipeline.rsem_quant.rsem_reference" : "gs://rna-seq_araja/references/rn/v96/rsem/sorted/rn6_rsem_reference.tar.gz",\
          "rnaseq_pipeline.rnaqc.ref_flat" : "gs://rna-seq_araja/references/rn/v96/sorted/refFlat_rn6_v96.txt",\
          "rnaseq_pipeline.featurecounts.gtf_file" : "gs://rna-seq_araja/references/rn/v96/sorted/Rattus_norvegicus.Rnor_6.0.96.gtf",\
          "rnaseq_pipeline.bowtie2_globin.genome_dir" : "rn_globin",\
          "rnaseq_pipeline.bowtie2_globin.genome_dir_tar": "gs://rna-seq_araja/references/rn/bowtie2_index/rn_globin.tar.gz",\
          "rnaseq_pipeline.bowtie2_rrna.genome_dir" : "rn_rRNA",\
          "rnaseq_pipeline.bowtie2_rrna.genome_dir_tar": "gs://rna-seq_araja/references/rn/bowtie2_index/rn_rRNA.tar.gz",\
          "rnaseq_pipeline.bowtie2_phix.genome_dir" : "phix",\
          "rnaseq_pipeline.bowtie2_phix.genome_dir_tar": "gs://rna-seq_araja/references/rn/bowtie2_index/phix.tar.gz",\
          "rnaseq_pipeline.script": "gs://rna-seq_araja/scripts/rnaseq_qc.py",\
          "rnaseq_pipeline.num_threads" : "4",\
          "rnaseq_pipeline.num_preempt" : "0",\
          "rnaseq_pipeline.memory" : "16000",\
          "rnaseq_pipeline.cpus" : "4",\
          "rnaseq_pipeline.docker" : "gcr.io/motrpac-portal/motrpac_rnaseq:v0.1_04_20_19",\
          "rnaseq_pipeline.disk_space" : "100"}
      json.dump(d, f)
      f.close()

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description = 'This script is used to generate input json files from filelists for running rna-seq pipeline on GCP')
    parser.add_argument('filelist', help='comma separated list of files to generate input_json(full path of the file containing only *_R1.fastq.gz)', type=str)
    parser.add_argument('output_path', help='output path', type=str)
    args = parser.parse_args()

    filelist = args.filelist.split(',')

    main(filelist, args.output_path)
