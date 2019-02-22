task collectrnaseqmetrics {

    File input_bam
    File ref_flat
    String prefix

    Int memory
    Int disk_space
    Int num_threads
    Int num_preempt

    command {
        set -euo pipefail
        filename="$(basename -s .bam ${input_bam})"

        java -Xmx10g -jar /src/picard/picard.jar CollectRnaSeqMetrics \
            I=${input_bam} \
            O=$filename.RNA_Metrics \
            REF_FLAT=${ref_flat}\
            STRAND=FIRST_READ_TRANSCRIPTION_STRAND

        ls -ltr
    }

    output {
        File rnaseqmetrics = glob("*.RNA_Metrics")[0]
#        Array[File] output_results= glob('*')
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


workflow collectrnaseqmetrics_workflow {
    call collectrnaseqmetrics
}
