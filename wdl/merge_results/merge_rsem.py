"""
Usage: python merge_rsem.py --rsem_dir <rsem_dir>
"""
import argparse
import os
from functools import reduce

import pandas as pd


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument(
        '--rsem_dir',
        help='Path to the directory containing the RSEM files',
        required=True,
    )

    args = parser.parse_args()

    file_list = [f'{args.rsem_dir}/{f}' for f in os.listdir(args.rsem_dir)]

    # gene_ids , expected_counts
    cols_counts = [0, 4]  # add more columns here
    cols_tpm = [0, 5]
    cols_fpkm = [0, 6]
    count_l = []
    fpkm_l = []
    tpm_l = []
    sample_list = []

    for f in file_list:
        df = pd.read_csv(f, header=0, sep="\t", usecols=cols_counts)
        df_tpm = pd.read_csv(f, header=0, sep="\t", usecols=cols_tpm)
        df_fpkm = pd.read_csv(f, header=0, sep="\t", usecols=cols_fpkm)
        vial_label = f.split("/")[1].split(".")[0]

        df.rename(columns={'expected_count': vial_label}, inplace=True)
        df_tpm.rename(columns={'TPM': vial_label}, inplace=True)
        df_fpkm.rename(columns={'FPKM': vial_label}, inplace=True)
        if vial_label not in sample_list:
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


if __name__ == '__main__':
    main()
