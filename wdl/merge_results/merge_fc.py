"""
Usage: python merge_fc.py --fc_dir <fc_dir>
"""

import argparse
import os
from functools import reduce

import pandas as pd


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument(
        '--fc_dir',
        help='Path to the directory containing the feature count files',
        required=True,
    )

    args = parser.parse_args()

    file_list = [f'{args.fc_dir}/{f}' for f in os.listdir(args.fc_dir)]

    cols_counts = [0, 6]
    sample_list = []
    count_l = []

    for f in file_list:
        df = pd.read_csv(f, header=None, skiprows=2, sep="\t", usecols=cols_counts)

        vial_label = f.split("/")[1].split(".")[0]
        df.columns = ["gene_id", vial_label]

        print(df.columns)

        if vial_label not in sample_list:
            count_l.append(df)
            sample_list.append(vial_label)

    df_final = reduce(lambda x, y: pd.merge(x, y, on='gene_id', how='outer'), count_l)
    df_final = df_final.astype(str)

    df_final.to_csv("featureCounts.txt", index=False, sep="\t")
    print("Shape of Feature counts df")
    print(df_final.shape)


if __name__ == '__main__':
    main()
