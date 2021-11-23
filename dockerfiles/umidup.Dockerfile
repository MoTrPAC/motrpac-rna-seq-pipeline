FROM python:3.7-slim

RUN apt-get update && \
    apt-get install -y --no-install-recommends wget && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*

WORKDIR /usr/local/bin

RUN wget https://raw.githubusercontent.com/yongchao/motrpac_rnaseq/0071959641549d093c1ce669c903372ecd7c9d0d/bin/UMI_attach.awk && \
    chmod 755 UMI_attach.awk

# Download nudup.py from January 2018
RUN wget https://raw.githubusercontent.com/nugentechnologies/nudup/555756bbbdc5c83c4d4b00cda9f51758393583ca/nudup.py && \
    chmod 755 /src/nudup.py
