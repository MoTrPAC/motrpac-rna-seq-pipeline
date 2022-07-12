version 1.0

task fastQC {
    input {
        File fastqr1
        File fastqr2

        String outdir

        Int memory
        Int disk_space
        Int ncpu

        String docker
    }

    command <<<
        echo "--- $(date "+[%b %d %H:%M:%S]") Beginning task, creating output directory ---"
        mkdir -p ~{outdir}

        echo "--- $(date "+[%b %d %H:%M:%S]") Running fastqc on fastq files ---"
        fastqc -o ~{outdir} ~{fastqr1}
        fastqc -o ~{outdir} ~{fastqr2}

        echo "--- $(date "+[%b %d %H:%M:%S]") Finished fastqc on fastq files, creating output tarball ---"
        tar -cvzf ~{outdir}.tar.gz ./~{outdir}

        echo "--- $(date "+[%b %d %H:%M:%S]") Finished creating output tarball, task complete ---"
    >>>

    output {
        File fastQC_report = '${outdir}.tar.gz'
    }

    parameter_meta {
        fastqr1: {
            label: "Forward End Read FASTQ File"
        }
        fastqr2: {
            type: "Reverse End Read FASTQ File"
        }
    }

    runtime {
        docker: "${docker}"
        memory: "${memory}GB"
        disks: "local-disk ${disk_space} HDD"
        cpu: "${ncpu}"
    }
}
