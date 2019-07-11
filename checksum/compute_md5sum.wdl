task checksum {

    Int memory
    Int disk_space
    Int num_threads
    Int num_preempt
    String docker
    File fastq
    command <<<
        set -euo pipefail
        md5sum ${fastq} >>checksums_sample.txt 
        touch checksums_sample.txt
    >>>

    output {
        File md5sum_output = "checksums_sample.txt"
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


workflow checksum_workflow {
    Array[File] sample_files=[]
    scatter (i in range(length(sample_files))) {
      call checksum {
      input:
      fastq=sample_files[i]

      } 
    }
}
