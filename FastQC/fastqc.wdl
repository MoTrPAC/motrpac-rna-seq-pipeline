task fastQC {
  File fastqr1
  File fastqr2
  
  Int memory
  Int disk_space
  Int num_threads
  Int num_preempt
  String docker

  command {
    mkdir fastqc_report
    fastqc -o fastqc_report ${fastqr1}
    fastqc -o fastqc_report ${fastqr2}

    tar -cvzf fastqc_report.tar.gz ./fastqc_report
  }
  output {
    File fastQC_report = 'fastqc_report.tar.gz'  
  }
  runtime {
    docker: "${docker}"
    memory: "${memory}GB"
    disks: "local-disk ${disk_space} HDD"
    cpu: "${num_threads}"
    preemptible: "${num_preempt}"
  }
}

workflow fastqc_report{  
  Int memory
  Int disk_space
  Int num_threads
  Int num_preempt
  call fastQC{
    input:
    memory=memory,
    disk_space=disk_space,
    num_threads=num_threads,
    num_preempt=num_preempt,
  }
  output {
    fastQC.fastQC_report
  }
}
