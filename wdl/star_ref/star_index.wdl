version 1.0

task star_index {
    input {
        File reference_fasta
        File annotation_gtf
        String prefix
        Int overhang
        Int memory
        Int disk_space
        Int ncpu

    }

    command <<<
        mkdir ~{prefix}
        STAR \
        --runMode genomeGenerate \
        --genomeDir ~{prefix} \
        --genomeFastaFiles ~{reference_fasta} \
        --sjdbGTFfile ~{annotation_gtf} \
        --sjdbOverhang ~{overhang} \
        --runThreadN ~{ncpu}
        tar -cvzf ~{prefix}.tar.gz ~{prefix}
    >>>

    output {
        File star_index = "${prefix}.tar.gz"
    }

    runtime {
        docker: "us-docker.pkg.dev/motrpac-portal/rnaseq/star:latest"
        memory: "${memory}GB"
        disks: "local-disk ${disk_space} HDD"
        cpu: "${ncpu}"

    }

    meta {
        author: "Archana Raja"
    }
}
