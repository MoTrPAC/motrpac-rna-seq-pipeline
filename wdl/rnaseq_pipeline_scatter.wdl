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
import "merge_results/merge_results.wdl" as final_merge

workflow rnaseq_pipeline {
    input {
        # Input files/values
        Array[File] fastq1=[]
        Array[File] fastq2=[]
        Array[File] fastq_index=[]
        Array[String] sample_prefix=[]

        # FastQC Parameters
        String pre_trim_out_dir
        Int pretrim_fastqc_ncpu
        Int pretrim_fastqc_ramGB
        Int pretrim_fastqc_disk
        String post_trim_out_dir
        Int posttrim_fastqc_ncpu
        Int posttrim_fastqc_ramGB
        Int posttrim_fastqc_disk

        String fastqc_docker

        # Attach UMI Parameters
        Int attach_umi_ncpu
        Int attach_umi_ramGB
        Int attach_umi_disk
        String attach_umi_docker

        # CutAdapt Parameters
        Int minimumLength
        String index_adapter
        String univ_adapter
        Int cutadapt_ncpu
        Int cutadapt_ramGB
        Int cutadapt_disk
        String cutadapt_docker

        # MultiQC Parameters
        Int multiqc_ncpu
        Int multiqc_ramGB
        Int multiqc_disk
        String multiqc_docker

        # Star Align Parameters
        File star_index
        Int star_ncpu
        Int star_ramGB
        Int star_disk
        String star_docker

        # FeatureCounts Parameters
        File gtf_file
        Int feature_counts_ncpu
        Int feature_counts_ramGB
        Int feature_counts_disk
        String feature_counts_docker

        # RSEM Parameters
        File rsem_reference
        Int rsem_ncpu
        Int rsem_ramGB
        Int rsem_disk
        String rsem_docker

        # Bowtie2 Parameters
        String globin_genome_dir
        File globin_genome_dir_tar
        Int bowtie2_globin_ncpu
        Int bowtie2_globin_ramGB
        Int bowtie2_globin_disk

        String rrna_genome_dir
        File rrna_genome_dir_tar
        Int bowtie2_rrna_ncpu
        Int bowtie2_rrna_ramGB
        Int bowtie2_rrna_disk

        String phix_genome_dir
        File phix_genome_dir_tar
        Int bowtie2_phix_ncpu
        Int bowtie2_phix_ramGB
        Int bowtie2_phix_disk

        String bowtie_docker

        # Picard Docker Image
        Int markdup_ncpu
        Int markdup_ramGB
        Int markdup_disk

        # CollectRnaSeqMetrics Parameters
        File ref_flat
        Int rnaqc_ncpu
        Int rnaqc_ramGB
        Int rnaqc_disk

        String picard_docker

        # UMI Duplication Parameters
        Int umi_dup_ncpu
        Int umi_dup_ramGB
        Int umi_dup_disk
        String umi_dup_docker

        # Samtools Parameters
        Int mapped_ncpu
        Int mapped_ramGB
        Int mapped_disk
        String samtools_docker

        # MultiQC Post Align Parameters
        Int mqc_postalign_ncpu
        Int mqc_postalign_ramGB
        Int mqc_postalign_disk

        # Collect QC Parameters
        Int collect_qc_ncpu
        Int collect_qc_ramGB
        Int collect_qc_disk
        String collect_qc_docker

        # Merge Results Parameters
        String output_report_name
        Int merge_results_ncpu
        Int merge_results_ramGB
        Int merge_results_disk
        String merge_results_docker
    }

    scatter (i in range(length(fastq1))) {
        call fastqc.fastQC as pretrim_fastqc {
            input:
            # Inputs
                fastqr1=fastq1[i],
                fastqr2=fastq2[i],
                outdir=pre_trim_out_dir,
            # Runtime Parameters
                ncpu=pretrim_fastqc_ncpu,
                memory=pretrim_fastqc_ramGB,
                disk_space=pretrim_fastqc_disk,

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
                ncpu=attach_umi_ncpu,
                memory=attach_umi_ramGB,
                disk_space=attach_umi_disk,

                docker=attach_umi_docker
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
                cpus=cutadapt_ncpu,
                memory=cutadapt_ramGB,
                disk_space=cutadapt_disk,

                docker=cutadapt_docker,
        }

        call fastqc.fastQC as posttrim_fastqc {
            input:
            # Inputs
                fastqr1=cutadapt.fastq_trimmed_R1,
                fastqr2=cutadapt.fastq_trimmed_R2,
                outdir=post_trim_out_dir,
            # Runtime Parameters
                ncpu=posttrim_fastqc_ncpu,
                memory=posttrim_fastqc_ramGB,
                disk_space=posttrim_fastqc_disk,

                docker=fastqc_docker
        }

        call multiqc.multiQC as mqc {
            input:
            # Inputs
                fastQCReports=[pretrim_fastqc.fastQC_report,posttrim_fastqc.fastQC_report],
                trim_report=cutadapt.report,
            # Runtime Parameters
                ncpu=multiqc_ncpu,
                memory=multiqc_ramGB,
                disk_space=multiqc_disk,

                docker=multiqc_docker,

        }

        call star.star as star_align {
            input:
            # Inputs
                star_index=star_index,
                prefix=sample_prefix[i],
                fastq1=cutadapt.fastq_trimmed_R1,
                fastq2=cutadapt.fastq_trimmed_R2,
            # Runtime Parameters
                ncpu=star_ncpu,
                memory=star_ramGB,
                disk_space=star_disk,

                docker=star_docker,
        }

        call fc.feature_counts as feature_counts {
            input:
            # Inputs
                SID=sample_prefix[i],
                input_bam=star_align.bam_file,
                gtf_file=gtf_file,
            # Runtime Parameters
                ncpu=feature_counts_ncpu,
                memory=feature_counts_ramGB,
                disk_space=feature_counts_disk,

                docker=feature_counts_docker
        }

        call rsem.rsem as rsem_quant {
            input:
            # Inputs
                SID=sample_prefix[i],
                transcriptome_bam=star_align.transcriptome_bam,
                rsem_reference=rsem_reference,
            # Runtime Parameters
                ncpu=rsem_ncpu,
                memory=rsem_ramGB,
                disk_space=rsem_disk,

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
                ncpu=bowtie2_globin_ncpu,
                memory=bowtie2_globin_ramGB,
                disk_space=bowtie2_globin_disk,

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
                ncpu=bowtie2_rrna_ncpu,
                memory=bowtie2_rrna_ramGB,
                disk_space=bowtie2_rrna_disk,

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
                ncpu=bowtie2_phix_ncpu,
                memory=bowtie2_phix_ramGB,
                disk_space=bowtie2_phix_disk,

                docker=bowtie_docker,

        }

        call markdup.markduplicates as md {
            input:
            # Inputs
                SID=sample_prefix[i],
                input_bam=star_align.bam_file,
            # Runtime Parameters
                ncpu=markdup_ncpu,
                memory=markdup_ramGB,
                disk_space=markdup_disk,

                docker=picard_docker
        }

        call metrics.collectrnaseqmetrics as rnaqc {
            input:
            # Inputs
                SID=sample_prefix[i],
                input_bam=star_align.bam_file,
                ref_flat=ref_flat,
            # Runtime Parameters
                ncpu=rnaqc_ncpu,
                memory=rnaqc_ramGB,
                disk_space=rnaqc_disk,

                docker=picard_docker
        }

        call umi_dup.UMI_dup as udup {
            input:
            # Inputs
                sample_prefix=sample_prefix[i],
                star_align=star_align.bam_file,
            # Runtime Parameters
                ncpu=umi_dup_ncpu,
                memory=umi_dup_ramGB,
                disk_space=umi_dup_disk,

                docker=umi_dup_docker
        }

        call mapped.samtools_mapped as sm {
            input:
            # Inputs
                SID=sample_prefix[i],
                input_bam=star_align.bam_file,
            # Runtime Parameters
                ncpu=mapped_ncpu,
                memory=mapped_ramGB,
                disk_space=mapped_disk,

                docker=samtools_docker
        }

        call mqc_postalign.multiQC_postalign as mqc_pa {
            input:
            # Inputs
                fastQCReport=[posttrim_fastqc.fastQC_report],
                trim_report=cutadapt.report,
                rnametric_report=rnaqc.rnaseqmetrics,
                md_report=md.metrics,
                star_report=star_align.logs[0],
                rsem_report=rsem_quant.stat_cnt,
                fc_report=feature_counts.fc_summary,
            # Runtime Parameters
                ncpu=mqc_postalign_ncpu,
                memory=mqc_postalign_ramGB,
                disk_space=mqc_postalign_disk,

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
                ncpu=collect_qc_ncpu,
                memory=collect_qc_ramGB,
                disk_space=collect_qc_disk,

                docker=collect_qc_docker,
        }
    }

    call final_merge.merge_results as merge_results {
        input:
        # Inputs
            output_report_name=output_report_name,
            rsem_files=rsem_quant.genes,
            feature_counts_files=feature_counts.fc_out,
            qc_report_files=qc_report.rnaseq_report,
        # Runtime Parameters
            ncpu=merge_results_ncpu,
            memory=merge_results_ramGB,
            disk_space=merge_results_disk,

            docker=merge_results_docker,
    }

    output {
        File rsem_genes_count = merge_results.rsem_genes_count
        File rsem_genes_tpm = merge_results.rsem_genes_tpm
        File rsem_genes_fpkm = merge_results.rsem_genes_fpkm
        File feature_counts = merge_results.feature_counts
        File qc_report = merge_results.qc_report
    }
}
