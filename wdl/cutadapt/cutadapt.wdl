version 1.0

task Cutadapt {
    input {
        String SID
        File fastqr1
        File fastqr2

        String index_adapter
        String univ_adapter
        Int? minimumLength
        
        Int cpus
        Int disk_space
        Int memory

        String docker
    }

    command <<<
        set -eou pipefail

        echo "--- $(date "+[%b %d %H:%M:%S]") Beginning task, making output directories ---"
        mkdir -p fastq_trim
        mkdir -p fastq_trim/tooshort

        echo "--- $(date "+[%b %d %H:%M:%S]") Running cutadapt on ~{fastqr1} and ~{fastqr2} ---"

        cutadapt \
        -a ~{index_adapter} \
        -A ~{univ_adapter} \
        -o fastq_trim/~{SID}_R1.fastq.gz \
        -p fastq_trim/~{SID}_R2.fastq.gz \
        -m ~{minimumLength} \
        --too-short-output fastq_trim/tooshort/~{SID}_R1.fastq.gz \
        --too-short-paired-output fastq_trim/tooshort/~{SID}_R2.fastq.gz \
        ~{fastqr1} ~{fastqr2} > "fastq_trim/~{SID}_report.log"

        echo "--- $(date "+[%b %d %H:%M:%S]") Cutadapt done, extracting summary ---"
        grep "with adapter:" fastq_trim/~{SID}_report.log|awk -F "(" '{print $2}'|sed 's/%//;s/)//'|awk -v id=~{SID} '{sum+=$1}END{print "Sample""\t""pct_adapter_detected""\n"id"\t"sum/2}' >fastq_trim/~{SID}_summary.txt

        echo "--- $(date "+[%b %d %H:%M:%S]") Done extracting summary, task complete ---"
    >>>

    output {
        File fastq_trimmed_R1 = "fastq_trim/${SID}_R1.fastq.gz"
        File fastq_trimmed_R2 = "fastq_trim/${SID}_R2.fastq.gz"
        File report = "fastq_trim/${SID}_report.log"
        File summary = "fastq_trim/${SID}_summary.txt"
        File tooShortOutput = "fastq_trim/tooshort/${SID}_R1.fastq.gz"
        File tooShortPairedOutput = "fastq_trim/tooshort/${SID}_R2.fastq.gz"
    }

    parameter_meta {
        SID: {
            type: "id"
        }
        fastqr1: {
            label: "Forward End Read FASTQ File"
        }
        fastqr2: {
            label: "Reverse End Read FASTQ File"
        }
    }

    runtime {
        docker: "${docker}"
        memory: "${memory}GB"
        disks: "local-disk ${disk_space} HDD"
        cpu: "${cpus}"
    }
}
