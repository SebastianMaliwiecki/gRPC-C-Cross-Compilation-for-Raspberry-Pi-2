# gRPC C++ Cross-Compilation for Raspberry Pi 2

Cross-compile gRPC C++ projects on x86_64 Linux (or WSL) for Raspberry Pi 2 Model B using Docker. No need to install any cross-compilation tools on your host machine — everything runs inside a container.

## Target

- **Board:** Raspberry Pi 2 Model B (armv7l / armhf)
- **OS:** Raspbian trixie (Debian 13)
- **gRPC:** 1.51.1-6 (from Debian packages)

## Prerequisites

- Docker installed on your build machine
- Your project structured like this:

```
grpc-todo/
├── proto/
│   └── todo.proto
└── cpp/
    ├── CMakeLists.txt
    ├── server.cpp
    ├── client.cpp
    ├── Dockerfile
    ├── toolchain-armhf.cmake
    ├── build_docker.sh
    └── build-and-run.sh
```

## Quick Start

```bash
cd cpp/
chmod +x build_docker.sh build-and-run.sh

# Build for the Pi (one command)
./build_docker.sh
```

The first run takes a few minutes while Docker builds the image. After that, only your code gets compiled so it's fast.

Binaries are output to `build-armhf/`.

## Deploy to Pi

```bash
scp build-armhf/todo_server build-armhf/todo_client user@pi:~/path/to/project/
```

### Pi dependencies

The Pi needs the gRPC runtime libraries installed:

```bash
sudo apt install libgrpc++1.51t64 libgrpc29t64
```

## Interactive Mode

If you want to poke around inside the container:

```bash
./build-and-run.sh shell
```

This drops you into a bash shell with the cross-compiler and all libraries available. Your project is mounted at `/workspace`. Exit with `exit` or Ctrl+D.

## How It Works

The Docker image is based on Debian trixie (matching the Pi's OS) and contains:

- `gcc-arm-linux-gnueabihf` / `g++-arm-linux-gnueabihf` — the cross-compiler (runs on x86_64, produces ARM binaries)
- `libgrpc++-dev:armhf` and friends — ARM gRPC headers and libraries for linking
- `protobuf-compiler` / `protobuf-compiler-grpc` — protoc and the gRPC plugin (run on x86_64 to generate .pb.cc files)
- A CMake toolchain file that wires it all together

The image is built once and reused. Subsequent builds only compile your code.

## Customising

**Different Pi model?** Edit `toolchain-armhf.cmake`:
- Pi 3/4 (64-bit OS): switch to `crossbuild-essential-arm64` and `aarch64-linux-gnu-g++`
- Pi Zero/1: change flags to `-march=armv6`

**Different gRPC version?** The version comes from the Debian repos. Change `trixie` to `bookworm` (or another release) in the Dockerfile to get a different version.

**Different project structure?** Edit the `PROTO_SRC_DIR` path in your `CMakeLists.txt` and the `PI_WORKSPACE` mount path in `build_docker.sh`.

## Troubleshooting

| Problem | Fix |
|---|---|
| `Exec format error` on gcc | Run `docker builder prune -af` and rebuild — cached layer has wrong binary |
| `libgrpc++.so.1.51: cannot open shared object` on Pi | `sudo apt install libgrpc++1.51t64 libgrpc29t64` on the Pi |
| Proto file not found during build | Make sure `build_docker.sh` mounts the parent directory containing both `proto/` and `cpp/` |
| Docker daemon not running | `sudo service docker start` |
