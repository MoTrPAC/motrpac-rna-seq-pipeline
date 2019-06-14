import pandas as pd
tpm_stanford=pd.read_csv("rsem_genes_tpm_merged.txt",sep="\t",header=0)
tpm_bic=pd.read_csv("/Users/archanaraja/work/repo/motrpac-rna-seq-pipeline/pass1a_results/Stanford/Nicole/bic/rsem_genes_tpm_pass1a_batch1_Stanford.tab.csv",sep="\t",header=0)
print(tpm_stanford.shape)
#(32883, 487)
print(tpm_bic.shape)
#(32883, 321)
#look at the correlations across columns in two data frames
tpm_bic.corrwith(tpm_stanford, axis = 0).mean()
tpm_bic.corrwith(tpm_stanford, axis = 0).median()
tpm_bic.corrwith(tpm_stanford, axis = 0)
counts_stanford=pd.read_csv("rsem_genes_count_merged.txt",sep="\t",header=0)
counts_bic=pd.read_csv("/Users/archanaraja/work/repo/motrpac-rna-seq-pipeline/pass1a_results/Stanford/Nicole/bic/rsem_genes_count_pass1a_batch1_Stanford.tab.csv",sep="\t",header=0)
counts_bic.corrwith(counts_stanford, axis = 0).mean()
counts_bic.corrwith(counts_stanford, axis = 0)
fpkm_stanford=pd.read_csv("rsem_genes_fpkm_merged.txt",sep="\t",header=0)
fpkm_bic.corrwith(fpkm_stanford, axis = 0)



