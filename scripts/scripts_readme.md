# Scripts

### `make_json_rnaseq.py`

Generates the input configuration file required to run the rna-seq pipeline.

- Requires Python `>3.6.9`
- Install required packages by running `pip3 install -r scripts/requirements.txt`

```
usage: make_json_rnaseq.py [-h] [-g GCP_PATH] [-o OUTPUT_PATH]
                           [-r OUTPUT_REPORT_NAME] [-u] [-a {rat,human}]
                           [-n NUM_CHUNKS] [-d DOCKER_REPO]

This script is used to generate input json files from the fastq_raw dir on gcp
for running rna-seq pipeline on GCP

optional arguments:
  -h, --help            show this help message and exit
  -g GCP_PATH, --gcp_path GCP_PATH
                        location of the submission batch directory in gcp that
                        contains the fastq_raw dir
  -o OUTPUT_PATH, --output_path OUTPUT_PATH
                        output path, where you want the input jsons to be
                        written
  -r OUTPUT_REPORT_NAME, --output_report_name OUTPUT_REPORT_NAME
                        name of the output report to be written
  -u, --undetermined    Adding this flag will process undetermined FastQ files
                        if they exist. These are fastq files with prefix
                        "Undetermined_". If this flag isn't passed, items with
                        prefix "Undetermined_" will be removed
  -a {rat,human}, --organism {rat,human}
                        organism name, e.g. rat or human
  -n NUM_CHUNKS, --num_chunks NUM_CHUNKS
                        number of chunks to split the input files, should
                        always be <= number of input files
  -d DOCKER_REPO, --docker_repo DOCKER_REPO
                        Docker repository prefix containing the images used in
                        the workflow
```

Example

```
python3 make_json_rnaseq.py -g gs://motrpac/rna-seq/test \
-o `pwd`/input_json \
-r rna-seq-test \
-a rat \
-n 1 \
-d gcr.io/motrpac-portal/motrpac-rna-seq-pipeline
```
