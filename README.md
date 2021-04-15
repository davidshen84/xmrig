# README

The [xmrig][1] miner in a docker container.

Please consulte the official repository for [config.json][2].

- ✔ CPU mining
- ✔ CUDA mining
- ❌ OpenCL mining


## Build details

| component  | version |
|------------|---------|
| xmrig      | 6.11.1  |
| xmrig-cuda | 6.5.0   |
| cuda       | 11.2.2  |
| ubuntu     | 20.04   |

## CPU mining example

    docker run --rm -it -v $(pwd)/config.json:/xmrig/config.json xmrig:cpu

## CUDA mining example

Your system needs to have the *nvidia driver*, `nvidia-docker` and
necessary `docker` components installed and your docker daemon is
configured to use `nvidia-docker` runtime.

    nvidia-docker --rm -it -v $(pwd)/config.json:/xmrig/config.json xmrig:cuda


[1]: https://xmrig.com/
[2]: https://github.com/xmrig/xmrig/blob/v6.11.1/src/config.json
