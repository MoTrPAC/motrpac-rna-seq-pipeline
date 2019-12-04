MotrPAC RNA-seq Pipeline
=================================================
Description
-------------------------------------------------
This repo contains WDL implementation of the MotrPAC RNA-seq pipeline based on harmonized RNA-seq MOP
* [MoTrPAC RNA-seq MOP (web view version 2.0)](https://docs.google.com/document/d/e/2PACX-1vRFurZraZfxfMd5BWfIQEnETlalDNjQPyMjS7TCTgc3MMlMtB_-tmJfEK7lmRV7GD30I7R9-ISX3kuM/pub)

Requirements
--------------------------------------------------
Follow instructions in the [VM requirements](https://github.com/AshleyLab/motrpac-rna-seq-pipeline/blob/pipeline_test/vm_requirements.txt) file to create a new VM and install all the dependencies to run the pipeline

Setup
--------------------------------------------------
1. Set up mysql db to store metadata on a persistent hard-disk
```
mkdir -p mysql_db_rnaseq (should be run only once , subsequent runs can use the same mysql db)
```

2. Start the mysql db everytime before starting a pipeline , below step needs to be run first time your going to run a pipeline or everytime a VM instance is restarted.


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
 
3. Generate and configure ~/.caper/default.conf for gcp, add parameters for mysql backend 
```
caper init gcp
```
* Change <out-gcs-bucket> , <tmp-gcs-bucket> , make sure the tmp_dir specified below exists if it doesn't make one using `mkdir -p <dir_name>` , mysql-db-port should match the port number specified in the `docker ps` command

```
cromwell=/home/araja7/tools/cromwell-47.jar
backend=gcp
gcp-prj=motrpac-portal
out-gcs-bucket=gs://rna-seq_araja/rna-seq/sinai/batch5_20191031/
tmp-gcs-bucket=gs://rna-seq_araja/rna-seq/sinai/batch5_20191031/caper_tmp/
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

### Run the pipeline

1. If you haven't cloned the rna-seq repo as part of requirements step. Clone the repo using the below command.
```
git clone -b pipeline_test https://github.com/AshleyLab/motrpac-rna-seq-pipeline.git 
```
2. Generate input configuration files. These files are necessary to run the pipeline.

	* split the raw files into 4 batches assuming a batch has 320 samples. If the batch count is lesser we can make fewer batches. (this step might not be necessary if we decide to submit only 1 batch)
	
	```
	cd <rna-seq-repo>   
   mkdir -p input_json
   bash scripts/make_filelist.sh <gcp_fastq_dir> <batch_size> <outdir_for_split_file_list> <batch_name>
   bash scripts/make_filelist.sh gs://motrpac-portal-transfer-stanford/rna-seq/rat/batch1_20190503/fastq_raw 80 test test_b1
   
   ```
	* run python script to generate input.json config files for the split batches above
	
	```
	python scripts/make_json_rnaseq.py <comma-separated-filelists-including-paths> <complete-path-of-the-output-dir> 
	python scripts/make_json_rnaseq.py test_json/test/test_b1aa,test_json/test/test_b1ab,test_json/test/test_b1ac,test_json/test/test_b1ad test_json/test/
	```
	
3. Make sure to configure ~/.caper/default.conf (instructions in the setup step) . Run caper server in a screen session and detach the screen

```
screen -RD caper_server
caper server 2>caper.err 1>caper.out

```
To detach a screen
```
ctrl A + D
```	    
4. Submit rna-seq workflows to caper server

```
caper submit rnaseq_pipeline_scatter.wdl -i test_json/test/test_b1aa.json --docker gcr.io/motrpac-portal/motrpac_rnaseq:v0.1_04_20_19
```

Output
---------------------------------------------------

* Results can be found here `gs://rna-seq_araja/rna-seq/sinai/batch5_20191031/cromwell-execution/rnaseq_pipeline`

Maintainer
----------------------------------------------------
Archana Raja




