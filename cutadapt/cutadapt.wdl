task Cutadapt {
        String index_adapter
        String univ_adapter
        File fastqr1
        File fastqr2
#        String read1output
#        String read2output
#        String? reportPath
#        String? tooShortOutput
#        String? tooShortPairedOutput
        String sample_prefix
        Int? minimumLength
        Int cores
        Int disk_space
        Int memory
        Int num_preempt

    command {
        set -e -o pipefail
        mkdir -p fastq_trim
        mkdir -p fastq_trim/tooshort
        cutadapt \
        -a ${index_adapter} \
        -A ${univ_adapter} \
        -o fastq_trim/${sample_prefix}_R1.fastq \
        -p fastq_trim/${sample_prefix}_R2.fastq \
        -m ${minimumLength} \
        --too-short-output fastq_trim/tooshort/${sample_prefix}_R1.fastq \
        --too-short-paired-output fastq_trim/tooshort/${sample_prefix}_R2.fastq \
        ${fastqr1} ${fastqr2} > "${sample_prefix}_report.log"
    }

    output{
        File fastq_trimmed_R1="fastq_trim/${sample_prefix}_R1.fastq"
        File fastq_trimmed_R2="fastq_trim/${sample_prefix}_R2.fastq"
#        File report = "${sample_prefix}.log"
        File tooShortOutput="fastq_trim/tooshort/${sample_prefix}_R1.fastq"
        File tooShortPairedOutput="fastq_trim/tooshort/${sample_prefix}_R2.fastq"
    }

    runtime {
        docker: "akre96/motrpac_rnaseq:v0.1"
        memory: "${memory}GB"
        disks: "local-disk ${disk_space} HDD"
        cpu: "${cores}"
        preemptible: "${num_preempt}"

    }
}
workflow Cutadapt_workflow {
    call Cutadapt
}
