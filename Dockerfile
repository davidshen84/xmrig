FROM nvidia/cuda:11.2.2-devel-ubuntu20.04 as builder

ARG TZ=Australia/Sydney
ARG xmrigVersion=6.10.0
ARG xmrigCudaVersion=6.5.0
ARG cmakeJobs=9

ENV TZ=${TZ}
ENV DEBIAN_FRONTEND="noninteractive"
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN apt-get update && apt-get -y upgrade
RUN apt-get -y install tzdata && \
    dpkg-reconfigure --frontend noninteractive tzdata
RUN apt-get -y install cmake \
    libhwloc-dev libuv1-dev libssl-dev nvidia-cuda-dev

# unpack source code
WORKDIR /download
RUN mkdir xmrig && mkdir xmrig-cuda
ADD https://github.com/xmrig/xmrig/archive/refs/tags/v${xmrigVersion}.tar.gz xmrig.tar.gz
ADD https://github.com/xmrig/xmrig-cuda/archive/refs/tags/v${xmrigCudaVersion}.tar.gz xmrig-cuda.tar.gz
RUN tar xzf xmrig.tar.gz -C xmrig --strip-components=1
RUN tar xzf xmrig-cuda.tar.gz -C xmrig-cuda --strip-components=1

# build xmrig
WORKDIR /build/xmrig
RUN cmake -DWITH_MSR=OFF /download/xmrig
RUN cmake --build . --parallel ${cmakeJobs}

# build xmrig-cuda
WORKDIR /build/xmrig-cuda
RUN cmake /download/xmrig-cuda
RUN cmake --build . --parallel ${cmakeJobs}


FROM nvidia/cuda:11.2.2-runtime-ubuntu20.04

ARG TZ
ARG xmrigVersion
ARG xmrigCudaVersion

LABEL maintainer="Xi Shen" \
    xmrig.version="${xmrigVersion}" \
    xmrig.cuda.version="${xmrigCudaVersion}"

ENV TZ=${TZ}
ENV DEBIAN_FRONTEND="noninteractive"
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN apt-get update && apt-get -y upgrade
RUN apt-get -y install tzdata && \
    dpkg-reconfigure --frontend noninteractive tzdata
RUN apt-get -y install hwloc libuv1 cuda-11-2 && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /xmrig
COPY --from=builder /build/xmrig/xmrig /build/xmrig-cuda/libxmrig-cuda.so ./

ENTRYPOINT ["./xmrig"]
