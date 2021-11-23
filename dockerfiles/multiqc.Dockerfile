FROM python:3.7-slim

RUN pip install --upgrade pip setuptools wheel && \
    pip --no-cache-dir install multiqc==1.6
