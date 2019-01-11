import "star.wdl" as star_wdl
import "markduplicates.wdl" as markduplicates_wdl
import "rsem.wdl" as rsem_wdl
import "rnaseqc_counts.wdl" as rnaseqc_wdl

 
workflow rnaseq_pipeline_fastq_workflow {

    Array[File] fastq1
    
    Array[File] fastq2 = []
    String prefix
    File star_index
    
    ## WORKFLOW BEGINS

    Array[Array[File]] fastqs = if length(fastq1)>0 then transpose([fastq1, fastq2]) else transpose([fastq1])
    
    scatter (i in range(length(fastqs))) {
        call star_wdl.star {
                input: fastq = fastqs[i], prefix=prefix, star_index=star_index
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
    }
}
