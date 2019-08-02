#!/usr/bin/env bash

set -x

cmake -G"$CMAKE_GENERATOR" \
  -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
  -DCMAKE_BUILD_TYPE=Release \
  -DMKLROOT="${PREFIX}" \
  ${SRC_DIR}

cmake --build . --config Release -j${CPU_COUNT}

ctest

cmake --build . --target install
