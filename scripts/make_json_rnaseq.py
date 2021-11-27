# Usage example : python3 scripts/make_json_rnaseq.py
# gs://***REMOVED***-transfer-stanford/rna-seq/rat/batch4_20200106/fastq_raw
# input_json/test3/ 4 To do : Add an exception to stop execution with a reason if the
# number of chunks >number of files in the directory
import argparse
import json
import os
import sys

import gcsfs
import numpy as np


def main(gcp_path, output_path, num_chunks):
    fs = gcsfs.GCSFileSystem(project="***REMOVED***")
    batch_num = 1
    gcp_path = gcp_path + "/*_R1.fastq.gz"
    gcp_prefix = "gs://"
    print("Number of batches to split:" + "\t" + str(num_chunks))
    # Verify if the number of batches to split is <= the total number of input files
    if num_chunks > len(fs.glob(gcp_path)):
        print(
            "Script exited. Reason : num_chunks exceeded the number of files in the "
            "bucket, please enter a value that's <= the total number of input "
            "*_R1.fastq.gz "
        )
        sys.exit(1)

    else:
        split_r1 = np.array_split(fs.glob(gcp_path), num_chunks)
        sname = [[os.path.basename(i).split("_R1.fastq.gz")[0] for i in l] for l in split_r1]
        # gcsfs chops off the gs:// hence i have to do append gs:// to each path as below
        split_r1 = list(list(map(lambda orig_path: gcp_prefix + orig_path, l)) for l in split_r1)
        split_r2 = [[sub.replace("_R1.fastq.gz", "_R2.fastq.gz") for sub in l] for l in split_r1]
        split_i1 = [[sub.replace("_R1.fastq.gz", "_I1.fastq.gz") for sub in l] for l in split_r1]
        for (r1, r2, i1, prefix_list) in zip(split_r1, split_r2, split_i1, sname):
            json_dict = make_json_dict(r1, r2, i1, prefix_list)
            batch_num = batch_num + 1
            with open(
                os.path.join(output_path, f"set{str(batch_num)}_rnaseq.json"), "w", encoding="utf-8"
            ) as file:
                json.dump(json_dict, file)
        print("Success! Finished generating input jsons")


def make_json_dict(r1=None, r2=None, i1=None, prefix_list=None):
    if r1 is None:
        r1 = []
    if r2 is None:
        r2 = []
    if i1 is None:
        i1 = []
    if prefix_list is None:
        prefix_list = []

    d = {
        "rnaseq_pipeline.fastq1": r1,
        "rnaseq_pipeline.fastq2": r2,
        "rnaseq_pipeline.fastq_index": i1,
        "rnaseq_pipeline.sample_prefix": prefix_list,
        "rnaseq_pipeline.preTrimFastQC.outdir": "fastqc_raw",
        "rnaseq_pipeline.index_adapter": "AGATCGGAAGAGC",
        "rnaseq_pipeline.univ_adapter": "AGATCGGAAGAGC",
        "rnaseq_pipeline.minimumLength": "20",
        "rnaseq_pipeline.postTrimFastQC.outdir": "fastqc_trim",
        "rnaseq_pipeline.star_align.star_index": "gs://***REMOVED***/references/rn/v96/star_2.7.0d_04-20-19/sorted/Rnor6_v96_star_index.tar.gz",
        "rnaseq_pipeline.rsem_quant.rsem_reference": "gs://***REMOVED***/references/rn/v96/rsem/sorted/rn6_rsem_reference.tar.gz",
        "rnaseq_pipeline.rnaqc.ref_flat": "gs://***REMOVED***/references/rn/v96/sorted/refFlat_rn6_v96.txt",
        "rnaseq_pipeline.featurecounts.gtf_file": "gs://***REMOVED***/references/rn/v96/sorted/Rattus_norvegicus.Rnor_6.0.96.gtf",
        "rnaseq_pipeline.bowtie2_globin.genome_dir": "rn_globin",
        "rnaseq_pipeline.bowtie2_globin.genome_dir_tar": "gs://***REMOVED***/references/rn/bowtie2_index/rn_globin.tar.gz",
        "rnaseq_pipeline.bowtie2_rrna.genome_dir": "rn_rRNA",
        "rnaseq_pipeline.bowtie2_rrna.genome_dir_tar": "gs://***REMOVED***/references/rn/bowtie2_index/rn_rRNA.tar.gz",
        "rnaseq_pipeline.bowtie2_phix.genome_dir": "phix",
        "rnaseq_pipeline.bowtie2_phix.genome_dir_tar": "gs://***REMOVED***/references/rn/bowtie2_index/phix.tar.gz",
        "rnaseq_pipeline.script": "gs://***REMOVED***/scripts/rnaseq_qc.py",
        "rnaseq_pipeline.ncpu": "4",
        "rnaseq_pipeline.memory": "16000",
        "rnaseq_pipeline.cpus": "4",
        "rnaseq_pipeline.docker": "gcr.io/***REMOVED***/motrpac_rnaseq:v0.1_04_20_19",
        "rnaseq_pipeline.disk_space": "100",
    }

    return d


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="This script is used to generate input json files from the "
        "fastq_raw dir on gcp for running rna-seq pipeline on GCP "
    )
    parser.add_argument(
        "gcp_path",
        help="location of the submission batch directory in gcp that contains the " "fastq_raw dir",
        type=str,
    )
    parser.add_argument(
        "output_path", help="output path, where you want the input jsons to be written", type=str
    )
    parser.add_argument(
        "num_chunks",
        help="number of chunks to split the input files, should always be <= number of "
        "input files",
        type=int,
    )
    args = parser.parse_args()
    main(args.gcp_path, args.output_path, args.num_chunks)
