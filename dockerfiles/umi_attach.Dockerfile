FROM ubuntu:20.04 as compiler

RUN apt-get update && \
    apt-get install -y --no-install-recommends wget ca-certificates && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*

WORKDIR /usr/umi

RUN wget --progress=dot:giga \
      https://raw.githubusercontent.com/yongchao/motrpac_rnaseq/0071959641549d093c1ce669c903372ecd7c9d0d/bin/UMI_attach.awk

FROM ubuntu:20.04 as build

COPY --from=compiler /usr/umi/UMI_attach.awk ./
