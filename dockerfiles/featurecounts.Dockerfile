FROM ubuntu:20.04

RUN apt-get update && \
    apt-get install -y wget tar && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*

WORKDIR /usr/bowtie

RUN wget -O subread.tar.gz \
      https://sourceforge.net/projects/subread/files/subread-1.6.3/subread-1.6.3-Linux-x86_64.tar.gz/download && \
    tar -zxvf subread.tar.gz && \
    rm -rf subread.tar.gz && \
    mv subread-*/bin/fe* /usr/local/bin/
