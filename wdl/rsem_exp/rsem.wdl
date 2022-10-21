version 1.0

task rsem {
    input {
        String SID
        File transcriptome_bam
        File rsem_reference

        Int memory
        Int disk_space
        Int ncpu

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
            -p ~{ncpu} \
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
        cpu: "${ncpu}"
    }

    parameter_meta {
        SID: {
            type: "id"
        }
        transcriptome_bam: {
            label: "Aligned Transcriptome BAM File"
        }
        rsem_reference: {
            label: "RSEM Genome Reference File"
        }
    }

    meta {
        author: "Archana Raja"
    }
}
