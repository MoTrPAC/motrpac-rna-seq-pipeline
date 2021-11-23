FROM ubuntu:20.04 as compiler

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      autoconf automake make gcc perl zlib1g-dev libbz2-dev liblzma-dev \
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

FROM ubuntu:20.04 as build

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      zlib1g-dev libbz2-dev liblzma-dev libcurl4-gnutls-dev  \
      libssl-dev libncurses5-dev && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*

COPY --from=compiler /usr/samtools/samtools /usr/local/bin/
