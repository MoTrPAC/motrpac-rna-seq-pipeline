version 1.0

import "fastqc/fastqc.wdl" as fastqc
import "attach_umi/attach_umi.wdl" as attach_umi
import "cutadapt/cutadapt.wdl" as ca
import "multiqc/multiqc.wdl" as multiqc
import "star_align/star.wdl" as star
import "feature_counts/fc.wdl" as fc
import "rsem_exp/rsem.wdl" as rsem
import "bowtie2_align/bowtie2_align.wdl" as bowtie2_align
import "mark_duplicates/mark_duplicates.wdl" as markdup
import "collect_rnaseq_metrics/collect_rnaseq_metrics.wdl" as metrics
import "umi_dup/umi_dup.wdl" as umi_dup
import "compute_mapped/mapped.wdl" as mapped
import "multiqc/multiqc_postalign.wdl" as mqc_postalign
import "collect_qc_metrics/collect_qc.wdl" as collect_qc

workflow rnaseq_pipeline {
    input {
        # Input files/values
        Array[File] fastq1=[]
        Array[File] fastq2=[]
        Array[File] fastq_index=[]
        Array[String] sample_prefix=[]

        # FastQC Parameters
        String pre_trim_out_dir
        String post_trim_out_dir
        String fastqc_docker

        # Attach UMI Parameters
        String umi_attach_docker

        # CutAdapt Parameters
        Int minimumLength
        String index_adapter
        String univ_adapter
        String cutadapt_docker

        # MultiQC Parameters
        String multiqc_docker

        # Star Align Parameters
        File star_index
        String star_docker

        # FeatureCounts Parameters
        File gtf_file
        String feature_counts_docker

        # RSEM Parameters
        File rsem_reference
        String rsem_docker

        # Bowtie2 Parameters
        String globin_genome_dir
        File globin_genome_dir_tar
        String rrna_genome_dir
        File rrna_genome_dir_tar
        String phix_genome_dir
        File phix_genome_dir_tar
        String bowtie_docker

        # Picard Docker Image
        String picard_docker

        # UMI Duplication Parameters
        String umi_dup_docker

        # Collect QC Parameters
        File ref_flat
        String collect_qc_docker

        # Samtools Parameters
        String samtools_docker

    }

    scatter (i in range(length(fastq1))) {
        call fastqc.fastQC as preTrimFastQC {
            input:
            # Inputs
                fastqr1=fastq1[i],
                fastqr2=fastq2[i],
                outdir=pre_trim_out_dir,
            # Runtime Parameters
                memory=40,
                disk_space=100,
                ncpu=8,

                docker=fastqc_docker
        }

        call attach_umi.attachUMI as aumi {
            input:
            # Inputs
                SID=sample_prefix[i],
                fastqr1=fastq1[i],
                fastqr2=fastq2[i],
                fastqi1=fastq_index[i],
            # Runtime Parameters
                memory=40,
                disk_space=100,
                ncpu=8,

                docker=umi_attach_docker
        }

        call ca.Cutadapt as cutadapt {
            input:
            # Inputs
                index_adapter=index_adapter,
                univ_adapter=univ_adapter,
                SID=sample_prefix[i],
                fastqr1=aumi.r1_umi_attached,
                fastqr2=aumi.r2_umi_attached,
                minimumLength=minimumLength,
            # Runtime Parameters
                memory=45,
                disk_space=100,
                cpus=8,

                docker=cutadapt_docker,
        }

        call fastqc.fastQC as postTrimFastQC {
            input:
            # Inputs
                fastqr1=cutadapt.fastq_trimmed_R1,
                fastqr2=cutadapt.fastq_trimmed_R2,
                outdir=post_trim_out_dir,
            # Runtime Parameters
                memory=30,
                disk_space=100,
                ncpu=8,

                docker=fastqc_docker
        }

        call multiqc.multiQC as mqc {
            input:
            # Inputs
                fastQCReports=[preTrimFastQC.fastQC_report,postTrimFastQC.fastQC_report],
                trim_report=cutadapt.report,
            # Runtime Parameters
                memory=20,
                disk_space=100,
                ncpu=8,

                docker=multiqc_docker,

        }

        call star.star as star_align {
            input:
            # Inputs
                prefix=sample_prefix[i],
                fastq1=cutadapt.fastq_trimmed_R1,
                fastq2=cutadapt.fastq_trimmed_R2,
                star_index=star_index,
            # Runtime Parameters
                memory=100,
                disk_space=200,
                ncpu=10,

                docker=star_docker,
        }

        call fc.featurecounts as featurecounts {
            input:
            # Inputs
                SID=sample_prefix[i],
                input_bam=star_align.bam_file,
                gtf_file=gtf_file,
            # Runtime Parameters
                memory=40,
                disk_space=100,
                ncpu=8,

                docker=feature_counts_docker
        }

        call rsem.rsem as rsem_quant {
            input:
            # Inputs
                SID=sample_prefix[i],
                transcriptome_bam=star_align.transcriptome_bam,
                rsem_reference=rsem_reference,
            # Runtime Parameters
                memory=50,
                disk_space=150,
                ncpu=10,

                docker=rsem_docker,
        }

        call bowtie2_align.bowtie2_align as bowtie2_globin {
            input:
            # Inputs
                SID=sample_prefix[i],
                fastqr1=cutadapt.fastq_trimmed_R1,
                fastqr2=cutadapt.fastq_trimmed_R2,
                genome_dir=globin_genome_dir,
                genome_dir_tar=globin_genome_dir_tar,
            # Runtime Parameters
                memory=80,
                disk_space=200,
                ncpu=10,

                docker=bowtie_docker,

        }

        call bowtie2_align.bowtie2_align as bowtie2_rrna {
            input:
            # Inputs
                SID=sample_prefix[i],
                fastqr1=cutadapt.fastq_trimmed_R1,
                fastqr2=cutadapt.fastq_trimmed_R2,
                genome_dir=rrna_genome_dir,
                genome_dir_tar=rrna_genome_dir_tar,
            # Runtime Parameters
                memory=80,
                disk_space=200,
                ncpu=10,

                docker=bowtie_docker,

        }

        call bowtie2_align.bowtie2_align as bowtie2_phix {
            input:
            # Inputs
                SID=sample_prefix[i],
                fastqr1=cutadapt.fastq_trimmed_R1,
                fastqr2=cutadapt.fastq_trimmed_R2,
                genome_dir=phix_genome_dir,
                genome_dir_tar=phix_genome_dir_tar,
            # Runtime Parameters
                memory=80,
                disk_space=200,
                ncpu=10,

                docker=bowtie_docker,

        }

        call markdup.markduplicates as md {
            input:
            # Inputs
                SID=sample_prefix[i],
                input_bam=star_align.bam_file,
            # Runtime Parameters
                ncpu=10,
                memory=45,
                disk_space=150,

                docker=picard_docker
        }

        call metrics.collectrnaseqmetrics as rnaqc {
            input:
            # Inputs
                SID=sample_prefix[i],
                input_bam=star_align.bam_file,
                ref_flat=ref_flat,
            # Runtime Parameters
                ncpu=10,
                memory=40,
                disk_space=100,

                docker=picard_docker
        }

        call umi_dup.UMI_dup as udup {
            input:
            # Inputs
                sample_prefix=sample_prefix[i],
                star_align=star_align.bam_file,
            # Runtime Parameters
                ncpu=8,
                memory=50,
                disk_space=100,

                docker=umi_dup_docker
        }

        call mapped.samtools_mapped as sm {
            input:
            # Inputs
                SID=sample_prefix[i],
                input_bam=star_align.bam_file,
            # Runtime Parameters
                ncpu=8,
                memory=30,
                disk_space=200,

                docker=samtools_docker
        }

        call mqc_postalign.multiQC_postalign as mqc_pa {
            input:
            # Inputs
                fastQCReport=[postTrimFastQC.fastQC_report],
                trim_report=cutadapt.report,
                rnametric_report=rnaqc.rnaseqmetrics,
                md_report=md.metrics,
                star_report=star_align.logs[0],
                rsem_report=rsem_quant.stat_cnt,
                fc_report=featurecounts.fc_summary,
            # Runtime Parameters
                memory=30,
                disk_space=50,
                ncpu=8,

                docker=multiqc_docker
        }

        call collect_qc.rnaseqQC as qc_report {
            input:
            # Inputs
                SID=sample_prefix[i],
                multiQCReports=[mqc.multiQC_report,mqc_pa.multiQC_report],
                globin_report=bowtie2_globin.bowtie2_report,
                phix_report=bowtie2_phix.bowtie2_report,
                rRNA_report=bowtie2_rrna.bowtie2_report,
                trim_summary=cutadapt.summary,
                mapped_report=sm.report,
                star_log=star_align.logs[0],
                umi_report=udup.umi_report,
            # Runtime Parameters
                memory=10,
                disk_space=50,
                ncpu=8,

                docker=collect_qc_docker,
        }
    }
}
