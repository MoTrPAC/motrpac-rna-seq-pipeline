version 1.0

task merge_results {
    input {
        Array[File] rsem_files
        Array[File] feature_counts_files
        Array[File] qc_report_files
        String output_report_name

        Int memory
        Int disk_space
        Int ncpu
        String docker
    }

    command <<<
        set -eou pipefail
        echo "--- $(date "+[%b %d %H:%M:%S]") Beginning task, copying files ---"

        mkdir -p rsem_files
        mkdir -p qc_report_files
        mkdir -p feature_counts_files

        cp ~{sep=" " rsem_files} rsem_files/
        cp ~{sep=" " feature_counts_files} feature_counts_files/
        cp ~{sep=" " qc_report_files} qc_report_files/

        echo "--- $(date "+[%b %d %H:%M:%S]") Merging RSEM results ---"
        python3 /usr/local/src/merge_rsem.py --rsem_dir rsem_files

        echo "--- $(date "+[%b %d %H:%M:%S]") Finished merging RSEM results, consolidating QC reports ---"
        python3 /usr/local/src/consolidate_qc_report.py --qc_dir qc_report_files --output_name ~{output_report_name}.csv

        echo "--- $(date "+[%b %d %H:%M:%S]") Finished merging consolidating QC reports, merging feature counts ---"
        python3 /usr/local/src/merge_fc.py --fc_dir feature_counts_files

        echo "--- $(date "+[%b %d %H:%M:%S]") Finished merging feature counts, finished task  ---"
    >>>

    output {
        File rsem_genes_count = "rsem_genes_count.txt"
        File rsem_genes_tpm = "rsem_genes_tpm.txt"
        File rsem_genes_fpkm = "rsem_genes_fpkm.txt"
        File feature_counts = "featureCounts.txt"
        File qc_report = "${output_report_name}.csv"
    }

    runtime {
        docker: "${docker}"
        memory: "${memory}GB"
        disks: "local-disk ${disk_space} HDD"
        cpu: "${ncpu}"
    }
}
