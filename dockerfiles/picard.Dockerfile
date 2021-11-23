FROM adoptopenjdk:8 as builder

# Install ant, git for building
RUN apt-get update && \
    apt-get --no-install-recommends install -y git r-base ant && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*

ARG VERSION=2.18.16
ARG BUILD_DIR=/usr/picard

# Assumes Dockerfile lives in root of the git repo. Pull source files into container
RUN git clone --depth 1 --branch ${VERSION} https://github.com/broadinstitute/picard.git ${BUILD_DIR}
WORKDIR ${BUILD_DIR}

# Build the distribution jar
RUN ./gradlew shadowJar

FROM openjdk:8-jre-slim-buster

COPY --from=builder  /usr/picard/build/libs/picard.jar /usr/local/bin/picard.jar
