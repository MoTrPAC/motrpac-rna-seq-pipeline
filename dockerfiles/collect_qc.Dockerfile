FROM python:3.7-slim-bullseye

RUN apt-get update && \
    apt-get install -y --no-install-recommends procps && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*

RUN pip install --upgrade pip setuptools wheel && \
    pip install --no-cache-dir pandas==1.0.5

# be sure to create this Docker image outside the `dockerfiles` directory (i.e docker build -t dockerfiles/collect_qc .)
# in order to be able to copy the script into the Docker image
COPY wdl/collect_qc_metrics/rnaseq_qc.py /usr/local/src/rnaseq_qc.py

RUN chmod 755 /usr/local/src/rnaseq_qc.py
