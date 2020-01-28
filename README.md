MotrPAC RNA-seq Pipeline
=================================================
Description
-------------------------------------------------
This repo contains WDL implementation of the MotrPAC RNA-seq pipeline based on harmonized RNA-seq MOP
* [MoTrPAC RNA-seq MOP (web view version 2.0)](https://docs.google.com/document/d/e/2PACX-1vRFurZraZfxfMd5BWfIQEnETlalDNjQPyMjS7TCTgc3MMlMtB_-tmJfEK7lmRV7GD30I7R9-ISX3kuM/pub)

Requirements
--------------------------------------------------
Follow instructions in the [VM requirements](https://github.com/AshleyLab/motrpac-rna-seq-pipeline/blob/pipeline_test/vm_requirements.txt) file to create a new VM and install all the dependencies to run the pipeline. Test data to run the pipeline can be found here : `gs://***REMOVED***/rna-seq/test_data`

Setup
--------------------------------------------------
1. **Set up mysql db to store metadata on a persistent hard-disk**
```
mkdir -p mysql_db_rnaseq (should be run only once , subsequent runs can use the same mysql db)
```

2. **Start the mysql db everytime before starting a pipeline , below step needs to be run first time your going to run a pipeline or everytime a VM instance is restarted.**


```
run_mysql_server_docker.sh mysql_db_rnaseq
```
If the above command complains that a container already exists , remove the container using the below commands and rerun `run_mysql_server_docker.sh`
 
* list all the docker containers
 ```
 docker container ls -a
 ```
* remove docker container
```
docker stop <CONTAINER ID>
docker rm <CONTAINER ID>
```
* Make sure mysql db is running before instantiating caper server , below command should list a docker instance running the mysql-db
 ```
 docker ps
 ```
 
3. **Generate and configure ~/.caper/default.conf for gcp, add parameters for mysql backend** 
```
caper init gcp
```
* Change `cromwell` to the path where cromwell was locally installed `out-gcs-bucket , tmp-gcs-bucket` , make sure the tmp_dir specified below exists if it doesn't make one using `mkdir -p <dir_name>` , mysql-db-port should match the port number specified in the `docker ps` command

```
cromwell=/home/araja7/tools/cromwell-40.jar
backend=gcp
gcp-prj=***REMOVED***
out-gcs-bucket=gs://***REMOVED***/rna-seq/sinai/batch5_20191031/
tmp-gcs-bucket=gs://***REMOVED***/rna-seq/sinai/batch5_20191031/caper_tmp/
tmp-dir=/home/araja7/tmp_dir
db=mysql
mysql-db-ip=localhost
mysql-db-port=3306
mysql-db-user=cromwell
mysql-db-password=cromwell
java-heap-server=20G
## Cromwell server
ip=localhost
port=8000

```
**NOTE : When you update the out-gcs-bucket paths , you have to stop the docker and the caper server and restart for the new changes to be updated otherwise the output location of the workflows will be the previous location in the default.conf
 
### Run the pipeline

1. **If you haven't cloned the rna-seq repo as part of requirements step. Clone the repo using the below command.**
```
git clone -b pipeline_test https://github.com/AshleyLab/motrpac-rna-seq-pipeline.git 
```
2. **Generate input configuration files. These files are necessary to run the pipeline.**

	* split the raw files into 4 batches assuming a batch has 320 samples. If the batch count is lesser we can make fewer batches. (this step might not be necessary if we decide to submit only 1 batch)
	* Below is an example to generate only 1 batch.
	
	```
	cd <rna-seq-repo>   
   mkdir -p input_json
   bash scripts/make_filelist.sh <gcp_fastq_dir> <batch_size> <outdir_for_split_file_list> <batch_name>
   bash scripts/make_filelist.sh gs://***REMOVED***/rna-seq/test_data 1 input_json test_batch
   
   ```
	* run python script to generate input.json config files for the split batches above
	
	```

	python scripts/make_json_rnaseq.py <comma-separated-filelists-including-paths> <complete-path-of-the-output-dir> 
	python scripts/make_json_rnaseq.py input_json/test_batchaa input_json/

	```
	
3. **Make sure to configure ~/.caper/default.conf (instructions in the setup step) . Run caper server in a screen session and detach the screen**

	```
	screen -RD caper_server
	caper server 2>caper.err 1>caper.out

	```
 To detach a screen
 ```
 ctrl A + D
 ```	    
4. **Submit rna-seq workflows to caper server**

 ```
 caper submit rnaseq_pipeline_scatter.wdl -i test_json/test/test_b1aa.json --docker gcr.io/***REMOVED***/motrpac_rnaseq:v0.1_04_20_19
 ```
 A typical workflow for rat samples takes ~4 hours. Check the status of workflows and make sure they have succeeded by typing `caper list` on the VM instance that's running the job and look for `Succeeded`
 
Merge rna-seq results
-------------------------------------------------

1. Copy rsem ,featurecounts and qc reports to a VM instance.

   ```
   mkdir -p rsem_results
   gsutil -m cp -n -r gs://***REMOVED***/rna-seq/test-pipeline/rnaseq_pipeline/*/call-rsem_quant/shard-*/rsem_reference/*.*.results rsem_results/
   mkdir -p featureCounts
   gsutil -m cp -n -r gs://***REMOVED***/rna-seq/test-pipeline/rnaseq_pipeline/*/call-featurecounts/shard-*/*.out featureCounts/
   mkdir -p qc_report
   gsutil -m cp -n -r gs://***REMOVED***/rna-seq/test-pipeline/rnaseq_pipeline/*/call-qc_report/shard-*/*_qc_info.csv qc_report/
   ```
   
2. Merge the results to generate consolidated table
	   
	   a. Merge RSEM raw gene count
	   
	   ```
	   Make sure your in the parent directory of rsem_results 
		python merge_rsem.py
		Output : rsem_genes_count.txt,rsem_genes_tpm.txt,rsem_genes_fpkm.txt
       ```
      
      b. Merge FeatureCounts
      
      ```
      Make sure your in the parent directory of rsem_results 
      python3 merge_fc.py 
      Output : featureCounts.txt
      ```
      
      c. Merge QC report
         
         Make sure your in the parent directory of qc_report
         python3 consolidate_qc_report.py --qc_dir qc_report rnaseq_pipeline_qc_metrics_batch4.csv
         Output : qc_report/naseq_pipeline_qc_metrics_batch4.csv
3. Copy the results to the desired location on GCP

```
gsutil -m cp -r rsem_genes_* gs://***REMOVED***-transfer-stanford/Output/PASS1B/RNA-SEQ/batch4_20200106/results/
gsutil -m cp -r featureCounts.txt gs://***REMOVED***-transfer-stanford/Output/PASS1B/RNA-SEQ/batch4_20200106/results/
gsutil -m cp -r rnaseq_pipeline_qc_metrics_batch4.csv gs://***REMOVED***-transfer-stanford/Output/PASS1B/RNA-SEQ/batch4_20200106/results/
```


Output
---------------------------------------------------

* Results can be found here `gs://***REMOVED***/rna-seq/sinai/batch5_20191031/cromwell-execution/rnaseq_pipeline`

Maintainer
----------------------------------------------------
Archana Raja




