java -Dconfig.file=google.conf -jar /Users/archanaraja/work/tools/cromwell-38.jar run dup_umi/UMI_dup.wdl -i dup_umi/UMIdup_inputs.json
grep "Molecular tag dups count" rnaseq_test_pilot_NIH_cromwell-execution_rnaseq_pipeline_87725f64-7ef3-459b-88d7-1767ef9f5673_call-udup_udup-stdout.txt|awk -F "(" '{print $2}'|awk -v id="col_1" '{print "Sample""\t""%umi_dup""\n"id"\t"($1*100)}' >umi_dup.log
