#This script consolidates qc reports from individual samples into one report
#Usage : python3 consolidate_qc_report.py --qc_dir qc_logs Sinai_batch1_qc_info_bic.csv

import pandas as pd
import os
import argparse

parser = argparse.ArgumentParser()
parser.add_argument('--qc_dir', help='Path to the directory containing the qc reports')
parser.add_argument('output_report_name', help='Name of output report')
args = parser.parse_args()

targetdir=args.qc_dir
#list the files
filelist = os.listdir(targetdir) 


#change to the dirctory with qc logs
os.chdir(targetdir)


#read them into pandas
df_list = [pd.read_csv(file) for file in filelist]

#concatenate them together
big_df = pd.concat(df_list,sort=False)

#write the dataframe to a file
big_df.to_csv(args.output_report_name,sep=",",index=False)
