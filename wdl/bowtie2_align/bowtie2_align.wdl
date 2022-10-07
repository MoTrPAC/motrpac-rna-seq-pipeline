version 1.0

task bowtie2_align {
    input {
        String SID
        File fastqr1
        File fastqr2
        File genome_dir_tar

        String index_prefix = "bowtie2_index"
        Int memory
        Int disk_space
        Int ncpu

        String docker
    }

    String genome_dir = basename(genome_dir_tar, ".tar.gz")

    command <<<
        echo "--- $(date "+[%b %d %H:%M:%S]") Beginning task, making output directories ---"
        mkdir -p ./genome/~{genome_dir}

        echo "--- $(date "+[%b %d %H:%M:%S]") Extracting genome tarball into ./genome/~{genome_dir} ---"
        tar -zxvf ~{genome_dir_tar} -C ./genome/~{genome_dir} --strip-components 1

        echo "--- $(date "+[%b %d %H:%M:%S]") Indexing genome ---"
        bowtie2 -p ~{ncpu} -1 ~{fastqr1} -2 ~{fastqr2} -x genome/~{genome_dir}/~{index_prefix} --local -S ~{SID}.sam 2> ~{SID}.log

        echo "--- $(date "+[%b %d %H:%M:%S]") Transforming text ---"
        type=$(echo ~{genome_dir}|awk -F_ '{print $NF}')

        echo "--- $(date "+[%b %d %H:%M:%S]") Extracting report ---"
        tail -n1 ~{SID}.log |awk -v id=~{SID} -v kind="$type" '{print "Sample""\t""pct_"kind"\n"id"\t"$1}' > "~{SID}_~{genome_dir}_report.txt"

        echo "--- $(date "+[%b %d %H:%M:%S]") Finished task ---"
    >>>

    output {
        File bowtie2_output = "${SID}.sam"
        File bowtie2_log = "${SID}.log"
        File bowtie2_report = "${SID}_${genome_dir}_report.txt"
    }

    runtime {
        docker: "${docker}"
        memory: "${memory}GB"
        disks: "local-disk ${disk_space} HDD"
        cpu: "${ncpu}"
    }

    parameter_meta {
        SID: {
            type: "id"
        }
        fastqr1: {
            label: "Forward End Read FASTQ File"
        }
        fastqr2: {
            label: "Reverse End Read FASTQ File"
        }
        genome_dir_tar: {
            label: "Bowtie2 Reference Tarball File"
        }
    }

    meta {
        author: "Archana Raja"
    }
}
