task rnaseqQC{
 
  Array[File] multiQCReports

  Int memory
  Int disk_space
  Int num_threads
  Int num_preempt
  String docker
  File script
  File trim_summary
  File mapped_report
  File rRNA_report
  File globin_report
  File phix_report
  File umi_report
  File star_log
  String SID

  command {
    set -eou pipefail
#    mkdir reports
#    cd reports
    for file in ${sep=' ' multiQCReports}  ; do
        tar -zxvf $file
        rm $file
    done


#    cd ..
#    ls reports
    
    python3 ${script} --multiqc_prealign multiQC_prealign_report \
    --multiqc_postalign multiQC_postalign_report \
    ${trim_summary} \
    ${mapped_report} \
    ${rRNA_report} \
    ${globin_report} \
    ${phix_report} \
    ${umi_report} \
    ${star_log}
    touch ${SID}_qc_info.csv
  }
  output {
    File rnaseq_report = "${SID}_qc_info.csv"  
  }
  runtime {
    docker: "${docker}"
    memory: "${memory}GB"
    disks: "local-disk ${disk_space} HDD"
    cpu: "${num_threads}"
    preemptible: "${num_preempt}"
  }
}

workflow rnaseqQC_report{  
  Int memory
  Int disk_space
  Int num_threads
  Int num_preempt
  call rnaseqQC{
    input:
    memory=memory,
    disk_space=disk_space,
    num_threads=num_threads,
    num_preempt=num_preempt,
  }
  output {
    rnaseqQC.rnaseq_report
  }
}
