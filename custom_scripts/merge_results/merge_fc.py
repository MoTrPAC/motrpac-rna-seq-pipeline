import glob
import pandas as pd
from functools import reduce

#Usage : python merge_fc.py

#file_list = glob.glob('mnt_araja/PASS1A/Stanford/batch1/set1/rnaseq_pipeline/*/call-rsem_quant/shard*/rsem_reference/*.genes.results')


file_list = glob.glob('featureCounts/*.out')

#gene_ids , expected_counts
cols_counts = [0,6]
vial_label=[]
sample_list=[]
count_l=[]

for f in file_list:
    df = pd.read_csv(f,header=None,skiprows=2,sep="\t",usecols=cols_counts)
    vial_label=f.split("/")[1].split(".")[0]
    df.columns = ["gene_id",vial_label]
    print (df.columns)
    if not vial_label in sample_list:
        count_l.append(df)
        sample_list.append(vial_label)
 
 
#print (count_l)
df_final=reduce(lambda x,y: pd.merge(x,y, on='gene_id', how='outer'), count_l)
#print (df_final)
df_final = df_final.astype(str)

df_final.to_csv("featureCounts.txt", index=False,sep="\t")
print ("Shape of Feature counts df")
print (df_final.shape)





