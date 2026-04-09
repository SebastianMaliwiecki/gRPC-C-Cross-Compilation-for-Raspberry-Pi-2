#!/usr/bin/env bash
# build_docker.sh — Cross-compile the gRPC project for Raspberry Pi 2 inside Docker
# Usage: ./build_docker.sh
#
# Run from: ~/workspace/grpc-mini-projects/grpc-todo/cpp/
 
set -euo pipefail
 
IMAGE_NAME="pi2-grpc-cross"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# Mount grpc-todo/ so the proto folder is accessible
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
BUILD_DIR="build-armhf"
 
echo "==> Building Docker image (skipped if already built)..."
docker build -t "${IMAGE_NAME}" "${SCRIPT_DIR}"
 
echo "==> Cross-compiling for Raspberry Pi 2 (armhf)..."
docker run --rm \
    -v "${PROJECT_ROOT}:/workspace" \
    "${IMAGE_NAME}" \
    bash -c "
        cd /workspace/cpp && \
        rm -rf ${BUILD_DIR} && \
        mkdir ${BUILD_DIR} && \
        cd ${BUILD_DIR} && \
        cmake .. \
            -DCMAKE_TOOLCHAIN_FILE=/opt/toolchain/toolchain-armhf.cmake \
            -GNinja && \
        ninja
    "
 
echo ""
echo "==> Build complete! Binaries are in:"
echo "    ${SCRIPT_DIR}/${BUILD_DIR}/todo_server"
echo "    ${SCRIPT_DIR}/${BUILD_DIR}/todo_client"
echo ""
echo "==> Deploy to Pi with:"
echo "    scp ${BUILD_DIR}/todo_server ${BUILD_DIR}/todo_client sebm@pi:~/workspace/grpc-mini-projects/grpc-todo/cpp/"