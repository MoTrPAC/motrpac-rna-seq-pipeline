version 1.0

task rnaseqQC {
    input {
        Array[File] multiQCReports
        Int memory
        Int disk_space
        Int num_threads
        Int num_preempt
        String docker

        File trim_summary
        File mapped_report
        File rRNA_report
        File globin_report
        File phix_report
        File umi_report
        File star_log
        String SID
    }

    command <<<
        set -eou pipefail

        for file in ~{sep=' ' multiQCReports}  ; do
            tar -zxvf $file
            rm $file
        done

        python3 rnaseq_pc.py --multiqc_prealign multiQC_prealign_report \
        --multiqc_postalign multiQC_postalign_report \
            ~{trim_summary} \
            ~{mapped_report} \
            ~{rRNA_report} \
            ~{globin_report} \
            ~{phix_report} \
            ~{umi_report} \
            ~{star_log}

        touch ~{SID}_qc_info.csv
    >>>

    output {
        File rnaseq_report = "${SID}_qc_info.csv"
    }

    runtime {
        docker: "${docker}"
        memory: "${memory}GB"
        disks: "local-disk ${disk_space} HDD"
        cpu: "${num_threads}"
        preemptible: "${num_preempt}"
    }
}