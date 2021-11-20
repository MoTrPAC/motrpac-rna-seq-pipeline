version 1.0

#Use version v1.6.3 , currently uses v1.6.2 as specified in the MOP , subtle changes in .out file

task featurecounts {
    input {
        File input_bam
        File gtf_file
        String SID
        Int memory
        Int disk_space
        Int num_threads
        Int num_preempt
        String docker
    }

    command <<<
        set -euo pipefail
        featureCounts -a ~{gtf_file} -o ~{SID}.out -p -M --fraction ~{input_bam}
        ls -ltr
    >>>

    output {
        File fc_out = "${SID}.out"
        File fc_summary = "${SID}.out.summary"
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
