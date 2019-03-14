MotrPAC RNA-seq Pipeline
=================================================
Description
-------------------------------------------------
This repo contains WDL implementation of the MotrPAC RNA-seq pipeline based on harmonized RNA-seq MOP
* [MoTrPAC RNA-seq MOP (web view version 2.0)](https://docs.google.com/document/d/e/2PACX-1vRFurZraZfxfMd5BWfIQEnETlalDNjQPyMjS7TCTgc3MMlMtB_-tmJfEK7lmRV7GD30I7R9-ISX3kuM/pub)

To run the pipeline
--------------------------------------------------
    java -Dconfig.file=google.conf -jar /Users/archanaraja/work/tools/cromwell/cromwell-36.jar run rnaseq_pipeline.wdl -i rnaseq_pipeline_inputs_gcp.json

Output
---------------------------------------------------
* Results can be found here `gs://archanaraja/rnaseq/test/pilot/cromwell-execution/rnaseq_pipeline`

Maintainer
----------------------------------------------------
Archana Raja




