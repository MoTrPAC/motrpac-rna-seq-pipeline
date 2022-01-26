FROM python:3.7-slim-bullseye

RUN apt-get update && \
    apt-get install -y --no-install-recommends procps && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*

RUN pip install --upgrade pip setuptools wheel && \
    pip install --no-cache-dir pyyaml==3.13 multiQC==1.6
