import "FastQC/fastqc.wdl" as fastqc
import "fastq_attach/attach_UMI.wdl" as attach_umi
import "fastq_trim/cutadapt.wdl" as cutadapt
import "MultiQC/multiqc.wdl" as multiqc
import "star_align/star.wdl" as star
import "FeatureCounts/fc.wdl" as fc
import "rsem_exp/rsem.wdl" as rsem
import "bowtie2_align/bowtie2_align.wdl" as bowtie2_align
import "mark_duplicates/markduplicates.wdl" as markdup
import "rnaseq_metrics/collectrnaseqmetrics.wdl" as metrics
import "dup_umi/UMI_dup.wdl" as umi_dup

workflow rnaseq_pipeline{
  # Default values for runtime, changed in individual calls according to requirements
  Int memory
  Int disk_space
  Int num_threads
  Int num_preempt
  String docker
  Int cpus
  File fastqr1
  File fastqr2
  File fastqi1
  String SID
  String index_adapter
  String univ_adapter
  Int minimumLength

  call fastqc.fastQC as preTrimFastQC {
    input:
    memory=20,
    disk_space=20,
    num_threads=1,
    num_preempt=0,
    docker=docker,
    fastqr1=fastqr1,
    fastqr2=fastqr2
  }

  call attach_umi.attachUMI as aumi {
    input :
    memory=20,
    disk_space=30,
    num_threads=1,
    num_preempt=0,
    docker=docker,
    SID=SID,
    fastqr1=fastqr1,
    fastqr2=fastqr2,
    fastqi1=fastqi1
  }

  call cutadapt.Cutadapt as cutadapt {
    input :
    memory=45,
    disk_space=50,
    cpus=1,
    num_preempt=0,
    docker=docker,
    index_adapter=index_adapter,
    univ_adapter=index_adapter,
    SID=SID,
    fastqr1=aumi.r1_umi_attached,
    fastqr2=aumi.r2_umi_attached,
    minimumLength=minimumLength
  }
  call fastqc.fastQC as postTrimFastQC {
    input :
    memory=30,
    disk_space=50,
    num_threads=1,
    num_preempt=0,
    docker=docker,
    fastqr1=cutadapt.fastq_trimmed_R1,
    fastqr2=cutadapt.fastq_trimmed_R2
  }
  call multiqc.multiQC as mqc {
    input :
    memory=20,
    disk_space=20,
    num_threads=1,
    num_preempt=0,
    docker=docker,
    fastQCReports=[preTrimFastQC.fastQC_report,postTrimFastQC.fastQC_report],
    trim_report=cutadapt.report
 }

  call star.star as star_align {
    input :
    memory=50,
    disk_space=100,
    num_threads=10,
    num_preempt=0,
    docker=docker,
    prefix=SID,
    fastq1=cutadapt.fastq_trimmed_R1,
    fastq2=cutadapt.fastq_trimmed_R2,
 }

  call fc.featurecounts as featurecounts {
    input :
    memory=30,
    disk_space=50,
    num_threads=1,
    num_preempt=0,
    docker=docker,
    SID=SID,
    input_bam=star_align.bam_file
 }

  call rsem.rsem as rsem_quant {
    input :
    memory=50,
    disk_space=100,
    num_threads=10,
    num_preempt=0,
    docker=docker,
    prefix=SID,
    transcriptome_bam=star_align.transcriptome_bam
 }

  call bowtie2_align.bowtie2_align as bowtie2_rrna {
    input :
    memory=45,
    disk_space=50,
    num_threads=10,
    num_preempt=0,
    docker=docker,
    SID=SID,
    fastqr1=cutadapt.fastq_trimmed_R1,
    fastqr2=cutadapt.fastq_trimmed_R2
}

  call bowtie2_align.bowtie2_align as bowtie2_globin {
    input :
    memory=45,
    disk_space=50,
    num_threads=10,
    num_preempt=0,
    docker=docker,
    SID=SID,
    fastqr1=cutadapt.fastq_trimmed_R1,
    fastqr2=cutadapt.fastq_trimmed_R2
}

call bowtie2_align.bowtie2_align as bowtie2_phix {
    input :
    memory=45,
    disk_space=50,
    num_threads=10,
    num_preempt=0,
    docker=docker,
    SID=SID,
    fastqr1=cutadapt.fastq_trimmed_R1,
    fastqr2=cutadapt.fastq_trimmed_R2
} 

  call markdup.markduplicates as md {
  input :
  num_threads=10,
  memory=30,
  disk_space=50,
  num_preempt=0,
  docker=docker,
  SID=SID,
  input_bam=star_align.bam_file
}
  call metrics.collectrnaseqmetrics as rnametrics {
  input :
  num_threads=10,
  memory=40,
  disk_space=100,
  num_preempt=0,
  docker=docker,
  SID=SID,
  input_bam=star_align.bam_file
}
  call umi_dup.UMI_dup as udup {
  input :
  num_threads=8,
  memory=50,
  disk_space=50,
  num_preempt=0,
  docker=docker,
  sample_prefix=SID,
  star_align=star_align.bam_file
}
}

