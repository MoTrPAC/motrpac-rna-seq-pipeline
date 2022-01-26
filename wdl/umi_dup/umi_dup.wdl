version 1.0

task UMI_dup {
    input {
        File star_align
        String sample_prefix
        String docker
        # Runtime Attributes
        Int memory
        Int disk_space
        Int ncpu

    }

    command <<<
        set -euo pipefail
        echo "--- $(date "+[%b %d %H:%M:%S]") Beginning task, creating temp folder ---"
        mkdir tmp_dir

        echo "--- $(date "+[%b %d %H:%M:%S]") Running nudup.py script ---"

        python /usr/local/src/nudup.py -2 -s 8 -l 8 --rmdup-only -o ~{sample_prefix} -T tmp_dir ~{star_align} > ~{sample_prefix}.out
        touch UMI_dup.log ~{sample_prefix}.out

        echo "--- $(date "+[%b %d %H:%M:%S]") Finished nudup.py script, extracting report ---"
        grep "Molecular tag dups count" ~{sample_prefix}.out |awk -F "(" '{print $2}'|awk -v id=~{sample_prefix} '{print "Sample""\t""pct_umi_dup""\n"id"\t"($1*100)}' >"~{sample_prefix}_umi_report.txt"

        echo "--- $(date "+[%b %d %H:%M:%S]") Finished extracting report, finished task ---"
    >>>

    output {
        File umi_dup_out = "UMI_dup.log"
        File umi_out = "${sample_prefix}.out"
        File umi_report = "${sample_prefix}_umi_report.txt"
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
