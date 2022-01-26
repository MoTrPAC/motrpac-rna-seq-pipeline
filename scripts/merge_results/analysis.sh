gsutil cp -r gs://rna-seq_araja/PASS1A/Stanford/batch1/set*/rnaseq_pipeline/*/call-qc_report/shard*/*_qc_info.csv .
gsutil cp -r gs://rna-seq_araja/PASS1A/Stanford/batch1/redo/rnaseq_pipeline/*/call-qc_report/shard*/*_qc_info.csv .
#below yields the report for total number of samples
ls *.csv|wc -l
