FROM ubuntu:20.04 as nudup-compiler

RUN apt-get update && \
    apt-get install -y --no-install-recommends wget ca-certificates && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*

WORKDIR /usr/nudup

# Download nudup.py from January 2018
RUN wget --progress=dot:giga \
      https://raw.githubusercontent.com/nugentechnologies/nudup/555756bbbdc5c83c4d4b00cda9f51758393583ca/nudup.py

FROM debian:buster as samtools-compiler

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      autoconf automake make gcc perl zlib1g-dev libbz2-dev liblzma-dev bzip2 \
      libcurl4-gnutls-dev libssl-dev libncurses5-dev wget git ca-certificates && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*

ARG VERSION=1.3.1
ARG BUILD_DIR=/usr/samtools

RUN mkdir -p ${BUILD_DIR} && \
    wget --progress=dot:giga https://github.com/samtools/samtools/releases/download/1.3.1/samtools-1.3.1.tar.bz2 && \
    tar -vxjf samtools-1.3.1.tar.bz2 && \
    mv samtools-1.3.1/* ${BUILD_DIR}

WORKDIR ${BUILD_DIR}

RUN autoheader && \
    autoconf -Wno-syntax && \
    ./configure && \
    make

FROM python:2.7-slim-buster as build

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      zlib1g-dev libbz2-dev liblzma-dev libcurl4-gnutls-dev  \
      libssl-dev libncurses5-dev gawk procps && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*

COPY --from=nudup-compiler /usr/nudup/nudup.py /usr/local/src/nudup.py

RUN chmod 755 /usr/local/src/nudup.py

COPY --from=samtools-compiler /usr/samtools/samtools /usr/local/bin/

