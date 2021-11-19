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

task gather_checksums {
    Array[File] files
    Int memory = 8
    Int disk_space = 8
    Int num_threads = 1
    Int num_preempt = 0
    
     
     command <<<
         set -eou pipefail
         cat ${sep=" " files} >>tmp_checksums.txt
         awk '{print $1}' tmp_checksums.txt >1.txt
         awk '{print $2}' tmp_checksums.txt |awk -F "/" '{print $8}' >2.txt
         paste 1.txt 2.txt |awk '{print $1,$2}'|sort -k2,2 >md5sum_bic.txt
     >>>

     output {
        File merged_output = "md5sum_bic.txt"
     }
    
    runtime {
       docker:"gcr.io/motrpac-portal/motrpac_rnaseq:v0.1_04_20_19"
       memory: "${memory}GB"
       disks: "local-disk ${disk_space} HDD"
       cpu: "${num_threads}"
       preemptible: "${num_preempt}"
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
    call gather_checksums {
    input: files=checksum.md5sum_output
    }
}
