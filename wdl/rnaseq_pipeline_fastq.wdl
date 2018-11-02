import "wdl/star.wdl" as star_wdl
import "wdl/markduplicates.wdl" as markduplicates_wdl
import "wdl/rsem.wdl" as rsem_wdl
import "wdl/rnaseqc_counts.wdl" as rnaseqc_wdl
 
workflow rnaseq_pipeline_fastq_workflow {

    File fastq1
    File? fastq2
    String prefix
    File star_index

    call star_wdl.star {
        input: fastq1=fastq1, fastq2=fastq2, prefix=prefix, star_index=star_index
    }

    call markduplicates_wdl.markduplicates {
        input: input_bam=star.bam_file, prefix=prefix
    }

    call rsem_wdl.rsem {
        input: transcriptome_bam=star.transcriptome_bam, prefix=prefix
    }

    call rnaseqc_wdl.rnaseqc_counts {
        input: bam_file=markduplicates.bam_file, bam_index=markduplicates.bam_index, prefix=prefix
    }

    meta {
        author: "Shruti Marwaha"
    }
}
