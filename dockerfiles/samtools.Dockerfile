FROM ubuntu:20.04 as compiler

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      autoconf automake make gcc perl zlib1g-dev libbz2-dev liblzma-dev \
      libcurl4-gnutls-dev libssl-dev libncurses5-dev git && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*

ARG VERSION=1.3.1
ARG BUILD_DIR=/usr/samtools

RUN git clone --depth 1 --branch ${VERSION} https://github.com/broadinstitute/picard.git ${BUILD_DIR}

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

WORKDIR /usr/local/bin

COPY --from=compiler /usr/samtools/samtools ./
