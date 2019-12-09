import "FastQC/fastqc.wdl" as fastqc
import "fastq_trim/cutadapt.wdl" as cutadapt
import "MultiQC/multiqc.wdl" as multiqc
import "star_align/star.wdl" as star
import "FeatureCounts/fc.wdl" as fc
import "rsem_exp/rsem.wdl" as rsem
import "bowtie2_align/bowtie2_align.wdl" as bowtie2_align
import "mark_duplicates/markduplicates.wdl" as markdup
import "rnaseq_metrics/collectrnaseqmetrics.wdl" as metrics
import "compute_mapped/mapped.wdl" as mapped
import "MultiQC/multiqc_postalign.wdl" as mqc_postalign

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
  String SID
  String index_adapter
  String univ_adapter
  Int minimumLength

  call fastqc.fastQC as postTrimFastQC {
    input :
    memory=30,
    disk_space=50,
    num_threads=1,
    num_preempt=0,
    docker=docker,
    fastqr1=fastqr1,
    fastqr2=fastqr2
  }

  call star.star as star_align {
    input :
    memory=50,
    disk_space=150,
    num_threads=10,
    num_preempt=0,
    docker=docker,
    prefix=SID,
    fastq1=fastqr1,
    fastq2=fastqr2,
 }

  call fc.featurecounts as featurecounts {
    input :
    memory=30,
    disk_space=150,
    num_threads=1,
    num_preempt=0,
    docker=docker,
    SID=SID,
    input_bam=star_align.bam_file
 }

  call rsem.rsem as rsem_quant {
    input :
    memory=50,
    disk_space=150,
    num_threads=10,
    num_preempt=0,
    docker=docker,
    SID=SID,
    transcriptome_bam=star_align.transcriptome_bam
 }

  call bowtie2_align.bowtie2_align as bowtie2_rrna {
    input :
    memory=45,
    disk_space=100,
    num_threads=10,
    num_preempt=0,
    docker=docker,
    SID=SID,
    fastqr1=fastqr1,
    fastqr2=fastqr2
}

  call bowtie2_align.bowtie2_align as bowtie2_globin {
    input :
    memory=45,
    disk_space=100,
    num_threads=10,
    num_preempt=0,
    docker=docker,
    SID=SID,
    fastqr1=fastqr1,
    fastqr2=fastqr2
}

call bowtie2_align.bowtie2_align as bowtie2_phix {
    input :
    memory=45,
    disk_space=100,
    num_threads=10,
    num_preempt=0,
    docker=docker,
    SID=SID,
    fastqr1=fastqr1,
    fastqr2=fastqr2
} 

  call markdup.markduplicates as md {
  input :
  num_threads=10,
  memory=40,
  disk_space=100,
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
call mapped.samtools_mapped as sm {
input :
num_threads=1,
memory=30,
disk_space=100,
num_preempt=0,
docker=docker,
SID=SID,
input_bam=star_align.bam_file
}
call mqc_postalign.multiQC_postalign as mqc_pa {
input :
   memory=30,
   disk_space=50,
   num_threads=1,
   num_preempt=0,
   docker=docker,
   star_report=star_align.logs[0],
   rsem_report=rsem_quant.stat_cnt,
   fc_report=featurecounts.fc_summary
}
}

