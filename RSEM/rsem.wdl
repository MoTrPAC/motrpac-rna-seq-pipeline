task rsem {

    File transcriptome_bam
    File rsem_reference
    String prefix

    Int memory
    Int disk_space
    Int num_threads
    Int num_preempt

#    Int? max_frag_len
#    String? estimate_rspd
#    String? is_stranded
#    String? paired_end
#    String? seed

    command {
        set -euo pipefail
        mkdir rsem_reference
        echo "--- tar -xzvf of rsem_reference --- "
        tar -xzvf ${rsem_reference} -C rsem_reference --strip-components=1
        echo "--- Done tar --- "

        cd rsem_reference
        echo "--- Running: ls --- "
        ls
        echo "--- Done: ls--- "
        echo "--- Running: rsem-calculate-expression --- "
        rsem-calculate-expression \
            -p ${num_threads} \
            --bam \
            --paired-end \
            --no-bam-output \
            --forward-prob 0.5 \
            --seed 12345 \
            ${transcriptome_bam}\
            rsem_reference \
            ${prefix}
        echo "--- Done: rsem-calculate-expression --- "
        echo "--- Running: ls --- "
        ls
        echo "--- Done: ls --- "
    }

    output {
        File genes="rsem_reference/${prefix}.genes.results"
        File isoforms="rsem_reference/${prefix}.isoforms.results"
    }

    runtime {
        docker: "akre96/motrpac_rnaseq:v0.1"
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
