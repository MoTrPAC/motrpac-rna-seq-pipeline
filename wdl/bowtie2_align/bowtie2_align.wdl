task bowtie2_align {

    File fastqr1
    File fastqr2
    File genome_dir_tar
    String genome_dir # name of the directory when uncompressed
    String index_prefix="bowtie2_index"
    String SID
    Int memory
    Int disk_space
    Int num_threads
    Int num_preempt
    String docker

    command <<<
        mkdir genome
        tar -zxvf ${genome_dir_tar} -C ./genome
        bowtie2 -p ${num_threads} -1 ${fastqr1} -2 ${fastqr2} -x genome/${genome_dir}/${index_prefix} --local -S ${SID}.sam 2> ${SID}.log
#        type=$(echo ${genome_dir}|awk '{print substr($1,4)}')
        type=$(echo ${genome_dir}|sed 's/rn_//1')
        tail -n1 ${SID}.log |awk -v id=${SID} -v kind=$type '{print "Sample""\t""pct_"kind"\n"id"\t"$1}' > ${SID}_${genome_dir}_report.txt
    >>>

    output {
        File bowtie2_output = "${SID}.sam"
        File bowtie2_log = "${SID}.log"
        File bowtie2_report="${SID}_${genome_dir}_report.txt"

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


workflow bowtie2_align_workflow {
    call bowtie2_align
}
