FROM ubuntu:20.04 as compiler

RUN apt-get update && \
    apt-get install -y --no-install-recommends wget tar && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*

WORKDIR /usr/featurecounts

RUN wget -O --progress=dot:giga subread.tar.gz \
      https://sourceforge.net/projects/subread/files/subread-1.6.3/subread-1.6.3-Linux-x86_64.tar.gz/download && \
    tar -zxvf subread.tar.gz

FROM ubuntu:20.04 as build

COPY --from=compiler /usr/featurecounts/subread-*/bin/fe* /usr/local/bin/
