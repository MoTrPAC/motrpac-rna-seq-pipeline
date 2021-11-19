task UMI_dup {
    File star_align
    String sample_prefix
    String docker
    # Runtime Attributes
    Int memory
    Int disk_space
    Int num_threads
    Int num_preempt

    command <<<
        set -euo pipefail
        mkdir tmp_dir
        nudup.py -2 -s 8 -l 8 --rmdup-only -o ${sample_prefix} -T tmp_dir ${star_align} > ${sample_prefix}.out
        touch UMI_dup.log ${sample_prefix}.out
        grep "Molecular tag dups count" ${sample_prefix}.out |awk -F "(" '{print $2}'|awk -v id=${sample_prefix} '{print "Sample""\t""pct_umi_dup""\n"id"\t"($1*100)}' >"${sample_prefix}_umi_report.txt"
    >>>
    output {
        File umi_dup_out="UMI_dup.log"
        File umi_out="${sample_prefix}.out"
        File umi_report= "${sample_prefix}_umi_report.txt"
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