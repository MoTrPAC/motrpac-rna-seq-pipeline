version 1.0

task star {
    input {
        String prefix
        File star_index
        File fastq1
        File fastq2
        # STAR options
        String outFilterType = "BySJout"
        String outSAMtype = "BAM SortedByCoordinate"
        String quantMode = "TranscriptomeSAM"
        String outSAMattributes = "NH HI AS NM MD nM"
        Int memory
        Int disk_space
        Int num_threads
        Int num_preempt
        String docker
    }

    command <<<
        set -euo pipefail
        FASTQ_1_ABS=~{fastq1}
        FASTQ_2_ABS=~{fastq2}

        echo "FASTQs:"
        echo "$FASTQ_1_ABS"
        echo "$FASTQ_2_ABS"

        # extract index
        echo "--- $(date "+[%b %d %H:%M:%S]") Extracting STAR index ---"
        mkdir star_index
        tar -xvvf ~{star_index} -C star_index --strip-components=1
        echo "--- $(date "+[%b %d %H:%M:%S]")" Done extracting index

        mkdir star_out
        echo "--- $(date "+[%b %d %H:%M:%S]") Running STAR ---"
        STAR  --genomeDir star_index \
            --readFilesIn "$FASTQ_1_ABS" "$FASTQ_2_ABS" \
            --outFileNamePrefix star_out/~{prefix}. \
            --readFilesCommand zcat \
            --outSAMattributes ~{outSAMattributes} \
            --outFilterType ~{outFilterType} \
            --runThreadN ~{num_threads} \
            --outSAMtype ~{outSAMtype} \
            --quantMode ~{quantMode}

        cd star_out
        ls

        echo "--- $(date "+[%b %d %H:%M:%S]") Running samtools index ---"
        samtools index ~{prefix}.Aligned.sortedByCoord.out.bam

        echo "--- $(date "+[%b %d %H:%M:%S]") Finished running samtools index ---"
        ls
        echo "--- $(date "+[%b %d %H:%M:%S]") Completed task ---"
    >>>

    output {
        File bam_file = "star_out/${prefix}.Aligned.sortedByCoord.out.bam"
        File bam_index = "star_out/${prefix}.Aligned.sortedByCoord.out.bam.bai"
        File transcriptome_bam = "star_out/${prefix}.Aligned.toTranscriptome.out.bam"
        File junctions = "star_out/${prefix}.SJ.out.tab"
        Array[File] logs = [
            "star_out/${prefix}.Log.final.out",
            "star_out/${prefix}.Log.out",
            "star_out/${prefix}.Log.progress.out"
        ]
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
