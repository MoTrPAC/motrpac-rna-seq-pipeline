task rsem {

    File transcriptome_bam
    File rsem_reference
    String prefix

    Int memory
    Int disk_space
    Int num_threads
    Int num_preempt

    Int? max_frag_len
    String? estimate_rspd
    String? is_stranded
    String? paired_end
    String? seed
    File script

    command {
        set -euo pipefail
        mkdir rsem_reference
        tar -xvvf ${rsem_reference} -C rsem_reference --strip-components=1

        python3 ${script} \
            ${"--max_frag_len " + max_frag_len} \
            ${"--estimate_rspd " + estimate_rspd} \
            ${"--is_stranded " + is_stranded} \
            ${"--paired_end " + paired_end} \
            ${"--seed " + seed} \
            --threads ${num_threads} \
            rsem_reference ${transcriptome_bam} ${prefix}
    }

    output {
        File genes="${prefix}.rsem.genes.results"
        File isoforms="${prefix}.rsem.isoforms.results"
    }

    runtime {
        docker: "gcr.io/broad-cga-francois-gtex/gtex_rnaseq:V8"
        memory: "${memory}GB"
        disks: "local-disk ${disk_space} HDD"
        cpu: "${num_threads}"
        preemptible: "${num_preempt}"
    }

    meta {
        author: "Archana Raja"
    }
}


workflow rsem_workflow {
    call rsem
}
