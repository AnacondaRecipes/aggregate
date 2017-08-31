#!/bin/bash

. activate "${PREFIX}"
PATH=${PREFIX}/cmake-bin/bin:${PATH}
cd "${SRC_DIR}"

pushd ${PREFIX}/bin
  ln -s clang clang++
popd
