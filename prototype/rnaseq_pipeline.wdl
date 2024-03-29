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
import "compute_mapped/mapped.wdl" as mapped
import "MultiQC/multiqc_postalign.wdl" as mqc_postalign
import "collect_qc_metrics/collect_qc.wdl" as collect_qc 

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
  File script

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
    SID=SID,
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
  call metrics.collectrnaseqmetrics as rnaqc {
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
call mapped.samtools_mapped as sm {
  input :
  num_threads=1,
  memory=30,
  disk_space=30,
  num_preempt=0,
  docker=docker,
  SID=SID,
  input_bam=star_align.bam_file
}
call mqc_postalign.multiQC_postalign as mqc_pa {
input :
   memory=30,
   disk_space=40,
   num_threads=1,
   num_preempt=0,
   docker=docker,
   fastQCReport=[postTrimFastQC.fastQC_report],
   trim_report=cutadapt.report,
   rnametric_report=rnaqc.rnaseqmetrics,
   md_report=md.metrics,
   star_report=star_align.logs[0],
   rsem_report=rsem_quant.stat_cnt,
   fc_report=featurecounts.fc_summary
}
call collect_qc.rnaseqQC as qc_report {
input :
   memory=10,
   disk_space=20,
   num_threads=1,
   num_preempt=0,
   docker=docker,
   script=script,
   SID=SID,
   multiQCReports=[mqc.multiQC_report,mqc_pa.multiQC_report],
   globin_report=bowtie2_globin.bowtie2_report,
   phix_report=bowtie2_phix.bowtie2_report,
   rRNA_report=bowtie2_rrna.bowtie2_report,
   trim_summary=cutadapt.summary,
   mapped_report=sm.report,
   star_log=star_align.logs[0],
   umi_report=udup.umi_report
}
}

