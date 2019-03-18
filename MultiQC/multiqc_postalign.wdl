#rsem => looks for the file .cnt inside {SID}.stat, fc.summary file
task multiQC_postalign{
  Int memory
  Int disk_space
  Int num_threads
  Int num_preempt
  String docker
  File rsem_report
  File star_report
  File fc_report

  command {
    set -eou pipefail
    mkdir -p reports
    cd reports/
    cp ${rsem_report} ./
    cp ${star_report} ./
    cp ${fc_report} ./
    cd ..
    echo "ls-------"
    ls reports
    mkdir multiQC_report
    multiqc \
      -d \
      -f \
      -o multiQC_postalign_report \
      reports/*
    echo "success"
#      ${rsem_report} ${star_report} ${fc_report}
    tar -czvf multiqc_postalign_report.tar.gz ./multiQC_postalign_report
  }
  output {
    File multiQC_report = 'multiqc_postalign_report.tar.gz'  
  }
  runtime {
    docker: "${docker}"
    memory: "${memory}GB"
    disks: "local-disk ${disk_space} HDD"
    cpu: "${num_threads}"
    preemptible: "${num_preempt}"
  }
}

workflow multiqc_postalign_report{  
  Int memory
  Int disk_space
  Int num_threads
  Int num_preempt
  call multiQC_postalign{
    input:
    memory=memory,
    disk_space=disk_space,
    num_threads=num_threads,
    num_preempt=num_preempt,
  }
  output {
    multiQC_postalign.multiQC_report
  }
}
