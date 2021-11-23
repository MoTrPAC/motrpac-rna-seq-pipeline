FROM ubuntu:20.04

RUN apt-get update && \
    apt-get install -y wget libkrb5-dev && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*

WORKDIR /usr/local/bin
RUN wget https://hgdownload.cse.ucsc.edu/admin/exe/linux.x86_64/gtfToGenePred && \
    chmod 755 gtfToGenePred
