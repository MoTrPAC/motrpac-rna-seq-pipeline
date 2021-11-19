import glob
import pandas as pd
from functools import reduce


# Usage : python merge_rsem.py

# file_list = glob.glob('mnt_araja/PASS1A/Stanford/batch1/set1/rnaseq_pipeline/*/call-rsem_quant/shard*/rsem_reference/*.genes.results')

# file_list=['mnt_araja/PASS1A/Stanford/batch1/set1/rnaseq_pipeline/b18e9045-9433-4e8f-8b71-17cc82dda6e5/call-rsem_quant/shard-0/rsem_reference/80000885526.genes.results', 'mnt_araja/PASS1A/Stanford/batch1/set1/rnaseq_pipeline/b18e9045-9433-4e8f-8b71-17cc82dda6e5/call-rsem_quant/shard-1/rsem_reference/80001995526.genes.results']

file_list = glob.glob('rsem_results/*.genes.results')

# gene_ids , expected_counts
cols_counts = [0, 4]  # add more columns here
cols_tpm = [0, 5]
cols_fpkm = [0, 6]
count_l = []
fpkm_l = []
tpm_l = []
vial_label = []
sample_list = []

for f in file_list:
    df = pd.read_csv(f, header=0, sep="\t", usecols=cols_counts)
    df_tpm = pd.read_csv(f, header=0, sep="\t", usecols=cols_tpm)
    df_fpkm = pd.read_csv(f, header=0, sep="\t", usecols=cols_fpkm)
    vial_label = f.split("/")[1].split(".")[0]
    #    print (df.columns)
    #    print (df_tpm.columns)
    #    print (df_fpkm.columns)
    df.rename(columns={'expected_count': vial_label}, inplace=True)
    df_tpm.rename(columns={'TPM': vial_label}, inplace=True)
    df_fpkm.rename(columns={'FPKM': vial_label}, inplace=True)
    if not vial_label in sample_list:
        count_l.append(df)
        tpm_l.append(df_tpm)
        fpkm_l.append(df_fpkm)
        sample_list.append(vial_label)

# print (count_l)
df_final = reduce(lambda x, y: pd.merge(x, y, on='gene_id', how='outer'), count_l)
# print (df_final)
df_final = df_final.astype(str)

df_final.to_csv("rsem_genes_count.txt", index=False, sep="\t")

df_final = reduce(lambda x, y: pd.merge(x, y, on='gene_id', how='outer'), tpm_l)
df_final = df_final.astype(str)
df_final.to_csv("rsem_genes_tpm.txt", index=False, sep="\t")

df_final = reduce(lambda x, y: pd.merge(x, y, on='gene_id', how='outer'), fpkm_l)
df_final = df_final.astype(str)
df_final.to_csv("rsem_genes_fpkm.txt", index=False, sep="\t")
