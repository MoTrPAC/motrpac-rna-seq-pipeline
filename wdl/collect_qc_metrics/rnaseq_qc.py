"""
Script to collect rna-seq qc metrics from different summary and report files from the rnaseq
pipeline

Usage : python rnaseq_qc.py --multiqc_prealign multiQC_prealign_report --multiqc_postalign
multiQC_postalign_report 8019468197_summary.txt 8019468197_mapped_report.txt 
8019468197_rRNA_report.txt 8019468197_globin_report.txt 8019468197_phix_report.txt 
8019468197_umi_report.txt 8019468197.Log.final.out

Author : Archana Raja
"""
import argparse
import os
import re
from functools import reduce

import pandas as pd


def make_args():
    parser = argparse.ArgumentParser(description="Script to collect RNA-seq QC metrics")
    parser.add_argument("--sample", help="Sample prefix")
    parser.add_argument("--multiqc_prealign", help="path to MultiQC prealign directory")
    parser.add_argument("--multiqc_postalign", help="path to MultiQC postalign directory")
    parser.add_argument("--cutadapt_report", help="Cutadapt report file")
    parser.add_argument("--mapped_report", help="Alignment report")
    parser.add_argument("--rRNA_report", help="rRNA alignment report")
    parser.add_argument("--globin_report", help="globin alignment report")
    parser.add_argument("--phix_report", help="phix alignment report")
    parser.add_argument("--umi_report", help="UMI duplication report")
    parser.add_argument("--star_log", help="STAR log file")
    return parser.parse_args()


def main():
    args = make_args()

    dirname = "multiQC_prealign_report"
    filename = "multiqc_data/multiqc_general_stats.txt"
    pa_dirname = "multiQC_postalign_report"
    star_report = "multiqc_data/multiqc_star.txt"
    mqc_gen_report = "multiqc_data/multiqc_general_stats.txt"
    rna_metrics_report = "multiqc_data/multiqc_picard_RnaSeqMetrics.txt"
    print("Success reading input reports")

    mqc_raw = os.path.join(dirname, filename)
    mqc_star = os.path.join(pa_dirname, star_report)
    mqc_gen = os.path.join(pa_dirname, mqc_gen_report)
    mqc_rna_metrics = os.path.join(pa_dirname, rna_metrics_report)
    print("Success creating paths")

    df_raw = pd.read_csv(mqc_raw, sep="\t", header=0)
    df_star = pd.read_csv(mqc_star, sep="\t", header=0)
    df_pa = pd.read_csv(mqc_gen, sep="\t", header=0)
    df_star_log = pd.read_csv(args.star_log, index_col=0, sep="\t")
    df_rna_metrics = pd.read_csv(mqc_rna_metrics, sep="\t", header=0)
    df_cutadapt = pd.read_csv(args.cutadapt_report, sep="\t", header=0)
    df_umi = pd.read_csv(args.umi_report, sep="\t", header=0)
    df_globin = pd.read_csv(args.globin_report, sep="\t", header=0)
    df_r_rna = pd.read_csv(args.rRNA_report, sep="\t", header=0)
    df_phix = pd.read_csv(args.phix_report, sep="\t", header=0)
    df_mapped = pd.read_csv(args.mapped_report, sep="\t", header=0)

    df_globin["pct_globin"] = df_globin["pct_globin"].str.replace("%", "")
    df_r_rna["pct_rRNA"] = df_r_rna["pct_rRNA"].str.replace("%", "")
    df_phix["pct_phix"] = df_phix["pct_phix"].str.replace("%", "")
    print("Success creating data frames")

    # %trimmed_bases
    percent_trimmed_bases = df_raw[
        "Cutadapt_mqc-generalstats-cutadapt-percent_trimmed"
    ][0].round(3)

    # %Adapter detected
    pct_adapter_detected = df_cutadapt["pct_adapter_detected"][0]

    # get mean raw read count
    reads_raw = (
                    df_raw["FastQC_mqc-generalstats-fastqc-total_sequences"][1]
                    + df_raw["FastQC_mqc-generalstats-fastqc-total_sequences"][2]
                ) / 2

    # Below expression extracts the sample_name by splitting the first value in the
    # Sample column by _R1.fastq.gz or _R2.fastq.gz
    sample_name = re.split("_R[1,2]", (df_raw["Sample"][0]))[0]

    # get read counts after trimming (reads)
    reads_trim = (
                     df_raw["FastQC_mqc-generalstats-fastqc-total_sequences"][3]
                     + df_raw["FastQC_mqc-generalstats-fastqc-total_sequences"][4]
                 ) / 2

    # get GC content of the trimmed reads (%GC)
    gc = (
             df_raw["FastQC_mqc-generalstats-fastqc-percent_gc"][3]
             + df_raw["FastQC_mqc-generalstats-fastqc-percent_gc"][4]
         ) / 2

    # %dup_sequence
    dup_seq = (
        (
            df_raw["FastQC_mqc-generalstats-fastqc-percent_duplicates"][3]
            + df_raw["FastQC_mqc-generalstats-fastqc-percent_duplicates"][4]
        )
        / 2
    ).round(3)

    # %trimmed
    perc_trimmed = (((reads_raw - reads_trim) / reads_raw) * 100).round(3)

    # %rRNA
    perc_r_rna = df_r_rna["pct_rRNA"][0]

    # %globin
    perc_globin = df_globin["pct_globin"][0]

    # %phix
    perc_phix = df_phix["pct_phix"][0]

    # %picard_dup
    perc_picard_dup = (
        (df_pa["Picard_mqc-generalstats-picard-PERCENT_DUPLICATION"][0]) * 100
    ).round(3)

    # UMI dup percent
    pct_umi_dup = df_umi["pct_umi_dup"][0]

    # % chimeric reads
    d = df_star_log.to_dict()
    perc_chimeric_reads = d[list(d.keys())[0]][
        "                            % of chimeric reads |"
    ].strip("%")

    data1 = {
        "Sample": [sample_name],
        "reads_raw": [reads_raw],
        "pct_adapter_detected": [pct_adapter_detected],
        "pct_trimmed": [perc_trimmed],
        "pct_trimmed_bases": [percent_trimmed_bases],
        "reads": [reads_trim],
        "pct_GC": [gc],
        "pct_dup_sequence": [dup_seq],
        "pct_rRNA": [perc_r_rna],
        "pct_globin": [perc_globin],
        "pct_phix": [perc_phix],
        "pct_picard_dup": [perc_picard_dup],
        "pct_umi_dup": [pct_umi_dup],
    }

    df1 = pd.DataFrame(data1)
    df1["Sample"] = df1.Sample.astype("str")
    print("df_prealign")
    print(df1)
    print("Success")

    df_star = df_star.drop(
        [
            "insertion_length",
            "deletion_length",
            "deletion_rate",
            "mismatch_rate",
            "multimapped_toomany",
            "unmapped_mismatches",
            "unmapped_other",
            "insertion_rate",
            "multimapped",
            "unmapped_tooshort",
            "total_reads",
        ],
        axis=1,
    )
    df_star = df_star.reindex(
        [
            "Sample",
            "avg_input_read_length",
            "uniquely_mapped",
            "uniquely_mapped_percent",
            "avg_mapped_read_length",
            "num_splices",
            "num_annotated_splices",
            "num_GTAG_splices",
            "num_GCAG_splices",
            "num_ATAC_splices",
            "num_noncanonical_splices",
            "multimapped_percent",
            "multimapped_toomany_percent",
            "unmapped_mismatches_percent",
            "unmapped_tooshort_percent",
            "unmapped_other_percent",
        ],
        axis=1,
    )
    df_star.rename(
        columns={
            "Sample": "sample",
            "uniquely_mapped_percent": "pct_uniquely_mapped",
            "multimapped_percent": "pct_multimapped",
            "multimapped_toomany_percent": "pct_multimapped_toomany",
            "unmapped_mismatches_percent": "pct_unmapped_mismatches",
            "unmapped_tooshort_percent": "pct_unmapped_tooshort",
            "unmapped_other_percent": "pct_unmapped_other",
        },
        inplace=True,
    )

    # Adding pct_chimeric column to the star data frame
    df_star = df_star.assign(pct_chimeric=[perc_chimeric_reads])
    print(df_star)

    # Modifying rnaseqmetrics data frame column names
    df_rna_metrics = df_rna_metrics.loc[
                     :,
                     [
                         "Sample",
                         "PCT_CODING_BASES",
                         "PCT_MRNA_BASES",
                         "PCT_INTRONIC_BASES",
                         "MEDIAN_5PRIME_TO_3PRIME_BIAS",
                         "PCT_INTERGENIC_BASES",
                         "PCT_UTR_BASES",
                     ],
                     ]
    df_rna_metrics = df_rna_metrics.reindex(
        [
            "Sample",
            "PCT_CODING_BASES",
            "PCT_UTR_BASES",
            "PCT_INTRONIC_BASES",
            "PCT_INTERGENIC_BASES",
            "PCT_MRNA_BASES",
            "MEDIAN_5PRIME_TO_3PRIME_BIAS",
        ],
        axis=1,
    )
    df_rna_metrics.columns = [x.strip().replace("_BASES", "") for x in
                              df_rna_metrics.columns]
    df_rna_metrics.rename(
        columns={"MEDIAN_5PRIME_TO_3PRIME_BIAS": "median_5_3_bias"}, inplace=True
        )
    df_rna_metrics.columns = df_rna_metrics.columns.str.lower()
    print(df_rna_metrics)

    df_mapped.rename(columns={"Sample": "sample"}, inplace=True)
    df1.rename(columns={"Sample": "sample"}, inplace=True)

    df1 = df1.round(3)
    df_star = df_star.round(3)
    df_rna_metrics = df_rna_metrics.round(3)
    print(df_rna_metrics)
    df_mapped = df_mapped.round(
        {"pct_chrX": 3, "pct_chrY": 5, "pct_chrM": 3, "pct_chrAuto": 3, "pct_contig": 3}
    )
    # Merging data frames
    dfs = [df1, df_star, df_mapped, df_rna_metrics]

    def rename_sample_df(df: pd.DataFrame):
        df['sample'] = df['sample'].astype(str)
        df['sample'] = df['sample'].apply(lambda x: re.sub(r"(_R[1,2])$", "", x))
        return df

    new_dfs = map(lambda x: rename_sample_df(x), dfs)
    df_final = reduce(lambda left, right: pd.merge(left, right, on="sample"), new_dfs)

    print(df_final["sample"].dtype)
    print("Merging successful")
    print(df_final)
    print(df_final["sample"][0])

    name = f"{args.sample.strip()}_qc_info.csv"

    # Writing qc_report to a csv file
    df_final.to_csv(name, sep=",", index=False)


if __name__ == "__main__":
    main()
