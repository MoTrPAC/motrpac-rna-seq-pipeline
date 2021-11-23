FROM openjdk:8-jre-slim-buster

RUN apt-get update && \
    apt-get install -y wget zip && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*

WORKDIR /usr/local/bin
# Install FastQC-0.11.8
RUN wget https://www.bioinformatics.babraham.ac.uk/projects/fastqc/fastqc_v0.11.8.zip && \
    unzip fastqc_v0.11.8.zip && \
    rm fastqc_v0.11.8.zip && \
    mv FastQC/fastqc ./ && \
    chmod 755 fastqc && \
    rm -rf FastQC \

WORKDIR /home
