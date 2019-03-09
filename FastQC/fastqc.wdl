task fastQC {
  File fastqr1
  File fastqr2
  String outdir  
  Int memory
  Int disk_space
  Int num_threads
  Int num_preempt
  String docker

  command {
    mkdir -p ${outdir}
    fastqc -o ${outdir} ${fastqr1}
    fastqc -o ${outdir} ${fastqr2}

    tar -cvzf ${outdir}.tar.gz ./${outdir}
  }
  output {
    File fastQC_report = '${outdir}.tar.gz'  
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
  String outdir
  call fastQC{
    input:
    memory=memory,
    disk_space=disk_space,
    num_threads=num_threads,
    num_preempt=num_preempt,
    outdir=outdir
  }
  output {
    fastQC.fastQC_report
  }
}
