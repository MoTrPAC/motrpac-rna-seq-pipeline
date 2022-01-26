FROM ubuntu:20.04 as compiler

RUN apt-get update && \
    apt-get install -y --no-install-recommends wget ca-certificates perl perl-modules && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*

WORKDIR /usr/umi

RUN wget --progress=dot:giga \
      https://raw.githubusercontent.com/yongchao/motrpac_rnaseq/0071959641549d093c1ce669c903372ecd7c9d0d/bin/UMI_attach.awk

FROM ubuntu:20.04 as build

RUN apt-get update && \
    apt-get install -y --no-install-recommends gawk procps && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*

COPY --from=compiler /usr/umi/UMI_attach.awk /usr/local/src/UMI_attach.awk

RUN chmod 755 /usr/local/src/UMI_attach.awk
