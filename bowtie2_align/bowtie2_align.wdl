task bowtie2_align {

#    Array[File] fastq
    File fastqr1
    File fastqr2
    File genome_dir_tar
    String genome_dir # name of the directory when uncompressed
    String index_prefix="bowtie2_index"
    String SID
    Int memory
    Int disk_space
    Int num_threads
    Int num_preempt
    String docker

    command {
        mkdir genome
        tar -zxvf ${genome_dir_tar} -C ./genome
        bowtie2 -p ${num_threads} -1 ${fastqr1} -2 ${fastqr2} -x genome/${genome_dir}/${index_prefix} --local -S ${SID}.sam > ${SID}.log
    }

    output {
        File bowtie2_output = "${SID}.sam"
        File bowtie2_log = "${SID}.log"

    }

    runtime {
        docker: "${docker}"
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
