task rnaseqc_aggregate {

    Array[File] rpkm_gcts
    Array[File] count_gcts
    Array[File] exon_count_gcts
    Array[File] metrics_tsvs
    String prefix

    Int memory
    Int disk_space
    Int num_threads
    Int num_preempt

    command {
        set -euo pipefail
        echo $(date +"[%b %d %H:%M:%S] Combining RPKM GCTs")
        python3 /src/combine_GCTs.py ${write_lines(rpkm_gcts)} "${prefix}.rnaseqc_rpkm"
        echo $(date +"[%b %d %H:%M:%S] Combining count GCTs")
        python3 /src/combine_GCTs.py ${write_lines(count_gcts)} "${prefix}.rnaseqc_counts"
        echo $(date +"[%b %d %H:%M:%S] Combining exon count GCTs")
        python3 /src/combine_GCTs.py ${write_lines(exon_count_gcts)} "${prefix}.rnaseqc_exon_counts"
        echo $(date +"[%b %d %H:%M:%S] Combining metrics")
        python3 /src/aggregate_rnaseqc_metrics.py ${write_lines(metrics_tsvs)} ${prefix}
    }

    output {
        File rpkm_gct="${prefix}.rnaseqc_rpkm.gct.gz"
        File count_gct="${prefix}.rnaseqc_counts.gct.gz"
        File exon_count_gct="${prefix}.rnaseqc_exon_counts.gct.gz"
        File metrics="${prefix}.metrics.tsv"
    }

    runtime {
        docker: "gcr.io/broad-cga-francois-gtex/gtex_rnaseq:V8"
        memory: "${memory}GB"
        disks: "local-disk ${disk_space} HDD"
        cpu: "${num_threads}"
        preemptible: "${num_preempt}"
    }

    meta {
        author: "Francois Aguet"
    }
}


workflow rnaseqc_aggregate_workflow {
    call rnaseqc_aggregate
}
