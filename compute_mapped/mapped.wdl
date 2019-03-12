task samtools_mapped {

    File input_bam
    String SID

    Int memory
    Int disk_space
    Int num_threads
    Int num_preempt
    String docker

    command {
        set -euo pipefail
        samtools view -b -F 0x900 ${input_bam} -o ${SID}_aligned_primary.bam
        samtools index ${SID}_aligned_primary.bam
        samtools idxstats ${SID}_aligned_primary.bam > ${SID}_aligned_chr_info.txt
        rm ${SID}_aligned_primary.bam ${SID}_aligned_primary.bam.bai
    }

    output {
        File aligned_chrinfo = "${SID}_aligned_chr_info.txt"
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


workflow mapped_workflow {
    call samtools_mapped
}

