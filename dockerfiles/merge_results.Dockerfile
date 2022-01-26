FROM python:3.7-slim-bullseye

RUN apt-get update && \
    apt-get install -y --no-install-recommends procps && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*

RUN pip install --upgrade pip setuptools wheel && \
    pip install --no-cache-dir pandas==1.0.5

# be sure to create this Docker image outside the `dockerfiles` directory
# (i.e docker build -t motrpac-rna-seq-pipeline/merge_results -f dockerfiles/merge_results.Dockerfile .)
# in order to be able to copy the script into the Docker image
COPY wdl/merge_results/consolidate_qc_report.py /usr/local/src/consolidate_qc_report.py
COPY wdl/merge_results/merge_fc.py /usr/local/src/merge_fc.py
COPY wdl/merge_results/merge_rsem.py /usr/local/src/merge_rsem.py

RUN chmod 755 /usr/local/src/*.py
