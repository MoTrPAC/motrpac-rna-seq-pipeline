FROM ubuntu:20.04 as compiler

RUN apt-get update && \
    apt-get install -y --no-install-recommends wget zip unzip ca-certificates && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*

WORKDIR /usr/fastqc
# Install FastQC-0.11.8
RUN wget --progress=dot:giga https://www.bioinformatics.babraham.ac.uk/projects/fastqc/fastqc_v0.11.8.zip && \
    unzip fastqc_v0.11.8.zip

FROM openjdk:8-jre-slim-buster as build

COPY --from=compiler /usr/fastqc/FastQC/fastqc /usr/local/bin/

RUN chmod 755 /usr/local/bin/fastqc
