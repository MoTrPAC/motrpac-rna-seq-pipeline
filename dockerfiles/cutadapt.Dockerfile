FROM python:3.7-slim-bullseye

RUN apt-get update && \
    apt-get install -y --no-install-recommends gawk procps && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*

RUN pip install --upgrade pip setuptools wheel && \
    pip install --no-cache-dir cutadapt==1.18
