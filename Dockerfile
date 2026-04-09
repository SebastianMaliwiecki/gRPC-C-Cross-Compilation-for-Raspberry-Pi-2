# Cross-compilation Docker image for Raspberry Pi 2 Model B (armv7l / armhf)
# Matches Raspbian trixie (Debian 13) packages on the Pi
FROM debian:trixie

ENV DEBIAN_FRONTEND=noninteractive

# ── 1. Rewrite sources to pin amd64 for host packages ──
RUN echo 'Types: deb\n\
URIs: http://deb.debian.org/debian\n\
Suites: trixie trixie-updates\n\
Components: main\n\
Architectures: amd64\n\
Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg\n\
\n\
Types: deb\n\
URIs: http://deb.debian.org/debian-security\n\
Suites: trixie-security\n\
Components: main\n\
Architectures: amd64\n\
Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg' \
    > /etc/apt/sources.list.d/debian.sources

# ── 2. Install host build tools ──
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    ninja-build \
    git \
    wget \
    curl \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

# ── 3. Add armhf architecture with its own repos ──
RUN dpkg --add-architecture armhf
RUN echo "deb [arch=armhf] http://deb.debian.org/debian trixie main" \
      > /etc/apt/sources.list.d/armhf-trixie.list && \
    echo "deb [arch=armhf] http://deb.debian.org/debian trixie-updates main" \
      >> /etc/apt/sources.list.d/armhf-trixie.list && \
    echo "deb [arch=armhf] http://deb.debian.org/debian-security trixie-security main" \
      >> /etc/apt/sources.list.d/armhf-trixie.list

# ── 4. Install armhf gRPC/protobuf libs + host protoc ──
RUN apt-get update && apt-get install -y \
    libc6:armhf \
    libstdc++6:armhf \
    libgrpc++-dev:armhf \
    libgrpc-dev:armhf \
    libprotobuf-dev:armhf \
    protobuf-compiler \
    protobuf-compiler-grpc \
    && rm -rf /var/lib/apt/lists/*

# ── 5. Install cross-compiler AFTER armhf packages ──
#    This ensures the gcc/g++ binaries are the amd64 cross-compiler
#    and not the armhf native compiler
RUN apt-get update && apt-get install -y --reinstall \
    gcc-arm-linux-gnueabihf \
    g++-arm-linux-gnueabihf \
    && rm -rf /var/lib/apt/lists/*

# ── 6. Verify the cross-compiler works ──
RUN echo 'int main(){return 0;}' > /tmp/test.c && \
    arm-linux-gnueabihf-gcc /tmp/test.c -o /tmp/test && \
    echo "Cross-compiler works - OK" && rm /tmp/test.c /tmp/test

# ── 7. Create CMake toolchain file for armhf cross-compilation ──
RUN mkdir -p /opt/toolchain
COPY toolchain-armhf.cmake /opt/toolchain/toolchain-armhf.cmake

# ── 8. Set up working directory ──
WORKDIR /workspace

CMD ["/bin/bash"]