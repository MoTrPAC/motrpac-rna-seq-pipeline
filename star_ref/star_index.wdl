#compressing the index folder is the only way to capture all the files , otherwise all the output files should be declared in Output

task star_index {

    File reference_fasta
    File annotation_gtf
    String prefix
    Int overhang

    Int memory
    Int disk_space
    Int num_threads
    Int num_preempt

    command {
        mkdir ${prefix}
	STAR \
            --runMode genomeGenerate \
            --genomeDir ${prefix} \
            --genomeFastaFiles ${reference_fasta} \
            --sjdbGTFfile ${annotation_gtf} \
            --sjdbOverhang ${overhang} \
            --runThreadN ${num_threads}
            tar -cvzf ${prefix}.tar.gz ${prefix}
    }

    output {
         File star_index = "${prefix}.tar.gz"
#        File star_index = "${prefix}/Genome"
    }

    runtime {
        docker: "gcr.io/***REMOVED***/motrpac_rnaseq:v0.1_04_20_19"
        memory: "${memory}GB"
        disks: "local-disk ${disk_space} HDD"
        cpu: "${num_threads}"
        preemptible: "${num_preempt}"
    }

    meta {
        author: "Archana Raja"
    }
}


workflow star_index_workflow {
    call star_index
}
