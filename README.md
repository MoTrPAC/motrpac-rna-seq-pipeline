MoTrPAC RNA-SEQ Pipeline
=================================================

[![DOI](https://zenodo.org/badge/144631622.svg)](https://zenodo.org/badge/latestdoi/144631622)

Overview
-------------------------------------------------

This repo contains the rna-seq data processing pipeline implemented in Workflow Description Language (WDL) based on harmonized [RNA-SEQ MOP](https://docs.google.com/document/d/e/2PACX-1vRFurZraZfxfMd5BWfIQEnETlalDNjQPyMjS7TCTgc3MMlMtB_-tmJfEK7lmRV7GD30I7R9-ISX3kuM/pub). This pipeline uses [caper](https://github.com/ENCODE-DCC/caper), a wrapper python package for the workflow management system [Cromwell](https://cromwell.readthedocs.io/en/stable/). All the data was processed on the Google Cloud Platform (GCP). The pipeline uses [STAR aligner](https://github.com/alexdobin/STAR), [RSEM](https://github.com/deweylab/RSEM) and [featureCounts](https://subread.sourceforge.net/) read quantification tools. The pipeline also generates a qc metrics file, useful for outlier detection and covariate adjustment during differential analysis.

## Details

### GCP set-up

The WDL/Cromwell framework is optimized to run pipelines in high-performance computing environments. The MoTrPAC Bioinformatics Center runs pipelines on Google Cloud Platform (GCP). We used a number of fantastic tools developed by our colleagues from the [ENCODE project](https://github.com/ENCODE-DCC) to run pipelines on GCP (and other HPC platforms).

A brief summary of the steps to set-up a VM to run the Motrpac pipelines on GCP (**for details, please, check the [caper repo](https://github.com/ENCODE-DCC/caper/blob/master/scripts/gcp_caper_server/README.md)**):

- Create a GCP account.
- Enable cloud APIs. 
- Install the [Google Cloud SDK](https://cloud.google.com/sdk/docs/install) (Software Development Kit) on your local machine.    
- Create a service account and download the key file to your local computer (e.g  “`service-account-191919.json`”)
- Create a bucket for pipeline inputs and outputs (e.g. gs://pipelines/). Note: a GCP bucket is similar to a folder on your computer or a storage unit, but it is stored on Google's servers in the cloud instead of on your local computer.
- Set up a VM on GCP: create a Virtual Machine (VM) instance from where the pipelines will be run. We recommend the script available in the [caper repo](https://github.com/ENCODE-DCC/caper). For that, clone the repo on your local machine and run the following command:

 ```
 $ bash create_instance.sh [INSTANCE_NAME] [PROJECT_ID] [GCP_SERVICE_ACCOUNT_KEY_JSON_FILE] [GCP_OUT_DIR]

 # Example for the pipeline:
./create_instance.sh pipeline-instance your-gcp-project-name service-account-191919.json gs://pipelines/results/
```

- Finally, clone the repo

 `git clone https://github.com/MoTrPAC/motrpac-rna-seq-pipeline`

### Software / Dockerfiles

Several tools are required to run the rna-seq pipeline. All of them are pre-installed in docker containers, which are publicly available in the [Artifact Registry](https://cloud.google.com/artifact-registry). To find out more about the specific versions of tools used to run the pipeline, check the `dockerfiles/*.Dockerfile`

### Configuration Files

An input configuration file (in JSON format) is required to process the data through the pipeline. This configuration file contains several key-value pairs that specify the inputs and outputs of the workflow, the location of the input files, default pipeline paramenters, docker containers, the execution environment, and other parameters needed for execution.

The optimal way to generate the configuration files is to run the `make_json_rnaseq.py` script. [Check this help guide to find out more](scripts/scripts_readme.md).
  
### Run the pipeline

Connect to the VM and submit the job using the below command


`caper submit rnaseq_pipeline_scatter.wdl -i input_json/set1_rnaseq.json`
    
Check the status of workflows and make sure they have succeeded by
typing `caper list` on the VM instance that's running the job and look for `Succeeded`.



