task attachUMI {
  File fastqr1
  File fastqr2
  File fastqi1
  String SID
  String docker
  String script
  # Runtime Attributes
  Int memory
  Int disk_space
  Int num_threads
  Int num_preempt

  command {
    mkdir fastq_attach
    zcat ${fastqr1} | ${script} -v Ifq=${fastqi1} |
    gzip -c > "fastq_attach/${SID}_R1.fastq.gz"

    zcat ${fastqr2}| ${script} -v Ifq=${fastqi1} |
    gzip -c > "fastq_attach/${SID}_R2.fastq.gz"

  }
  output {
    File r1_umi_attached= "fastq_attach/${SID}_attached_R1.fastq.gz"
    File r2_umi_attached= "fastq_attach/${SID}_attached_R2.fastq.gz"
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

workflow attach_umi{  
  Int memory
  Int disk_space
  Int num_threads
  Int num_preempt
  String docker

  call attachUMI{
    input:
    memory=memory,
    disk_space=disk_space,
    num_threads=num_threads,
    num_preempt=num_preempt,
    docker=docker
  }
  output {
    attachUMI.r1_umi_attached
    attachUMI.r2_umi_attached
  }
}
