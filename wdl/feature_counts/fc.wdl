version 1.0

#Use version v1.6.3 , currently uses v1.6.2 as specified in the MOP , subtle changes in .out file

task feature_counts {
    input {
        File input_bam
        File gtf_file
        String SID
        Int memory
        Int disk_space
        Int ncpu

        String docker
    }

    command <<<
        set -euo pipefail
        echo "--- $(date "+[%b %d %H:%M:%S]") Beginning task, running featurecounts ---"
        featureCounts -a ~{gtf_file} -o ~{SID}.out -p -M --fraction ~{input_bam}

        echo "$(date "+[%b %d %H:%M:%S]") Finished featurecounts"
        ls -ltr

        echo "--- $(date "+[%b %d %H:%M:%S]") Finished task ---"
    >>>

    output {
        File fc_out = "${SID}.out"
        File fc_summary = "${SID}.out.summary"
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
