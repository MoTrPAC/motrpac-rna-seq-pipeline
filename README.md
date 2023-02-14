MotrPAC RNA-seq Pipeline
=================================================
Description
-------------------------------------------------
This repo contains WDL implementation of the MotrPAC RNA-seq pipeline based on harmonized RNA-seq MOP

* [MoTrPAC RNA-seq MOP (web view version 2.0)](https://docs.google.com/document/d/e/2PACX-1vRFurZraZfxfMd5BWfIQEnETlalDNjQPyMjS7TCTgc3MMlMtB_-tmJfEK7lmRV7GD30I7R9-ISX3kuM/pub)

Requirements
--------------------------------------------------
Follow instructions in
the [VM requirements](https://github.com/AshleyLab/motrpac-rna-seq-pipeline/blob/pipeline_test/vm_requirements.txt) file
to create a new VM and install all the dependencies to run the pipeline. Test data to run the pipeline can be found
here : `gs://***REMOVED***/rna-seq/test_data`

Setup
--------------------------------------------------

1. **Set up mysql db to store metadata on a persistent hard-disk**

    ```bash
    mkdir -p mysql_db_rnaseq # (should be run only once, subsequent runs can use the same mysql db)
    ```

2. **Start the mysql db everytime before starting a pipeline , below step needs to be run first time your going to run a
   pipeline or everytime a VM instance is restarted.**

    ```bash
    run_mysql_server_docker.sh mysql_db_rnaseq
    ```

   If the above command complains that a container already exists , remove the container using the below commands and
   rerun `run_mysql_server_docker.sh`

    * list all the docker containers

    ```bash
    docker ps -a
    ```

    * remove docker container

    ```bash
    docker stop <CONTAINER ID>
    docker rm <CONTAINER ID>
    ```

    * Make sure mysql db is running before instantiating caper server , below command should list a docker instance
      running
      the mysql-db

     ```bash
    docker ps
     ```

3. **Generate and configure ~/.caper/default.conf for gcp, add parameters for mysql backend**

    ```bash
    caper init gcp
    ```

    * Change `out-gcs-bucket , tmp-gcs-bucket` , make sure the tmp_dir specified below exists if it doesn't make one
      using `mkdir <dir_name>` , mysql-db-port should match the port number specified in the `docker ps` command

    ```dotenv
    cromwell=/home/araja7/tools/cromwell-42.jar
    womtool=/home/araja7/tools/womtool-42.jar
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

Run the pipeline
-------------------------------------------------

1. **If you haven't cloned the rna-seq repo as part of requirements step. Clone the repo using the below command.**

    ```bash
    git clone https://github.com/AshleyLab/motrpac-rna-seq-pipeline.git 
    ```

2. **Generate input configuration files. These files are necessary to run the pipeline.**

    * run python script to generate input.json config files from the raw fastq directory on gcp
    * split the raw files into 4 batches assuming a batch has 320 samples. If the batch count is lesser we can make
      fewer batches.
    * Below is an example to generate input.json file for 1 batch.

    ```bash
    cd <rna-seq-repo>   
    mkdir input_json
    python3 scripts/make_json_rnaseq.py <gcp_path_fastq_dir_without_trailing_slash> <outdir_for_split_file_list> <num_of_batches_to_split>
    python3 scripts/make_json_rnaseq.py gs://***REMOVED***/rna-seq/test_data input_json/ 1
    ```

3. **Make sure to configure ~/.caper/default.conf (instructions in the setup step) . Run caper server in a screen
   session and detach the screen**

    ```bash
    screen -RD caper_server
    caper server 2>caper.err 1>caper.out
    
    ```

   To detach a screen

    ```bash
     ctrl A + D
    ```

4. **Submit rna-seq workflows to caper server**

    ```bash
    caper submit rnaseq_pipeline_scatter.wdl -i input_json/set1_rnaseq.json
    ```

A typical workflow for rat samples takes ~4 hours. Check the status of workflows and make sure they have succeeded by
typing `caper list` on the VM instance that's running the job and look for `Succeeded`

Merge RNA-seq results
-------------------------------------------------

1. Copy rsem,featurecounts and qc reports to a VM instance.

   ```bash
   mkdir -p rsem_results
   gsutil -m cp -n -r gs://***REMOVED***/rna-seq/test-pipeline/rnaseq_pipeline/*/call-rsem_quant/shard-*/rsem_reference/*.*
   .results rsem_results/
   mkdir -p featureCounts
   gsutil -m cp -n -r gs://***REMOVED***/rna-seq/test-pipeline/rnaseq_pipeline/*/call-featurecounts/shard-*/*.out
   featureCounts/
   mkdir -p qc_report
   gsutil -m cp -n -r gs://***REMOVED***/rna-seq/test-pipeline/rnaseq_pipeline/*/call-qc_report/shard-*/*_qc_info.csv
   qc_report/
   ```
   
2. Merge the results to generate consolidated table

   a. Merge RSEM raw gene count
   Make sure you are in the parent directory of rsem_results
   ```bash
   python merge_rsem.py
   # Output: rsem_genes_count.txt,rsem_genes_tpm.txt,rsem_genes_fpkm.txt
   ```
   
   b. Merge FeatureCounts

   Make sure you are in the parent directory of rsem_results
   ```bash
   python3 merge_fc.py 
   # Output : featureCounts.txt
   ```

   c. Merge QC report
   
   Make sure you are in the parent directory of qc_report
   ```bash
   python3 consolidate_qc_report.py --qc_dir qc_report rnaseq_pipeline_qc_metrics_batch4.csv
   # Output: qc_report/naseq_pipeline_qc_metrics_batch4.csv
   ```
3. Copy the results to the desired location on GCP

	```
	gsutil -m cp -r rsem_genes_* gs://***REMOVED***-transfer-stanford/Output/PASS1B/RNA-SEQ/batch4_20200106/results/
	gsutil -m cp -r featureCounts.txt gs://***REMOVED***-transfer-stanford/Output/PASS1B/RNA-SEQ/batch4_20200106/results/
	gsutil -m cp -r rnaseq_pipeline_qc_metrics_batch4.csv gs://***REMOVED***-transfer-stanford/Output/PASS1B/RNA-SEQ/batch4_20200106/results/
	```


Output
---------------------------------------------------

* Results can be found here `gs://***REMOVED***/rna-seq/test-42/rnaseq_pipeline/c62db449-3b65-4eeb-831e-1e411eace6bd/`

Maintainer
----------------------------------------------------
Archana Raja




