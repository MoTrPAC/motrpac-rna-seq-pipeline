task bowtie2_index {

    File reference_fasta
    String prefix

    Int memory
    Int disk_space
    Int num_threads
    Int num_preempt

    command {
        mkdir ${prefix}
        bowtie2-build ${reference_fasta} ${prefix}/bowtie2_index
        ls ${prefix}
        tar -cvzf ${prefix}.tar.gz ${prefix}
    }

    output {
        File bowtie2_index = "${prefix}.tar.gz"
    }

    runtime {
        docker: "gcr.io/motrpac-portal/motrpac_rnaseq:v0.1_04_20_19"
	memory: "${memory}GB"
        disks: "local-disk ${disk_space} HDD"
        cpu: "${num_threads}"
        preemptible: "${num_preempt}"
    }

    meta {
        author: "Archana Raja"
    }
}


workflow bowtie2_index_workflow {
    call bowtie2_index
}
