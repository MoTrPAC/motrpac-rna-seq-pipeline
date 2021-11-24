FROM ubuntu:20.04 as compiler

RUN apt-get update && \
    apt-get install -y --no-install-recommends wget ca-certificates && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*

WORKDIR /usr/gtfToGenePred
RUN wget --progress=dot:giga https://hgdownload.cse.ucsc.edu/admin/exe/linux.x86_64/gtfToGenePred

FROM ubuntu:20.04 as build

RUN apt-get update && \
    apt-get install -y --no-install-recommends libkrb5-dev && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*

COPY --from=compiler /usr/gtfToGenePred/gtfToGenePred /usr/local/bin/

RUN chmod 755 /usr/local/bin/gtfToGenePred
