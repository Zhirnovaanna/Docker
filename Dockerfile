FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive
ENV SOFT=/soft

# Дополнительные пакеты
RUN apt-get update && apt-get install -y --no-install-recommends \
	build-essential \
        bzip2 \
        ca-certificates \
        cmake \
        libbz2-dev \
        libcurl4-openssl-dev \
        liblzma-dev \
        wget \
        zlib1g-dev \
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

# HTSlib, version 1.24, released 2026-07-09
RUN cd /tmp \
	&& wget -q https://github.com/samtools/htslib/releases/download/1.24/htslib-1.24.tar.bz2 \
	&& tar -xjf htslib-1.24.tar.bz2 \
	&& cd htslib-1.24 \
	&& ./configure \
		--prefix=${SOFT}/htslib-1.24 \
		CPPFLAGS="-I${SOFT}/libdeflate-1.25/include" \
		LDFLAGS="-L${SOFT}/libdeflate-1.25/lib -Wl,-rpath,${SOFT}/libdeflate-1.25/lib" \
	&& make -j $(nproc) \
	&& make install \
	&& cd / \
	&& rm -rf /tmp/htslib-1.24.tar.bz2 /tmp/htslib-1.24


WORKDIR /data
CMD ["bash"]
