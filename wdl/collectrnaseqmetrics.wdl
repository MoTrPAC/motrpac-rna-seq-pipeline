task collectrnaseqmetrics {

    File input_bam
    File ref_flat
    File script
    String prefix

    Int memory
    Int disk_space
    Int num_threads
    Int num_preempt

    #String output_metrics = sub(basename(input_bam), "\\.bam$", ".RNA_metrics")

    command {
        set -euo pipefail
        python3 -u ${script} ${input_bam} ${prefix} ${ref_flat} --memory ${memory}
        ls -ltr
    }

    output {
        #File rnaseq_metrics="${output_metrics}"
        File rnaseqmetrics = glob("*.RNA_Metrics")[0]
        Array[File] output_results= glob('*')
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


workflow collectrnaseqmetrics_workflow {
    call collectrnaseqmetrics
}
