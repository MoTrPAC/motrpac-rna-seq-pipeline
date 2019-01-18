multiqc -d -f -n multiqc_report -o ../test_data ../test_data

# instructions to run wdl , should add docker capability
java -jar /Users/archanaraja/work/tools/cromwell/cromwell-36.jar run multiqc.wdl -i multiqc_inputs.json
