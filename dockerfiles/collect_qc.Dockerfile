FROM python:3.7-slim

RUN pip install --upgrade pip setuptools wheel && \
    pip install --no-cache-dir pandas==1.0.5

# be sure to create this Docker image outside the `dockerfiles` directory (i.e docker build -t dockerfiles/collect_qc .)
# in order to be able to copy the script into the Docker image
COPY wdl/collect_qc_metrics/rnaseq_qc.py ./
