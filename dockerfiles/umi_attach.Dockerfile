FROM ubuntu:20.04

RUN apt-get update && \
    apt-get install -y --no-install-recommends wget && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*

RUN wget --no-check-certificate --progress=dot:giga \
      https://raw.githubusercontent.com/yongchao/motrpac_rnaseq/0071959641549d093c1ce669c903372ecd7c9d0d/bin/UMI_attach.awk && \
    chmod 755 UMI_attach.awk
