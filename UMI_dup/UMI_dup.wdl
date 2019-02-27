task UMI_dup {
  File star_align
  String sample_prefix
  File script
  String docker
  # Runtime Attributes
  Int memory
  Int disk_space
  Int num_threads
  Int num_preempt

  command {
    set -euo pipefail
    mkdir tmp_dir
    nudup.py -2 -s 8 -l 8 --rmdup-only -o ${sample_prefix} -T tmp_dir ${star_align}
  }
  output{
#    File umi_dup_out= "${sample_prefix}_dup.txt"
     File umi_dup_out="UMI_dup.log"
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

workflow UMI_qc{  
  call UMI_dup
}
