#!/usr/bin/env bash

mkdir featureCounts rsem_results qc_report
gsutil -m cp -r gs://***REMOVED***/rna-seq/sinai/batch5_20191031/rnaseq_pipeline/*/call-rsem_quant/shard-*/rsem_reference/*.genes.results rsem_results/
gsutil -m cp -r gs://***REMOVED***/rna-seq/sinai/batch5_20191031/rnaseq_pipeline/*/call-featurecounts/shard-*/*.out featureCounts/
gsutil -m cp -r gs://***REMOVED***/rna-seq/sinai/batch5_20191031/rnaseq_pipeline/*/call-qc_report/shard-*/*_qc_info.csv qc_report/
conda deactivate
# Below script needs to be run from the base directory of where the above folders created reside
python3 consolidate_qc_report.py --qc_dir qc_report rnaseq_pipeline_qc_metrics.csv
python merge_fc.py
python merge_rsem.py
# Copy the merged results to gcp
gsutil -m cp -r ./*.txt gs://***REMOVED***-transfer-sinai/Output/rna-seq/rat/batch5_20191031/results/
