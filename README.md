# README

The [xmrig][1] miner in a docker container.

Please consulte the official repository for [config.json][2].

- :heavy_check_mark: CPU mining
- :x: CUDA mining
- :x: OpenCL mining


## Example

    docker run --rm -it -v $(pwd)/config.json:/xmrig/config.json xmrig:cpu


[1]: https://xmrig.com/
[2]: https://github.com/xmrig/xmrig/blob/v6.11.1/src/config.json
