#!/usr/bin/env bash

./bootstrap
mkdir build || true
pushd build
../configure            \
  --prefix="${PREFIX}"
make -j${CPU_COUNT} ${VERBOSE_AT}
make install
popd
