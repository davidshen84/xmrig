FROM ubuntu:20.04 as builder

RUN apt-get update
RUN apt-get -y upgrade
RUN apt-get -y install wget
RUN rm -rf /var/lib/apt/lists/*
WORKDIR /tmp
RUN wget https://github.com/xmrig/xmrig/releases/download/v6.10.0/xmrig-6.10.0-focal-x64.tar.gz
RUN tar xaf xmrig-6.10.0-focal-x64.tar.gz

FROM ubuntu:20.04

WORKDIR /xmrig
COPY --from=builder /tmp/xmrig-6.10.0 ./
# ENTRYPOINT ["/usr/bin/cgminer", "--text-only"]
