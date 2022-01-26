FROM ubuntu:20.04 as compiler

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      ca-certificates make perl gcc git g++ zlib1g-dev libbz2-dev liblzma-dev \
      libcurl4-gnutls-dev libssl-dev libncurses5-dev && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*

ARG VERSION=v1.3.1
ARG BUILD_DIR=/usr/rsem

RUN git clone --depth 1 --branch ${VERSION} https://github.com/deweylab/RSEM.git ${BUILD_DIR}

WORKDIR ${BUILD_DIR}
RUN make && make install
RUN ls -la


FROM ubuntu:20.04 as build

ENV DEBIAN_FRONTEND="noninteractive"

RUN apt-get update && \
    apt-get install -y --no-install-recommends r-base perl perl-modules procps && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*

COPY --from=compiler /usr/rsem/rsem* /usr/local/bin/
