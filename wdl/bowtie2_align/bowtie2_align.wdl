version 1.0

task bowtie2_align {
    input {
        File fastqr1
        File fastqr2
        File genome_dir_tar
        String genome_dir
        # name of the directory when uncompressed
        String index_prefix = "bowtie2_index"
        String SID
        Int memory
        Int disk_space
        Int ncpu

        String docker
    }

    command <<<
        echo "--- $(date "+[%b %d %H:%M:%S]") Beginning task, making output directories ---"
        mkdir genome

        echo "--- $(date "+[%b %d %H:%M:%S]") Extracting genome tarball ---"
        tar -zxvf ~{genome_dir_tar} -C ./genome

        echo "--- $(date "+[%b %d %H:%M:%S]") Indexing genome ---"
        bowtie2 -p ~{ncpu} -1 ~{fastqr1} -2 ~{fastqr2} -x genome/~{genome_dir}/~{index_prefix} --local -S ~{SID}.sam 2> ~{SID}.log

        echo "--- $(date "+[%b %d %H:%M:%S]") Transforming text ---"
        type=$(echo ~{genome_dir}|awk -F_ '{print $NF}')
        #type=$(echo "${~{genome_dir}##*_}")

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

    meta {
        author: "Archana Raja"
    }
}
