version 1.0

task rsem {
    input {
        File transcriptome_bam
        File rsem_reference
        String SID
        Int memory
        Int disk_space
        Int num_threads
        Int num_preempt
        String docker
    }

    command <<<
        set -euo pipefail
        mkdir rsem_reference
        echo "$(date "+[%b %d %H:%M:%S]") Extracting rsem_reference"
        tar -xzvf ~{rsem_reference} -C rsem_reference --strip-components=1
        echo "$(date "+[%b %d %H:%M:%S]") Done tar"

        cd rsem_reference
        echo "--- Running: ls --- "
        ls
        echo "--- $(date "+[%b %d %H:%M:%S]") Running: rsem-calculate-expression --- "
        rsem-calculate-expression \
            -p ~{num_threads} \
            --bam \
            --paired-end \
            --no-bam-output \
            --forward-prob 0.5 \
            --seed 12345 \
            ~{transcriptome_bam}\
            rsem_reference \
            ~{SID}
        echo "--- $(date "+[%b %d %H:%M:%S]") Done: rsem-calculate-expression --- "
        ls
        echo "--- $(date "+[%b %d %H:%M:%S]") Finished task --- "
    >>>

    output {
        File genes = "rsem_reference/${SID}.genes.results"
        File isoforms = "rsem_reference/${SID}.isoforms.results"
        File stat_cnt = "rsem_reference/${SID}.stat/${SID}.cnt"
        File stat_model = "rsem_reference/${SID}.stat/${SID}.model"
        File stat_theta = "rsem_reference/${SID}.stat/${SID}.theta"
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
