version 1.0

task multiQC {
    input {
        Array[File] fastQCReports
        Int memory
        Int disk_space
        Int num_threads
        Int num_preempt
        String docker
        File trim_report
    }

    command <<<
        set -eou pipefail
        echo "--- $(date "+[%b %d %H:%M:%S]") Beginning task, creating input directory ---"
        mkdir reports
        cd reports

        echo "--- $(date "+[%b %d %H:%M:%S]") Extracting fastQC reports from input tarball ---"
        for FILE in ~{sep=' ' fastQCReports}  ; do
            echo "Extracting $FILE"
            tar -zxvf $FILE
            rm $FILE
        done

        cd ..
        ls reports
        mkdir multiQC_report

        echo "--- $(date "+[%b %d %H:%M:%S]") Running multiQC ---"
        multiqc \
          -d \
          -f \
          -o multiQC_prealign_report \
          reports/* ~{trim_report}

        echo "--- $(date "+[%b %d %H:%M:%S]") Creating output tarball ---"
        tar -czvf multiqc_prealign_report.tar.gz ./multiQC_prealign_report

        echo "--- $(date "+[%b %d %H:%M:%S]") Finished creating output tarball, finished task ---"
    >>>

    output {
        File multiQC_report = 'multiqc_prealign_report.tar.gz'
    }

    runtime {
        docker: "${docker}"
        memory: "${memory}GB"
        disks: "local-disk ${disk_space} HDD"
        cpu: "${num_threads}"
        preemptible: "${num_preempt}"
    }
}
