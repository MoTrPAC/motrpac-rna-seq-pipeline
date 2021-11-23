FROM python:2.7-slim

RUN apt-get update && \
    apt-get install -y --no-install-recommends wget && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*

# Download nudup.py from January 2018
RUN wget --progress=dot:giga \
      https://raw.githubusercontent.com/nugentechnologies/nudup/555756bbbdc5c83c4d4b00cda9f51758393583ca/nudup.py
