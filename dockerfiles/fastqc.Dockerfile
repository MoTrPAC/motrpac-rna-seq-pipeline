FROM debian:bullseye as compiler

RUN apt-get update && \
    apt-get install -y --no-install-recommends wget zip unzip ca-certificates && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*

WORKDIR /usr/fastqc
# Install FastQC-0.11.8
RUN wget --progress=dot:giga https://www.bioinformatics.babraham.ac.uk/projects/fastqc/fastqc_v0.11.8.zip && \
    unzip fastqc_v0.11.8.zip

FROM openjdk:8-jre-slim-bullseye as build

RUN apt-get update && \
    apt-get install -y --no-install-recommends perl perl-modules procps libfreetype6 && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*

COPY --from=compiler /usr/fastqc /usr/fastqc

RUN chmod 755 /usr/fastqc/FastQC/fastqc && \
    ln -s /usr/fastqc/FastQC/fastqc /usr/local/bin
