FROM alpine:3 as builder

ARG xmrigVersion=6.11.1
ARG buildJobs=9


RUN apk update && apk upgrade --available
RUN apk add alpine-sdk cmake automake autoconf libtool \
    openssl-dev openssl-libs-static libuv-dev libuv-static

# build hwloc static
WORKDIR /download/hwloc
ADD https://github.com/open-mpi/hwloc/archive/refs/tags/hwloc-2.4.1.tar.gz ../hwloc.tar.gz
RUN tar xzf ../hwloc.tar.gz --strip-components=1
RUN autoreconf -ivf && ./configure --enable-static --disable-shared LDFLAGS="--static" HWLOC_BUILD_STANDALONE=1
RUN make -j ${buildJobs} && make install

# build xmrig
WORKDIR /download/xmrig
ADD https://github.com/xmrig/xmrig/archive/refs/tags/v${xmrigVersion}.tar.gz ../xmrig.tar.gz
RUN tar xzf ../xmrig.tar.gz --strip-components=1
COPY static-lib.patch .
RUN patch -p1 < static-lib.patch

WORKDIR /build/xmrig
RUN cmake -DCMAKE_BUILD_TYPE=Release -DWITH_HWLOC=ON -DWITH_MSR=OFF -DWITH_OPENCL=OFF -DWITH_ADL=OFF -DWITH_STRICT_CACHE=OFF -DWITH_BENCHMARK=OFF -DWITH_HTTP=OFF -DWITH_CUDA=OFF -DWITH_NVML=OFF -DBUILD_STATIC=ON /download/xmrig
RUN cmake --build . --parallel ${buildJobs}


FROM alpine:edge

ARG TZ=Australia/Sydney
ARG xmrigVersion=6.11.1

LABEL maintainer="Xi Shen" \
    xmrig.version="${xmrigVersion}"

ENV TZ=${TZ}
RUN apk add tzdata
RUN cp /usr/share/zoneinfo/${TZ} /etc/localtime
RUN echo "${TZ}" > /etc/localtime
RUN apk del tzdata
RUN apk update && apk upgrade --available

WORKDIR /xmrig
COPY --from=builder /build/xmrig/xmrig ./

ENTRYPOINT ["./xmrig"]
