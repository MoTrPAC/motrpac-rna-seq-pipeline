#rsem => looks for the file .cnt inside {SID}.stat, fc.summary file
task multiQC_postalign{
  Int memory
  Int disk_space
  Int num_threads
  Int num_preempt
  String docker
  Array[File] fastQCReport
  File trim_report
  File rsem_report
  File star_report
  File fc_report
  File md_report
  File rnametric_report

  command {
    set -eou pipefail
    mkdir -p reports
    cd reports/
    for file in ${sep=' ' fastQCReport}  ; do
        tar -zxvf $file
        rm $file
    done
    cp ${trim_report} ./
    cp ${rsem_report} ./
    cp ${star_report} ./
    cp ${fc_report} ./
    cp ${md_report} ./
    cp ${rnametric_report} ./
    cd ..

    echo "ls-------"
    ls reports
    mkdir multiQC_report
    multiqc \
      -f \
      -o multiQC_postalign_report \
      reports/*
    echo "success"
    
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
