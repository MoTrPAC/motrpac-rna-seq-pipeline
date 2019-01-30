import "star.wdl" as star_wdl

 
workflow rnaseq_pipeline_fastq_workflow {

    Array[File] fastq1
    
    Array[File] fastq2 = []
    String prefix
    File star_index
    String? outSAMattributes
    String? outFilterType
    String? outSAMtype
    String? quantMode
    
    ## WORKFLOW BEGINS

    Array[Array[File]] fastqs = if length(fastq1)>0 then transpose([fastq1, fastq2]) else transpose([fastq1])
    
    scatter (i in range(length(fastqs))) {
        call star_wdl.star {
                input: fastq = fastqs[i], 
                       prefix=prefix, 
                       star_index=star_index,
                       outSAMattributes = outSAMattributes,
                       outFilterType = outFilterType,
                       quantMode = quantMode
        }
    }
}
