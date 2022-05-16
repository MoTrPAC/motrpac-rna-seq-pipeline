version 1.0

task rsem_reference {
    input {
        File reference_fasta
        File annotation_gtf
        String prefix
        Int memory
        Int disk_space
        Int ncpu

    }

    command <<<
        mkdir ~{prefix}
        cd ~{prefix} || exit 126
        rsem-prepare-reference --gtf ~{annotation_gtf} --num-threads ~{ncpu} ~{reference_fasta} rsem_reference
        cd .. && tar -cvzf ~{prefix}.tar.gz ~{prefix}
    >>>

    output {
        File rsem_reference = "${prefix}.tar.gz"
    }

    runtime {
        docker: "gcr.io/***REMOVED***/motrpac-rna-seq-pipeline/rsem:latest"
        memory: "${memory}GB"
        disks: "local-disk ${disk_space} HDD"
        cpu: "${ncpu}"

    }

    meta {
        author: "Archana Raja"
    }
}
