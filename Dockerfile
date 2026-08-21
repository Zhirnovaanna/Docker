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
        libncurses-dev \
        wget \
        zlib1g-dev \
        autoconf \
        automake \
        perl \
        pkg-config \
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

# SAMtools, version 1.24, released 2026-07-09
RUN cd /tmp \
	&& wget -q https://github.com/samtools/samtools/releases/download/1.24/samtools-1.24.tar.bz2 \
	&& tar -xjf samtools-1.24.tar.bz2 \
	&& cd samtools-1.24 \
	&& ./configure \
		--prefix=${SOFT}/samtools-1.24 \
		--with-htslib=${SOFT}/htslib-1.24 \
		LDFLAGS="-Wl,-rpath,${SOFT}/htslib-1.24/lib" \
	&& make -j $(nproc) \
	&& make install \
	&& cd / \
	&& rm -rf /tmp/samtools-1.24.tar.bz2 /tmp/samtools-1.24

# BCFtools, version 1.24, released 2026-07-09
RUN cd /tmp \
	&& wget -q https://github.com/samtools/bcftools/releases/download/1.24/bcftools-1.24.tar.bz2 \
	&& tar -xjf bcftools-1.24.tar.bz2 \
	&& cd bcftools-1.24 \
	&& ./configure \
		--prefix=${SOFT}/bcftools-1.24 \
		--with-htslib=${SOFT}/htslib-1.24 \
		LDFLAGS="-Wl,-rpath,${SOFT}/htslib-1.24/lib" \
	&& make -j $(nproc) \
	&& make install \
	&& cd / \
	&& rm -rf /tmp/bcftools-1.24.tar.bz2 /tmp/bcftools-1.24

# VCFtools, version 0.1.17, released 2025-05-15
RUN cd /tmp \
	&& wget -q -O vcftools-0.1.17.tar.gz https://github.com/vcftools/vcftools/archive/refs/tags/v0.1.17.tar.gz \
	&& tar -xzf vcftools-0.1.17.tar.gz \
	&& cd vcftools-0.1.17 \
	&& ./autogen.sh \
	&& ./configure --prefix=${SOFT}/vcftools-0.1.17 \
	&& make -j $(nproc) \
	&& make install \
	&& ln -sfn "$(dirname $(find ${SOFT}/vcftools-0.1.17/share/perl -name Vcf.pm | head -1))" \
		${SOFT}/vcftools-0.1.17/share/perl5 \
	&& cd / \
	&& rm -rf /tmp/vcftools-0.1.17.tar.gz /tmp/vcftools-0.1.17

# Переменные окружения
ENV PATH="${SOFT}/libdeflate-1.25/bin:${SOFT}/htslib-1.24/bin:${SOFT}/samtools-1.24/bin:${SOFT}/bcftools-1.24/bin:${SOFT}/vcftools-0.1.17/bin:${PATH}"
ENV PERL5LIB="${SOFT}/vcftools-0.1.17/share/perl5:${PERL5LIB}"
ENV SAMTOOLS="${SOFT}/samtools-1.24/bin/samtools"
ENV BCFTOOLS="${SOFT}/bcftools-1.24/bin/bcftools"
ENV VCFTOOLS="${SOFT}/vcftools-0.1.17/bin/vcftools"

WORKDIR /data
CMD ["bash"]
