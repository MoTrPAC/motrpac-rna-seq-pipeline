java -jar ../../../tools/womtool-36.jar inputs rnaseq_fastq_star_scatter.wdl >star_inputs.json
java -Dconfig.file=google.conf -jar /Users/archanaraja/work/tools/cromwell/cromwell-36.jar run STAR/rnaseq_fastq_star_scatter.wdl -i STAR/star_inputs.json
