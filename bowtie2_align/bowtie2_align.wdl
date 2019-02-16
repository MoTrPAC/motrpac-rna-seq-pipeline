task bowtie2_align {

#    Array[File] fastq
    File fastq_r1
    File fastq_r2
    File genome_dir_tar
    String genome_dir # name of the directory when uncompressed
    String index_prefix="bowtie2_index"
    String sample_prefix
    Int memory
    Int disk_space
    Int num_threads
    Int num_preempt
#    File samfile
#    File log_file

    command {
        mkdir genome
        tar -zxvf ${genome_dir_tar} -C ./genome
        bowtie2 -p ${num_threads} -1 ${fastq_r1} -2 ${fastq_r2} -x genome/${genome_dir}/${index_prefix} --local -S ${sample_prefix}.sam > ${sample_prefix}.log
    }

    output {
        File bowtie2_output = "${sample_prefix}.sam"
        File bowtie2_log = "${sample_prefix}.log"

    }

    runtime {
        docker: "akre96/motrpac_rrbs:v0.1"
	memory: "${memory}GB"
        disks: "local-disk ${disk_space} HDD"
        cpu: "${num_threads}"
        preemptible: "${num_preempt}"
    }

    meta {
        author: "Archana Raja"
    }
}


workflow bowtie2_align_workflow {
    call bowtie2_align
}
