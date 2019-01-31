task featurecounts {

    File input_bam
    File gtf_file
    String prefix

    Int memory
    Int disk_space
    Int num_threads


    command {
        set -euo pipefail
        /Users/archanaraja/work/tools/subread-1.6.3-MacOSX-x86_64/bin/featureCounts -a ${gtf_file} -o /Users/archanaraja/work/repo/RNAseq/test_data/${prefix}.out -p -M --fraction ${input_bam}
        ls -ltr
    }

    output {
        File fc_out = "/Users/archanaraja/work/repo/RNAseq/test_data/A1k_R1_S16.out"
        File fc_summary = "/Users/archanaraja/work/repo/RNAseq/test_data/${prefix}.out.summary"
    }

    runtime {
        disks: "local-disk ${disk_space} HDD"
        cpu: "${num_threads}"
    }

    meta {
        author: "Archana Raja"
    }
}


workflow featurecounts_workflow {
    call featurecounts
}
