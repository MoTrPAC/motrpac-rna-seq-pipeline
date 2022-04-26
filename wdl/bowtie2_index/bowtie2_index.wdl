version 1.0

task bowtie2_index {
    input {
        File reference_fasta
        String prefix
        Int memory
        Int disk_space
        Int ncpu

    }

    command <<<
        mkdir ~{prefix}
        bowtie2-build ~{reference_fasta} ~{prefix}/bowtie2_index
        ls ~{prefix}
        tar -cvzf ~{prefix}.tar.gz ~{prefix}
    >>>

    output {
        File bowtie2_index = "${prefix}.tar.gz"
    }

    runtime {
	#requires python in the image for this step to run successfully
	#docker: "gcr.io/motrpac-portal/motrpac_rnaseq:v0.1_04_20_19"
        docker: "gcr.io/motrpac-portal/motrpac-rna-seq-pipeline/bowtie:latest"
        memory: "${memory}GB"
        disks: "local-disk ${disk_space} HDD"
        cpu: "${ncpu}"

    }

    meta {
        author: "Archana Raja"
    }
}
