task star {

    Array[File] fastq
    String prefix
    File star_index

    # STAR options
    Int? outFilterMultimapNmax
    Int? alignSJoverhangMin
    Int? alignSJDBoverhangMin
    Int? outFilterMismatchNmax
    Float? outFilterMismatchNoverLmax
    Int? alignIntronMin
    Int? alignIntronMax
    Int? alignMatesGapMax
    String outFilterType = "BySJout"
    String outSAMtype = "BAM SortedByCoordinate"
    Float? outFilterScoreMinOverLread
    Float? outFilterMatchNminOverLread
    Int? limitSjdbInsertNsj
    String? outSAMstrandField
    String? outFilterIntronMotifs
    String? alignSoftClipAtReferenceEnds
    String? quantMode = "TranscriptomeSAM"
    String? outSAMattrRGline
    String? outSAMattributes
    Int? chimSegmentMin
    Int? chimJunctionOverhangMin
    String? chimOutType
    Int? chimMainSegmentMultNmax
    File script
    Int memory
    Int disk_space
    Int num_threads
    Int num_preempt

    command {
        set -euo pipefail
        #if the length of fastq list is 1 then it is single end , if the length is 2 then it's paired end , removed the newline character
        ${if length(fastq)<2 then "fastq1_abs=" + fastq[0] else "fastq1_abs=" + fastq[0] +"\n"+ "fastq2_abs="+fastq[1]}

        echo "FASTQs:"
        echo $fastq1_abs
        echo $fastq2_abs

        # extract index
        echo $(date +"[%b %d %H:%M:%S] Extracting STAR index")
        mkdir star_index
        tar -xvvf ${star_index} -C star_index --strip-components=1

        mkdir star_out
        python3 ${script} \
            star_index $fastq1_abs $fastq2_abs ${prefix} \
            --output_dir star_out \
            --outFilterType ${outFilterType} \
            --quantMode ${quantMode} \
            ${"--outSAMattributes " + outSAMattributes} \
            --outSAMtype ${outSAMtype} \
            ${"--chimSegmentMin " + chimSegmentMin} \
            ${"--chimJunctionOverhangMin " + chimJunctionOverhangMin} \
            ${"--chimOutType " + chimOutType} \
            ${"--chimMainSegmentMultNmax " + chimMainSegmentMultNmax} \
            --threads ${num_threads}
    }

    output {
        File bam_file = "star_out/${prefix}.Aligned.sortedByCoord.out.bam"
        File bam_index = "star_out/${prefix}.Aligned.sortedByCoord.out.bam.bai"
        File transcriptome_bam = "star_out/${prefix}.Aligned.toTranscriptome.out.bam"
        File chimeric_junctions = "star_out/${prefix}.Chimeric.out.junction"
        File chimeric_bam_file = "star_out/${prefix}.Chimeric.out.sorted.bam"
        File chimeric_bam_index = "star_out/${prefix}.Chimeric.out.sorted.bam.bai"
        #File read_counts = "star_out/${prefix}.ReadsPerGene.out.tab"
        File junctions = "star_out/${prefix}.SJ.out.tab"
        File junctions_pass1 = "star_out/${prefix}._STARpass1/SJ.out.tab"
        Array[File] logs = ["star_out/${prefix}.Log.final.out", "star_out/${prefix}.Log.out", "star_out/${prefix}.Log.progress.out"]
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


workflow star_workflow {
    call star
}
