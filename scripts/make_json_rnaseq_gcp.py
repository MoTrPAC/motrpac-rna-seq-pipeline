#Usage example : python3 scripts/make_json_rnaseq_gcp.py motrpac-portal-transfer-stanford/rna-seq/rat/batch4_20200106/fastq_raw/*_R1.fastq.gz input_json/test3/
import os, sys, argparse, json
import gcsfs

def main(gcp_path,output_path):
      fs = gcsfs.GCSFileSystem(project='motrpac-portal')
      r1=[]
      r2=[]
      i1=[]
      prefix_list=[]
      counter=0
      batch_num=1
      for i in fs.glob(gcp_path):
#      for i in fs.glob('rna-seq_araja/rna-seq/test_data/subset/*_R1.fastq.gz'):
#        counter=counter+1
        sname=os.path.basename(i).split("_R1.fastq")[0]
        if counter < 80 :
#          sname=os.path.basename(i).split("_R1.fastq")[0]
          r1.append("gs://"+i)
          r2.append("gs://"+i.replace("_R1.fastq","_R2.fastq"))
          i1.append("gs://"+i.replace("_R1.fastq","_I1.fastq"))
          prefix_list.append(sname)
          batch_num=batch_num
          counter=counter+1

        elif counter >= 80 :
          counter=0
          r1.clear()
          r2.clear()
          i1.clear()
          prefix_list.clear()
          r1.append("gs://"+i)
          r2.append("gs://"+i.replace("_R1.fastq","_R2.fastq"))
          i1.append("gs://"+i.replace("_R1.fastq","_I1.fastq"))
          prefix_list.append(sname)
          counter=counter+1
          batch_num=batch_num+1

        f=open(os.path.join(output_path, "set"+str(batch_num)+"_rnaseq.json"),"w")
        json_dict=make_json_dict(r1,r2,i1,prefix_list)
        json.dump(json_dict,f)
        f.close()
      print("Success! Finished generating input jsons")
      
def make_json_dict(r1=[],r2=[],i1=[],prefix_list=[]):
          d = {"rnaseq_pipeline.fastq1": r1 ,\
          "rnaseq_pipeline.fastq2" : r2 ,\
          "rnaseq_pipeline.fastq_index": i1,\
          "rnaseq_pipeline.sample_prefix" : prefix_list,\
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
          return d
      

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description = 'This script is used to generate input json files from the fastq_raw dir on gcp for running rna-seq pipeline on GCP')
    parser.add_argument('gcp_path',help='location on gcp where the raw fastqs resid',type=str) 
    parser.add_argument('output_path', help='output path, where you want the input jsons to be written', type=str)
    args = parser.parse_args()
    main(args.gcp_path,args.output_path)
