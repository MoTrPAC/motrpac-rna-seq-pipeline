# RNAseq
repository to store code related to RNAseq preprocessing pipeline and analysis.

Usage: java -Dconfig.file=google.conf -jar /Users/archanaraja/work/tools/cromwell/cromwell-36.jar run wdl/rnaseq_pipeline_fastq.wdl -i input_json/rat/rnaseq_pipeline_fastq_rat.json

Monitoring jobs

/Users/archanaraja/work/tools/wdl/runners/cromwell_on_google/monitoring_tools/

monitor_wdl_pipeline.sh operations/EJPf9_j5LBix1vnc0JPQ2PMBIN2or9XICioPcHJvZHVjdGlvblF1ZXVl


Command to validate your wdl file

java -jar ../../../../tools/womtool-36.jar validate ../../wdl/collectrnaseqmetrics.wdl

Command to generate input.json based on wdl

java -jar ../../../tools/womtool-36.jar inputs collectrnaseqmetrics.wdl > collectrnaseqmetrics_inputs.json

# Working multisample STAR script
java -Dconfig.file=google.conf -jar /Users/archanaraja/work/tools/cromwell/cromwell-36.jar run wdl/wdl_test/rnaseq_star.wdl -i input_json/rat/test_star_multisample_rat.json 
