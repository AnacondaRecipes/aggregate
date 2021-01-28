#!/bin/bash

mkdir build
cd build

cmake -G "Unix Makefiles" \
  -DCMAKE_BUILD_TYPE="Release" \
  -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
  -DCMAKE_POSITION_INDEPENDENT_CODE=1 \
  -DBUILD_SHARED_LIBS=1 \
  "${SRC_DIR}"

cmake --build .
cmake --build . --target install

