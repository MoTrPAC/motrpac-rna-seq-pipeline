FROM python:3.7-slim

RUN pip install --upgrade pip setuptools wheel && \
    pip install --no-cache-dir cutadapt==1.18
