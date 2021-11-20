version 1.1

task attachUMI {
  input {
    File fastqr1
    File fastqr2
    File fastqi1
    String SID

    # Runtime Attributes
    Int memory
    Int disk_space
    Int num_threads
    Int num_preempt
    String docker
  }

  command <<<
        mkdir fastq_attach

        zcat ~{fastqr1} | UMI_attach.awk -v Ifq=~{fastqi1} | gzip -c > "fastq_attach/~{SID}_R1.fastq.gz"
        zcat ~{fastqr2}| UMI_attach.awk -v Ifq=~{fastqi1} | gzip -c > "fastq_attach/~{SID}_R2.fastq.gz"
  >>>

  output {
    File r1_umi_attached = "fastq_attach/${SID}_R1.fastq.gz"
    File r2_umi_attached = "fastq_attach/${SID}_R2.fastq.gz"
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