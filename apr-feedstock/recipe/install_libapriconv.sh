#!/bin/sh

set -x

cd "${SRC_DIR}/apr-iconv"

# Get an updated config.sub and config.guess
cp $BUILD_PREFIX/share/libtool/build-aux/config.* ./build

./configure --prefix="${PREFIX}" --host="${HOST}" --with-apr="${PREFIX}"
make
make install
