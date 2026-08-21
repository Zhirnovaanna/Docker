FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive
ENV SOFT=/soft

# Дополнительные пакеты
RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
        ca-certificates \
        cmake \
        wget \
        && rm -rf /var/lib/apt/lists/*

# libdeflate, version 1.25, released 2025-11-01
RUN cd /tmp \
        && wget -q https://github.com/ebiggers/libdeflate/releases/download/v1.25/libdeflate-1.25.tar.gz \
        && tar -xzf libdeflate-1.25.tar.gz \
        && cd libdeflate-1.25 \
        && cmake -B build \
                -DCMAKE_BUILD_TYPE=Release \
                -DCMAKE_INSTALL_PREFIX=${SOFT}/libdeflate-1.25 \
        && cmake --build build -j $(nproc) \
        && cmake --install build \
        && cd / \
        && rm -rf /tmp/libdeflate-1.25.tar.gz /tmp/libdeflate-1.25

WORKDIR /data
CMD ["bash"]
