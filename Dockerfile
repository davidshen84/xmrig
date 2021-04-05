FROM nvidia/cuda:11.2.2-devel-ubuntu20.04 as builder

ARG TZ=Australia/Sydney
ARG xmrigVersion=6.10.0
ARG xmrigCudaVersion=6.5.0
ARG cmakeJobs=9

ENV TZ=${TZ}
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN apt-get update
RUN apt-get -y upgrade
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install tzdata
RUN apt-get -y install curl cmake
RUN apt-get -y install libhwloc-dev libuv1-dev libssl-dev nvidia-cuda-dev

FROM builder as builder2

# unpack source code
WORKDIR /download
RUN mkdir xmrig && mkdir xmrig-cuda
RUN curl -Ls https://github.com/xmrig/xmrig/archive/refs/tags/v${xmrigVersion}.tar.gz | tar xz -C xmrig --strip-components=1
RUN curl -Ls https://github.com/xmrig/xmrig-cuda/archive/refs/tags/v${xmrigCudaVersion}.tar.gz | tar xz -C xmrig-cuda --strip-components=1

# build xmrig
WORKDIR /build/xmrig
RUN cmake -DWITH_NVML=OFF -DWITH_MSR=OFF /download/xmrig
RUN cmake --build . --parallel ${cmakeJobs}

# build xmrig-cuda
WORKDIR /build/xmrig-cuda
RUN cmake /download/xmrig-cuda
RUN cmake --build . --parallel ${cmakeJobs}


FROM nvidia/cuda:11.2.2-runtime-ubuntu20.04

ARG xmrigVersion=6.10.0
ARG xmrigCudaVersion=6.5.0

LABEL maintainer="Xi Shen" \
    xmrig.version="${xmrigVersion}" \
    xmrig.cuda.version="${xmrigCudaVersion}"

RUN apt-get update && apt-get -y upgrade && \
    apt-get -y install hwloc libuv1 && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /xmrig
COPY --from=builder2 /build/xmrig/xmrig /build/xmrig-cuda/libxmrig-cuda.so ./

# ENTRYPOINT ["./xmrig"]
