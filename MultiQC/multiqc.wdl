task multiQC{
#  Array[File] fastQCReports
#  Array[File] cutadaptReports
#  Array[File] fastQCReports_trim
#  String fastQC_raw_path
  String fastQC_trim_path
  String cutadapt_dir_path
  Int memory
  Int disk_space
  Int num_threads
  Int num_preempt
  String docker

  command {
    mkdir multiQC_report
    multiqc \
      -d \
      -f \
      -n multiQC_consolidated \
      -o multiQC_report \
      ${fastQC_trim_path} ${cutadapt_dir_path}
    tar -czvf multiqc_report.tar.gz ./multiQC_report
  }
  output {
    File multiQC_report = 'multiqc_report.tar.gz'  
  }
  runtime {
    docker: "${docker}"
    memory: "${memory}GB"
    disks: "local-disk ${disk_space} HDD"
    cpu: "${num_threads}"
    preemptible: "${num_preempt}"
  }
}

workflow multiqc_report{  
  Int memory
  Int disk_space
  Int num_threads
  Int num_preempt
  call multiQC{
    input:
    memory=memory,
    disk_space=disk_space,
    num_threads=num_threads,
    num_preempt=num_preempt,
  }
  output {
    multiQC.multiQC_report
  }
}
