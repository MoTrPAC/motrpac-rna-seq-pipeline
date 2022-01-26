version 1.0

workflow checksum_workflow {
    input {
        Array[File] sample_files = []
    }

    scatter (i in range(length(sample_files))) {
        call checksum {
            input:
                fastq = sample_files[i]
        }
    }

    call gather_checksums {
        input:
            files = checksum.md5sum_output
    }
}

task checksum {
    input {
        Int memory
        Int disk_space
        Int ncpu

        String docker
        File fastq
    }

    command <<<
        set -euo pipefail
        md5sum ~{fastq} >>checksums_sample.txt
        touch checksums_sample.txt
    >>>

    output {
        File md5sum_output = "checksums_sample.txt"
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

task gather_checksums {
    input {
        Array[File] files
        Int memory = 8
        Int disk_space = 8
        Int ncpu = 1
         = 0
    }

    command <<<
        set -eou pipefail
        cat ~{sep=" " files} >>tmp_checksums.txt
        awk '{print $1}' tmp_checksums.txt >1.txt
        awk '{print $2}' tmp_checksums.txt |awk -F "/" '{print $8}' >2.txt
        paste 1.txt 2.txt |awk '{print $1,$2}'|sort -k2,2 >md5sum_bic.txt
    >>>

    output {
        File merged_output = "md5sum_bic.txt"
    }

    runtime {
        docker: "gcr.io/motrpac-portal/motrpac_rnaseq:v0.1_04_20_19"
        memory: "${memory}GB"
        disks: "local-disk ${disk_space} HDD"
        cpu: "${ncpu}"

    }
}
