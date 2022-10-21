version 1.0

#rsem => looks for the file .cnt inside {SID}.stat, fc.summary file

task multiQC_postalign {
    input {
        Array[File] fastQCReport
        File trim_report
        File rsem_report
        File star_report
        File fc_report
        File md_report
        File rnametric_report

        Int memory
        Int disk_space
        Int ncpu

        String docker
    }

    command <<<
        set -eou pipefail
        echo "--- $(date "+[%b %d %H:%M:%S]") Beginning task, creating output directory ---"
        mkdir -p reports
        cd reports/

        echo "--- $(date "+[%b %d %H:%M:%S]") Extracting fastQC report files from input tarball ---"
        for FILE in ~{sep=' ' fastQCReport}  ; do
            tar -zxvf $FILE
            rm $FILE
        done

        echo "--- $(date "+[%b %d %H:%M:%S]") Copying input files to working directory ---"
        cp ~{trim_report} ./
        cp ~{rsem_report} ./
        cp ~{star_report} ./
        cp ~{fc_report} ./
        cp ~{md_report} ./
        cp ~{rnametric_report} ./
        cd ..

        ls reports
        mkdir multiQC_report

        echo "--- $(date "+[%b %d %H:%M:%S]") Running multiQC ---"
        multiqc \
            -f \
            -o multiQC_postalign_report \
            reports/*
        echo "--- $(date "+[%b %d %H:%M:%S]")Finished running multiQC ---"

        echo "--- $(date "+[%b %d %H:%M:%S]") Creating output tarball ---"
        tar -czvf multiqc_postalign_report.tar.gz ./multiQC_postalign_report

        echo "--- $(date "+[%b %d %H:%M:%S]") Finished creating output tarball, finished task ---"
    >>>

    output {
        File multiQC_report = 'multiqc_postalign_report.tar.gz'
    }

    runtime {
        docker: "${docker}"
        memory: "${memory}GB"
        disks: "local-disk ${disk_space} HDD"
        cpu: "${ncpu}"
    }

    parameter_meta {
        fastQCReport: {
           label: "FastQC Report Tarball"
        }
        trim_report: {
           label: "CutAdapt Report File"
        }
        rsem_report: {
           label: "RSEM Report File"
        }
        star_report: {
           label: "STAR Align Report File"
        }
        fc_report: {
           label: "FeatureCounts Report File"
        }
        md_report: {
           label: "Picard MarkDuplicates Report File"
        }
        rnametric_report: {
           label: "Picard CollectRnaSeqMetrics Report File"
        }
    }
}
