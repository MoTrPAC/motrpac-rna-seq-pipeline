version 1.0

task rnaseqQC {
    input {
        Array[File] multiQCReports
        Int memory
        Int disk_space
        Int ncpu

        String docker

        File trim_summary
        File mapped_report
        File rRNA_report
        File globin_report
        File phix_report
        File star_log
        File? umi_report
        String SID
    }

    command <<<
        set -eou pipefail
        echo "--- $(date "+[%b %d %H:%M:%S]") Beginning task, unzipping files ---"
        for FILE in ~{sep=' ' multiQCReports}  ; do
            echo "--- $(date "+[%b %d %H:%M:%S]") Unzipping $FILE ---"
            tar -zxvf $FILE
            rm $FILE
        done

        echo "--- $(date "+[%b %d %H:%M:%S]") Running rnaseq_qc.py script ---"
        python3 /usr/local/src/rnaseq_qc.py \
            --sample ~{SID} \
            --multiqc_prealign multiQC_prealign_report \
            --multiqc_postalign multiQC_postalign_report \
            --cutadapt_report ~{trim_summary} \
            --mapped_report ~{mapped_report} \
            --rRNA_report ~{rRNA_report} \
            --globin_report ~{globin_report} \
            --phix_report ~{phix_report} \
            --star_log ~{star_log} \
            ~{"--umi_report " + umi_report}

        touch ~{SID}_qc_info.csv

        echo "--- $(date "+[%b %d %H:%M:%S]") Finished running script, task complete ---"
    >>>

    output {
        File rnaseq_report = "${SID}_qc_info.csv"
    }

    runtime {
        docker: "${docker}"
        memory: "${memory}GB"
        disks: "local-disk ${disk_space} HDD"
        cpu: "${ncpu}"

    }

    parameter_meta {
        SID: {
            type: "id"
        }
        trim_summary: {
           label: "CutAdapt Trim Summary Report File"
        }
        mapped_report: {
           label: "Mapped Reads Report"
        }
        rRNA_report: {
           label: "Bowtie2 rRNA Sequence Mapping Report"
        }
        globin_report: {
           label: "Bowtie2 Globin Sequence Mapping Report"
        }
        phix_report: {
           label: "Bowtie2 Phix Sequence Mapping Report"
        }
        umi_report: {
           label: "UMI Duplicate Rate Detection Report"
        }
        star_log: {
           label: "STAR Align Log"
        }

    }
}
