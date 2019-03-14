MotrPAC RNA-seq Pipeline
=================================================
This repo contains WDL implementation of the MotrPAC RNA-seq pipeline based on harmonized RNAseq MOP

To run the pipeline
--------------------------------------------------
    `java -Dconfig.file=google.conf -jar /Users/archanaraja/work/tools/cromwell/cromwell-36.jar run rnaseq_pipeline.wdl -i rnaseq_pipeline_inputs_gcp.json`

Output
---------------------------------------------------
Time to run the pipeline

(7:56-8:00) 34 minutes

Path : gs://archanaraja/rnaseq/test/pilot/cromwell-execution/rnaseq_pipeline

job id :  
c5af4850

Ran the rnaseq pipeline on 2 pilot samples
job id => 2f9e005d
job id => e69cdf99

Docker images
------------------------------------------------------
(only updated subreads package)
araja7/motrpac_rnaseq:v0.1

gcr.io docker image with updated star version (2.7.0d)

gcr.io/***REMOVED***-dev/motrpac_rnaseq:v0.1_03_08_19

