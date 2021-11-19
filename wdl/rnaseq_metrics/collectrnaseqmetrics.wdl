#Change MINIMUM_LENGTH=50 RRNA_FRAGMENT_PERCENTAGE=0.3, present in the shell script was missing in the MOP
task collectrnaseqmetrics {

    File input_bam
    File ref_flat
    String SID

    Int memory
    Int disk_space
    Int num_threads
    Int num_preempt
    String docker
    command {
        set -euo pipefail
        #filename="$(basename -s .bam ${input_bam})"
        mkdir -p qc53
        mkdir -p qc53/log
        java -Xmx${memory}g -jar /src/picard/picard.jar CollectRnaSeqMetrics \
            I=${input_bam} \
            O=qc53/${SID}.RNA_Metrics \
            REF_FLAT=${ref_flat}\
            STRAND=FIRST_READ_TRANSCRIPTION_STRAND \
            MINIMUM_LENGTH=50 \
            RRNA_FRAGMENT_PERCENTAGE=0.3 >& qc53/log/${SID}.log

        ls -ltr
    }

    output {
         File rnaseqmetrics="qc53/${SID}.RNA_Metrics"
         File log="qc53/log/${SID}.log"
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
