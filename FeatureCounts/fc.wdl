task featurecounts {

    File input_bam
    File gtf_file
    String prefix

    Int memory
    Int disk_space
    Int num_threads
    Int num_preempt
    String docker

    command {
        set -euo pipefail
        featureCounts -a ${gtf_file} -o ${prefix}.out -p -M --fraction ${input_bam}
        ls -ltr
    }

    output {
        File fc_out = "${prefix}.out"
        File fc_summary = "${prefix}.out.summary"
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


workflow featurecounts_workflow {
    call featurecounts
}
