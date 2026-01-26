#!/bin/bash
set -ex

# Build the CUDA test program
mkdir -p build
cd build

cmake ${SRC_DIR} \
    -GNinja \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
    -DCMAKE_CUDA_ARCHITECTURES="60;70;75;80;86;89;90"

ninja
ninja install
