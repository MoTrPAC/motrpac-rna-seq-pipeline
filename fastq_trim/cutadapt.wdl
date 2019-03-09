task Cutadapt {
        String index_adapter
        String univ_adapter
        File fastqr1
        File fastqr2
        String SID
        Int? minimumLength
        Int cpus
        Int disk_space
        Int memory
        Int num_preempt
        String docker

    command {
        set -e -o pipefail
        mkdir -p fastq_trim
        mkdir -p fastq_trim/tooshort
        cutadapt \
        -a ${index_adapter} \
        -A ${univ_adapter} \
        -o fastq_trim/${SID}_R1.fastq.gz \
        -p fastq_trim/${SID}_R2.fastq.gz \
        -m ${minimumLength} \
        --too-short-output fastq_trim/tooshort/${SID}_R1.fastq.gz \
        --too-short-paired-output fastq_trim/tooshort/${SID}_R2.fastq.gz \
        ${fastqr1} ${fastqr2} > "fastq_trim/${SID}_report.log"
    }

    output{
        File fastq_trimmed_R1="fastq_trim/${SID}_R1.fastq.gz"
        File fastq_trimmed_R2="fastq_trim/${SID}_R2.fastq.gz"
        File report="fastq_trim/${SID}_report.log"
        File tooShortOutput="fastq_trim/tooshort/${SID}_R1.fastq.gz"
        File tooShortPairedOutput="fastq_trim/tooshort/${SID}_R2.fastq.gz"
    }

    runtime {
        docker: "${docker}"
        memory: "${memory}GB"
        disks: "local-disk ${disk_space} HDD"
        cpu: "${cpus}"
        preemptible: "${num_preempt}"

    }
}
workflow Cutadapt_workflow {
    call Cutadapt
}