MotrPAC RNA-seq Pipeline
    -This repo contains WDL implementation of the MotrPAC RNA-seq pipeline

To run the pipeline
    `java -Dconfig.file=google.conf -jar /Users/archanaraja/work/tools/cromwell/cromwell-36.jar run rnaseq_pipeline.wdl -i rnaseq_pipeline_inputs_gcp.json`

Time to run the pipeline

(7:56-8:00) 34 minutes

job id :  
c5af4850

Path : 
gs://archanaraja/rnaseq/test/pilot/cromwell-execution/rnaseq_pipeline/c5af4850-e024-4fe2-8de7-421621a01d1e/

Docker image : (only updated subreads package)
araja7/motrpac_rnaseq:v0.1

