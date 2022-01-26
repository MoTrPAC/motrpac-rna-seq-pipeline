FROM adoptopenjdk:8-jdk-hotspot-focal as picard-compiler

# Install ant, git for building
RUN apt-get update && \
    apt-get --no-install-recommends install -y git r-base ant && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*

ARG VERSION=2.18.16
ARG BUILD_DIR=/usr/picard

# Assumes Dockerfile lives in root of the git repo. Pull source files into container
RUN git clone --depth 1 --branch ${VERSION} https://github.com/broadinstitute/picard.git ${BUILD_DIR}
WORKDIR ${BUILD_DIR}

# Build the distribution jar
RUN ./gradlew shadowJar

# Compile SAMTools
FROM debian:bullseye as samtools-compiler

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

# Final minimal build image
FROM openjdk:8-jre-slim-bullseye as build

# Install R
RUN apt-get update && \
    apt-get --no-install-recommends install -y r-base procps && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*

COPY --from=picard-compiler  /usr/picard/build/libs/picard.jar /usr/local/bin/picard.jar
COPY --from=samtools-compiler /usr/samtools/samtools /usr/local/bin/
