version 1.0

task attachUMI {
    input {
        File fastqr1
        File fastqr2
        File fastqi1
        String SID

        # Runtime Attributes
        Int memory
        Int disk_space
        Int ncpu

        String docker
    }

    command <<<
        echo "--- $(date "+[%b %d %H:%M:%S]") Beginning task, making output directories ---"
        mkdir fastq_attach

        echo "--- $(date "+[%b %d %H:%M:%S]") Running attachUMI for ~{fastqr1} ---"
        zcat ~{fastqr1} | /usr/local/src/UMI_attach.awk -v Ifq=~{fastqi1} | gzip -c > "fastq_attach/~{SID}_R1.fastq.gz"

        echo "--- $(date "+[%b %d %H:%M:%S]") Running attachUMI for ~{fastqr2} ---"
        zcat ~{fastqr2}| /usr/local/src/UMI_attach.awk -v Ifq=~{fastqi1} | gzip -c > "fastq_attach/~{SID}_R2.fastq.gz"

        echo "--- $(date "+[%b %d %H:%M:%S]") Finished task ---"
    >>>

    output {
        File r1_umi_attached = "fastq_attach/${SID}_R1.fastq.gz"
        File r2_umi_attached = "fastq_attach/${SID}_R2.fastq.gz"
    }

    runtime {
        docker: "${docker}"
        memory: "${memory}GB"
        disks: "local-disk ${disk_space} HDD"
        cpu: "${ncpu}"

    }

    meta {
        author: "Archana Raja"
    }
}
