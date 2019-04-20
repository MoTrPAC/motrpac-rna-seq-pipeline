"""
Script to collect rna-seq qc metrics from different summary and report files from the rnaseq pipeline
 
Usage : python rnaseq_qc.py --multiqc_prealign multiQC_prealign_report --multiqc_postalign multiQC_postalign_report 8019468197_summary.txt 8019468197_mapped_report.txt 8019468197_rRNA_report.txt 8019468197_globin_report.txt 8019468197_phix_report.txt 8019468197_umi_report.txt 8019468197.Log.final.out

Author : Archana Raja
"""
import argparse
import pandas as pd
import os
from functools import reduce

parser = argparse.ArgumentParser(description='Script to collect rna-seq qc metrics')
parser.add_argument('--multiqc_prealign',help='path to multiqc prealign directory')
parser.add_argument('--multiqc_postalign',help='path to multiqc postalign directory')
parser.add_argument('cutadapt_report',help='cutadapt report file')
parser.add_argument('mapped_report',help='alignment report')
parser.add_argument('rRNA_report',help='rRNA alignment report')
parser.add_argument('globin_report',help='globin alignment report')
parser.add_argument('phix_report',help='phix alignment report')
parser.add_argument('umi_report',help='UMI duplication report')
parser.add_argument('star_log',help='star log file')
args = parser.parse_args()
dirname="multiQC_prealign_report"
filename="multiqc_data/multiqc_general_stats.txt"
pa_dirname="multiQC_postalign_report"
star_report="multiqc_data/multiqc_star.txt"
mqc_gen_report="multiqc_data/multiqc_general_stats.txt"
rna_metrics_report="multiqc_data/multiqc_picard_RnaSeqMetrics.txt"
print ("Success reading input reports")

mqc_raw=os.path.join(dirname, filename)
mqc_star=os.path.join(pa_dirname,star_report)
mqc_gen=os.path.join(pa_dirname,mqc_gen_report)
mqc_rna_metrics=os.path.join(pa_dirname,rna_metrics_report)
print ("Success creating paths")

#df_raw=pd.read_csv(mqc_raw,sep="\t",index_col=0)
df_raw=pd.read_csv(mqc_raw,sep="\t",header=0)
df_star=pd.read_csv(mqc_star,sep="\t",header=0)
df_pa=pd.read_csv(mqc_gen,sep="\t",header=0)
df_star_log=pd.read_csv(args.star_log,index_col=0,sep="\t")
df_rnametrics=pd.read_csv(mqc_rna_metrics,sep="\t",header=0)
df_cutadapt=pd.read_csv(args.cutadapt_report,sep="\t",header=0)
df_umi=pd.read_csv(args.umi_report,sep="\t",header=0)
df_globin=pd.read_csv(args.globin_report,sep="\t",header=0)
df_globin["pct_globin"]=df_globin["pct_globin"].str.replace("%",'')
df_rRNA=pd.read_csv(args.rRNA_report,sep="\t",header=0)
df_rRNA["pct_rRNA"]=df_rRNA["pct_rRNA"].str.replace("%",'')
df_phix=pd.read_csv(args.phix_report,sep="\t",header=0)
df_phix["pct_phix"]=df_phix["pct_phix"].str.replace("%",'')
df_mapped=pd.read_csv(args.mapped_report,sep="\t",header=0)
print ("Success creating data frames")

#%trimmed_bases
percent_trimmed_bases=df_raw["Cutadapt_mqc-generalstats-cutadapt-percent_trimmed"][0].round(2)

#get mean raw read count
reads_raw=(df_raw["FastQC_mqc-generalstats-fastqc-total_sequences"][1]+df_raw["FastQC_mqc-generalstats-fastqc-total_sequences"][2])/2
sample_name=df_raw["Sample"][0].split("_")[0]

#get read counts after trimming (reads)
reads_trim=(df_raw["FastQC_mqc-generalstats-fastqc-total_sequences"][3]+df_raw["FastQC_mqc-generalstats-fastqc-total_sequences"][4])/2

#get GC content of the trimmed reads (%GC)
gc=(df_raw["FastQC_mqc-generalstats-fastqc-percent_gc"][3]+df_raw["FastQC_mqc-generalstats-fastqc-percent_gc"][4])/2

#%dup_sequence
dup_seq=((df_raw["FastQC_mqc-generalstats-fastqc-percent_duplicates"][3]+df_raw["FastQC_mqc-generalstats-fastqc-percent_duplicates"][4])/2).round(2)

#%trimmed
perc_trimmed=(((reads_raw-reads_trim)/reads_raw)*100).round(2)

#%picard_dup
perc_picard_dup=((df_pa["Picard_mqc-generalstats-picard-PERCENT_DUPLICATION"][0])*100).round(2)

#Star stats
#uniquely_mapped
u_m=df_star["uniquely_mapped"][0]
total_reads=df_star["total_reads"][0]
#%uniquely_mapped
perc_uniquely_mapped=((u_m/total_reads)*100).round(2)

#% chimeric reads
d=df_star_log.to_dict()
perc_chimeric_reads=d[list(d.keys())[0]]["                            % of chimeric reads |"].strip('%')
data1={'Sample':[sample_name], 'pct_trimmed_bases':[percent_trimmed_bases],'reads_raw':[reads_raw],'reads':[reads_trim],'pct_trimmed':[perc_trimmed],'pct_GC':[gc],'pct_dup_sequence':[dup_seq],'pct_picard_dup':[perc_picard_dup],'pct_uniquely_mapped':[perc_uniquely_mapped]}
df1=pd.DataFrame(data1)
df1['Sample']=df1.Sample.astype('str')
print ('df_prealign')
print (df1)
df1.to_csv("df1.txt",sep="\t",index=False)
df1=pd.read_csv("df1.txt",sep="\t",header=0)
df_star=df_star.drop(['insertion_length','deletion_length','deletion_rate','mismatch_rate','multimapped_toomany','unmapped_mismatches','unmapped_other','insertion_rate','multimapped','unmapped_tooshort','total_reads'],axis=1)
print (df_star)

df_rnametrics=df_rnametrics.loc[:,['Sample','PCT_CODING_BASES','PCT_MRNA_BASES','PCT_INTRONIC_BASES','MEDIAN_5PRIME_TO_3PRIME_BIAS','PCT_INTERGENIC_BASES','PCT_UTR_BASES']]
print (df_rnametrics)
dfs=[df1,df_cutadapt,df_star,df_rnametrics,df_mapped,df_umi,df_globin,df_rRNA,df_phix]
df_final = reduce(lambda left,right:pd.merge(left,right,on='Sample'), dfs)
print ("Merging successful")
print (df_final)

df_final=df_final.round(2)
df_final.columns = df_final.columns.str.lower()
name=df_final['sample'][0].astype('str')+"_qc_info.csv"
print (name)
df_final.to_csv(name,sep=",",index=False)
#df_final.to_csv("qc_info.csv",sep=",",index=False)
