#prefix name should be autogenerated from the input bam rather than specifying in the input.json
task markduplicates {

    File input_bam
    String SID

    Int memory
    Int disk_space
    Int num_threads
    Int num_preempt
    String docker

    String output_bam = sub(basename(input_bam), "\\.bam$", ".md.bam")

    command {
        set -euo pipefail
        ulimit -c unlimited
        java -Xmx${memory}g -jar /src/picard/picard.jar  MarkDuplicates \
            I=${input_bam} \
            O= ${output_bam} \
            CREATE_INDEX=true \
            VALIDATION_STRINGENCY=SILENT \
            ASSUME_SORT_ORDER=coordinate \
            M=${SID}.marked_dup_metrics.txt \
            REMOVE_DUPLICATES=false

        samtools index ${output_bam}
    }

    output {
        File bam_file = "${output_bam}"
        File bam_index = "${output_bam}.bai"
        File metrics = "${SID}.marked_dup_metrics.txt"
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


workflow markduplicates_workflow {
    call markduplicates
}
