"""
This script consolidates qc reports from individual samples into one report
Usage: python3 consolidate_qc_report.py --qc_dir qc_logs --output_name Sinai_batch1_qc_info_bic.csv
"""

import argparse
import os

import pandas as pd


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument(
        '--qc_dir',
        help='Path to the directory containing the qc reports',
        required=True,
    )
    parser.add_argument(
        '--output_name', help='Name of the final, merged output report', required=True
    )
    args = parser.parse_args()

    # list the files
    file_list = [f'{args.qc_dir}/{f}' for f in os.listdir(args.qc_dir)]

    # read them into pandas
    df_list = [pd.read_csv(file) for file in file_list]

    # concatenate them together
    concat_df = pd.concat(df_list, sort=False)

    # write the dataframe to a file
    concat_df.to_csv(args.output_name, sep=",", index=False)


if __name__ == '__main__':
    main()
