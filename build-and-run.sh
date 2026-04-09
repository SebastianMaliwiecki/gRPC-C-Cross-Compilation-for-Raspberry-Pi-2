#!/usr/bin/env bash
# build-and-run.sh — Build the Docker image and drop into a shell
# Usage:
#   ./build-and-run.sh                  # interactive shell
#   ./build-and-run.sh build            # just build the image
#   ./build-and-run.sh cmake <path>     # run cmake + make inside container

set -euo pipefail

IMAGE_NAME="pi2-grpc-cross"
WORKSPACE="${PI_WORKSPACE:-$(pwd)}"

# ── Build the Docker image ──
build_image() {
    echo "==> Building cross-compilation image: ${IMAGE_NAME}"
    docker build -t "${IMAGE_NAME}" "$(dirname "$0")"
}

# ── Run container with workspace mounted ──
run_shell() {
    echo "==> Launching container (mounting ${WORKSPACE} → /workspace)"
    docker run --rm -it \
        -v "${WORKSPACE}:/workspace" \
        -e "TOOLCHAIN_FILE=/opt/toolchain/toolchain-armhf.cmake" \
        "${IMAGE_NAME}" \
        /bin/bash
}

# ── Build a CMake project inside the container ──
run_cmake_build() {
    local src_dir="${1:-.}"
    echo "==> Cross-compiling ${src_dir} for armhf"
    docker run --rm \
        -v "${WORKSPACE}:/workspace" \
        "${IMAGE_NAME}" \
        bash -c "
            mkdir -p /workspace/${src_dir}/build-armhf && \
            cd /workspace/${src_dir}/build-armhf && \
            cmake .. \
                -DCMAKE_TOOLCHAIN_FILE=/opt/toolchain/toolchain-armhf.cmake \
                -GNinja && \
            ninja
        "
    echo "==> Done. Binaries are in ${src_dir}/build-armhf/"
}

case "${1:-shell}" in
    build)  build_image ;;
    shell)  build_image; run_shell ;;
    cmake)  build_image; run_cmake_build "${2:-.}" ;;
    *)      echo "Usage: $0 {build|shell|cmake <path>}"; exit 1 ;;
esac
