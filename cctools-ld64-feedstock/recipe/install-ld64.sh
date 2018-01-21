#!/bin/bash

. activate "${BUILD_PREFIX}"
cd "${SRC_DIR}"

pushd cctools_build_final/ld64
  make install
popd
