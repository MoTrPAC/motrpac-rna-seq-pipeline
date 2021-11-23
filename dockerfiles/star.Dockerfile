FROM ubuntu:20.04 as compiler

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      make gcc perl git g++ ca-certificates zlib1g-dev libbz2-dev liblzma-dev && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*

ARG VERSION=2.7.0d
ARG BUILD_DIR=/usr/star

RUN git clone --depth 1 --branch ${VERSION} https://github.com/alexdobin/STAR.git ${BUILD_DIR}

WORKDIR ${BUILD_DIR}/source

RUN make STARstatic

FROM ubuntu:20.04 as build

COPY --from=compiler /usr/star/source/STAR /usr/local/bin/
