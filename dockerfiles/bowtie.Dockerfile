FROM ubuntu:20.04 as compiler

RUN apt-get update && \
    apt-get install -y --no-install-recommends ca-certificates wget zip unzip && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*

WORKDIR /usr/bowtie

RUN wget --progress=dot:giga -O bowtie2.zip \
      https://sourceforge.net/projects/bowtie-bio/files/bowtie2/2.3.4.3/bowtie2-2.3.4.3-linux-x86_64.zip/download && \
	unzip bowtie2.zip && \
    rm -rf bowtie2.zip

FROM ubuntu:20.04 as build

RUN apt-get update && \
    apt-get install -y --no-install-recommends gawk perl perl-modules procps && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*

COPY --from=compiler /usr/bowtie/bowtie2* /usr/local/bin/
