# Usage example : python3 make_json_rnaseq.py -g gs://my-bucket/rna-seq/human/batch7_20220316/fastq_raw -o `pwd` -r batch7_qc_metrics.csv -a human -n 1 -d gcr.io/motrpac-portal/motrpac-rna-seq-pipeline/ -p my-project

import argparse
import json
import os
import sys

import gcsfs
import numpy as np


def main(command_args: argparse.Namespace):
    fs = gcsfs.GCSFileSystem(args.project)
    batch_num = 0
    gcp_path = command_args.gcp_path + "/*_R1.fastq.gz"
    gcp_prefix = "gs://"
    print("Number of batches to split:" + "\t" + str(command_args.num_chunks))
    # Verify if the number of batches to split is <= the total number of input files
    if command_args.num_chunks > len(fs.glob(gcp_path)):
        print(
            "Script exited. Reason : num_chunks exceeded the number of files in the "
            "bucket, please enter a value that's <= the total number of input "
            "*_R1.fastq.gz "
        )
        sys.exit(1)

    else:
        np_split_r1 = np.array_split(fs.glob(gcp_path), command_args.num_chunks)
        split_r1 = [splitted_list.tolist() for splitted_list in np_split_r1]

        if not command_args.undetermined:
            split_r1 = [
                list(filter(lambda x: "Undetermined_" not in x, l)) for l in split_r1
            ]

        s_name = [
            [os.path.basename(i).split("_R1.fastq.gz")[0] for i in l] for l in split_r1
        ]
        # gcsfs chops off the gs:// hence i have to do append gs:// to each path as below
        split_r1 = [
            list(map(lambda orig_path: gcp_prefix + orig_path, l)) for l in split_r1
        ]
        split_r2 = [
            [sub.replace("_R1.fastq.gz", "_R2.fastq.gz") for sub in l] for l in split_r1
        ]
        split_i1 = [
            [sub.replace("_R1.fastq.gz", "_I1.fastq.gz") for sub in l] for l in split_r1
        ]
        docker_repo = command_args.docker_repo.rstrip("/").strip()

        for (r1, r2, i1, prefix_list) in zip(split_r1, split_r2, split_i1, s_name):
            json_dict = make_json_dict(
                command_args.organism,
                docker_repo,
                args.output_report_name,
                r1,
                r2,
                i1,
                prefix_list,
            )
            batch_num = batch_num + 1
            with open(
                os.path.join(
                    command_args.output_path, f"set{str(batch_num)}_rnaseq.json"
                ),
                "w",
                encoding="utf-8",
            ) as file:
                json.dump(obj=json_dict, fp=file, indent=4)

        print("Success! Finished generating input jsons")


def make_json_dict(
    organism,
    docker_repo,
    output_report_name,
    r1=None,
    r2=None,
    i1=None,
    prefix_list=None,
):
    if r1 is None:
        r1 = []
    if r2 is None:
        r2 = []
    if i1 is None:
        i1 = []
    if prefix_list is None:
        prefix_list = []

    if organism == "rat":
        organism_references = {
            "rnaseq_pipeline.star_index": "gs://omicspipelines/rnaseq/references/rat/Rnor6_v96_star_index.tar.gz",
            "rnaseq_pipeline.gtf_file": "gs://omicspipelines/rnaseq/references/rat/Rattus_norvegicus.Rnor_6.0.96.gtf",
            "rnaseq_pipeline.rsem_reference": "gs://omicspipelines/rnaseq/references/rat/rn6_rsem_reference.tar.gz",
            "rnaseq_pipeline.globin_genome_dir_tar": "gs://omicspipelines/rnaseq/references/rat/rn_globin.tar.gz",
            "rnaseq_pipeline.rrna_genome_dir_tar": "gs://omicspipelines/rnaseq/references/rat/rn_rRNA.tar.gz",
            "rnaseq_pipeline.phix_genome_dir_tar": "gs://omicspipelines/rnaseq/references/rat/phix.tar.gz",
            "rnaseq_pipeline.ref_flat": "gs://omicspipelines/rnaseq/references/rat/refFlat_rn6_v96.txt",
        }
    elif organism == "human":
        organism_references = {
            "rnaseq_pipeline.star_index": "gs://omicspipelines/rnaseq/references/human/hg38_v39_star_index.tar.gz",
            "rnaseq_pipeline.gtf_file": "gs://omicspipelines/rnaseq/references/human/GRCh38.v39.primary_assembly.annotation.gtf",
            "rnaseq_pipeline.rsem_reference": "gs://omicspipelines/rnaseq/references/human/hg38_rsem_reference.tar.gz",
            "rnaseq_pipeline.globin_genome_dir_tar": "gs://omicspipelines/rnaseq/references/human/hs_globin.tar.gz",
            "rnaseq_pipeline.rrna_genome_dir_tar": "gs://omicspipelines/rnaseq/references/human/hs_rRNA.tar.gz",
            "rnaseq_pipeline.phix_genome_dir_tar": "gs://omicspipelines/rnaseq/references/human/phix.tar.gz",
            "rnaseq_pipeline.ref_flat": "gs://omicspipelines/rnaseq/references/human/refFlat_hg38_v39.txt",
        }
    else:
        print("Invalid organism")
        sys.exit(1)

    filled_dict = {
        "rnaseq_pipeline.fastq1": r1,
        "rnaseq_pipeline.fastq2": r2,
        "rnaseq_pipeline.fastq_index": i1,
        "rnaseq_pipeline.sample_prefix": prefix_list,
        "rnaseq_pipeline.pretrim_fastqc_ncpu": 8,
        "rnaseq_pipeline.pretrim_fastqc_ramGB": 40,
        "rnaseq_pipeline.pretrim_fastqc_disk": 100,
        "rnaseq_pipeline.fastqc_docker": f"{docker_repo}/fastqc:latest",
        "rnaseq_pipeline.attach_umi_ncpu": 8,
        "rnaseq_pipeline.attach_umi_ramGB": 40,
        "rnaseq_pipeline.attach_umi_disk": 100,
        "rnaseq_pipeline.attach_umi_docker": f"{docker_repo}/umi_attach:latest",
        "rnaseq_pipeline.minimumLength": 20,
        "rnaseq_pipeline.index_adapter": "AGATCGGAAGAGC",
        "rnaseq_pipeline.univ_adapter": "AGATCGGAAGAGC",
        "rnaseq_pipeline.cutadapt_ncpu": 8,
        "rnaseq_pipeline.cutadapt_ramGB": 45,
        "rnaseq_pipeline.cutadapt_disk": 100,
        "rnaseq_pipeline.cutadapt_docker": f"{docker_repo}/cutadapt:latest",
        "rnaseq_pipeline.posttrim_fastqc_ncpu": 8,
        "rnaseq_pipeline.posttrim_fastqc_ramGB": 36,
        "rnaseq_pipeline.posttrim_fastqc_disk": 100,
        "rnaseq_pipeline.multiqc_ncpu": 8,
        "rnaseq_pipeline.multiqc_ramGB": 20,
        "rnaseq_pipeline.multiqc_disk": 100,
        "rnaseq_pipeline.multiqc_docker": f"{docker_repo}/multiqc:latest",
        "rnaseq_pipeline.star_ncpu": 12,
        "rnaseq_pipeline.star_ramGB": 120,
        "rnaseq_pipeline.star_disk": 400,
        "rnaseq_pipeline.star_docker": f"{docker_repo}/star:latest",
        "rnaseq_pipeline.feature_counts_ncpu": 8,
        "rnaseq_pipeline.feature_counts_ramGB": 48,
        "rnaseq_pipeline.feature_counts_disk": 100,
        "rnaseq_pipeline.feature_counts_docker": f"{docker_repo}/feature_counts:latest",
        "rnaseq_pipeline.rsem_ncpu": 10,
        "rnaseq_pipeline.rsem_ramGB": 48,
        "rnaseq_pipeline.rsem_disk": 150,
        "rnaseq_pipeline.rsem_docker": f"{docker_repo}/rsem:latest",
        "rnaseq_pipeline.bowtie2_globin_ncpu": 12,
        "rnaseq_pipeline.bowtie2_globin_ramGB": 80,
        "rnaseq_pipeline.bowtie2_globin_disk": 200,
        "rnaseq_pipeline.bowtie2_rrna_ncpu": 12,
        "rnaseq_pipeline.bowtie2_rrna_ramGB": 80,
        "rnaseq_pipeline.bowtie2_rrna_disk": 200,
        "rnaseq_pipeline.bowtie2_phix_ncpu": 12,
        "rnaseq_pipeline.bowtie2_phix_ramGB": 80,
        "rnaseq_pipeline.bowtie2_phix_disk": 200,
        "rnaseq_pipeline.bowtie_docker": f"{docker_repo}/bowtie:latest",
        "rnaseq_pipeline.markdup_ncpu": 10,
        "rnaseq_pipeline.markdup_ramGB": 96,
        "rnaseq_pipeline.markdup_disk": 300,
        "rnaseq_pipeline.rnaqc_ncpu": 10,
        "rnaseq_pipeline.rnaqc_ramGB": 48,
        "rnaseq_pipeline.rnaqc_disk": 100,
        "rnaseq_pipeline.picard_docker": f"{docker_repo}/picard:latest",
        "rnaseq_pipeline.umi_dup_ncpu": 8,
        "rnaseq_pipeline.umi_dup_ramGB": 36,
        "rnaseq_pipeline.umi_dup_disk": 200,
        "rnaseq_pipeline.umi_dup_docker": f"{docker_repo}/umi_dup:latest",
        "rnaseq_pipeline.mapped_ncpu": 8,
        "rnaseq_pipeline.mapped_ramGB": 36,
        "rnaseq_pipeline.mapped_disk": 200,
        "rnaseq_pipeline.samtools_docker": f"{docker_repo}/samtools:latest",
        "rnaseq_pipeline.mqc_postalign_ncpu": 8,
        "rnaseq_pipeline.mqc_postalign_ramGB": 36,
        "rnaseq_pipeline.mqc_postalign_disk": 50,
        "rnaseq_pipeline.collect_qc_ncpu": 8,
        "rnaseq_pipeline.collect_qc_ramGB": 16,
        "rnaseq_pipeline.collect_qc_disk": 100,
        "rnaseq_pipeline.collect_qc_docker": f"{docker_repo}/collect_qc:latest",
        "rnaseq_pipeline.output_report_name": output_report_name,
        "rnaseq_pipeline.merge_results_ncpu": 4,
        "rnaseq_pipeline.merge_results_ramGB": 16,
        "rnaseq_pipeline.merge_results_disk": 200,
        "rnaseq_pipeline.merge_results_docker": f"{docker_repo}/merge_results:latest",
    }

    d = {**filled_dict, **organism_references}

    return d


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="This script is used to generate input json files from the "
        "fastq_raw dir on gcp for running rna-seq pipeline on GCP "
    )
    parser.add_argument(
        "-g",
        "--gcp_path",
        help="location of the submission batch directory in gcp that contains the "
        "fastq_raw dir",
        type=str,
    )
    parser.add_argument(
        "-o",
        "--output_path",
        help="output path, where you want the input jsons to be written",
        type=str,
    )
    parser.add_argument(
        "-r",
        "--output_report_name",
        help="name of the output report to be written",
        type=str,
    )
    parser.add_argument(
        "-u",
        "--undetermined",
        help="Adding this flag will process undetermined FastQ files if they exist. "
        "These are fastq files with prefix \"Undetermined_\". If this flag isn't "
        "passed, items with prefix \"Undetermined_\" will be removed",
        default=False,
        action="store_true",
    )
    parser.add_argument(
        "-a",
        "--organism",
        help="organism name, e.g. rat or human",
        choices=["rat", "human"],
        default="rat",
    )
    parser.add_argument(
        "-n",
        "--num_chunks",
        help="number of chunks to split the input files, should always be <= number of "
        "input files",
        type=int,
    )
    parser.add_argument(
        "-d",
        "--docker_repo",
        help="Docker repository prefix containing the images used in the workflow",
        type=str,
        default="gcr.io/motrpac-portal/motrpac-rna-seq-pipeline",
    )
    parser.add_argument(
    "-p",
    "--project",
    help="Project name on the google cloud platform",
    type=str
    )
    args = parser.parse_args()
    main(args)
