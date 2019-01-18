Docker => quay.io/biocontainers/fastqc:0.11.8--1

Create input json
java -jar ../../../tools/womtool-36.jar inputs fastqc.wdl >fastqc_inputs.json


#Issue running fastqc through docker , error that it cannot locate the file , some permissions issue 
docker run quay.io/biocontainers/fastqc:0.11.8--1 fastqc -v

#running the script locally
java -jar /Users/archanaraja/work/tools/cromwell/cromwell-36.jar run fastqc_working1.wdl -i fastqc_inputs.json

#takes a minute to run on the test data
