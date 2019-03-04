java -jar ../../../tools/womtool-36.jar inputs multiqc.wdl >multiqc_inputs_gcp.json
java -Dconfig.file=google.conf -jar /Users/archanaraja/work/tools/cromwell/cromwell-36.jar run MultiQC/multiqc.wdl -i MultiQC/multiqc_inputs.json
