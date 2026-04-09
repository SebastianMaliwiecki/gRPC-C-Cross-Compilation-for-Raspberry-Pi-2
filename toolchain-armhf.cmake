# CMake Toolchain File: ARM Hard-Float (Raspberry Pi 2 Model B)
# Usage: cmake -DCMAKE_TOOLCHAIN_FILE=/opt/toolchain/toolchain-armhf.cmake ..

set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR arm)

# Cross-compiler
set(CMAKE_C_COMPILER   arm-linux-gnueabihf-gcc)
set(CMAKE_CXX_COMPILER arm-linux-gnueabihf-g++)

# Sysroot — armhf libs are in /usr/lib/arm-linux-gnueabihf,
# but headers (protobuf, grpc) are in /usr/include (arch-independent)
set(CMAKE_FIND_ROOT_PATH /usr /usr/arm-linux-gnueabihf /usr/lib/arm-linux-gnueabihf)

# Search paths: headers/libs from target, programs from host
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE BOTH)

# Tell pkg-config to look in the armhf directories
set(ENV{PKG_CONFIG_PATH}        "/usr/lib/arm-linux-gnueabihf/pkgconfig")
set(ENV{PKG_CONFIG_LIBDIR}      "/usr/lib/arm-linux-gnueabihf/pkgconfig")
set(ENV{PKG_CONFIG_SYSROOT_DIR} "/")

# Optimise for Cortex-A7 (Raspberry Pi 2 BCM2836)
set(CMAKE_C_FLAGS_INIT   "-march=armv7-a+fp -mfpu=neon-vfpv4")
set(CMAKE_CXX_FLAGS_INIT "-march=armv7-a+fp -mfpu=neon-vfpv4")