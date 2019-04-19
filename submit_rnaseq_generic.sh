#!/bin/bash
#Generic script takes in one input.json file for a sample and runs the pipeline
#$1 is the input.json file
#Usage : for i in `cat ids3.txt`;do ./submit_rnaseq_pilot_generic.sh $i;done
#for i in input_json/harmony_test/stanford_working/* ;do ./submit_rnaseq_generic.sh $i;done >>jobs.sh
#chmod +x jobs.sh
echo java -Dconfig.file=google.conf -jar /Users/archanaraja/work/tools/cromwell-38.jar run rnaseq_pipeline.wdl -i "$1" "&"
echo "Done , success"
