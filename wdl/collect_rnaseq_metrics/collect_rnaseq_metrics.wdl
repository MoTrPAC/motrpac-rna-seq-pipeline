version 1.0

#Change MINIMUM_LENGTH=50 RRNA_FRAGMENT_PERCENTAGE=0.3, present in the shell script was missing in the MOP

task collectrnaseqmetrics {
    input {
        File input_bam
        File ref_flat
        String SID
        Int memory
        Int disk_space
        Int ncpu

        String docker
    }

    command <<<
        set -euo pipefail
        echo "--- $(date "+[%b %d %H:%M:%S]") Beginning task, making output directories ---"
        mkdir -p qc53
        mkdir -p qc53/log

        echo "--- $(date "+[%b %d %H:%M:%S]") Running Picard collect metrics ---"
        java -Xmx~{memory}g -jar /usr/local/bin/picard.jar CollectRnaSeqMetrics \
            I=~{input_bam} \
            O=qc53/~{SID}.RNA_Metrics \
            REF_FLAT=~{ref_flat}\
            STRAND=FIRST_READ_TRANSCRIPTION_STRAND \
            MINIMUM_LENGTH=50 \
            RRNA_FRAGMENT_PERCENTAGE=0.3 >& qc53/log/~{SID}.log

        ls -la qc53

        echo "--- $(date "+[%b %d %H:%M:%S]") Task complete ---"
    >>>

    output {
        File rnaseqmetrics = "qc53/${SID}.RNA_Metrics"
        File log = "qc53/log/${SID}.log"
    }

    runtime {
        docker: "${docker}"
        memory: "${memory}GB"
        disks: "local-disk ${disk_space} HDD"
        cpu: "${ncpu}"

    }

    meta {
        author: "Archana Raja"
    }
}
