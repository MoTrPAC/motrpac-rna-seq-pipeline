MotrPAC RNA-seq Pipeline
=================================================
Description
-------------------------------------------------
This repo contains WDL implementation of the MotrPAC RNA-seq pipeline based on harmonized RNA-seq MOP
* [MoTrPAC RNA-seq MOP (web view version 2.0)](https://docs.google.com/document/d/e/2PACX-1vRFurZraZfxfMd5BWfIQEnETlalDNjQPyMjS7TCTgc3MMlMtB_-tmJfEK7lmRV7GD30I7R9-ISX3kuM/pub)

Requirements
--------------------------------------------------
1. Download cromwell
   wget https://github.com/broadinstitute/cromwell/releases/download/38/cromwell-38.jar
   chmod +rx cromwell-38.jar

2. Docker image : gcr.io/***REMOVED***/motrpac_rnaseq:v0.1_04_20_19

To run the pipeline
--------------------------------------------------
    java -Dconfig.file=google.conf -jar /Users/archanaraja/work/tools/cromwell/cromwell-40.jar run rnaseq_pipeline_scatter.wdl -i rnaseq_pipeline_inputs_scatter.json

Output
---------------------------------------------------
* Results can be found here `gs://archanaraja/rnaseq/test/pilot/cromwell-execution/rnaseq_pipeline`

Maintainer
----------------------------------------------------
Archana Raja




