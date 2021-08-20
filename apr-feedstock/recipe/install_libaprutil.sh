#!/bin/sh

set -x

cd "${SRC_DIR}/apr-util"

# Get an updated config.sub and config.guess
cp $BUILD_PREFIX/share/libtool/build-aux/config.* ./build

./configure --prefix="${PREFIX}" --host="${HOST}" --with-apr="${PREFIX}" \
            --with-apr-iconv="./apr-iconv" --without-iconv --without-sqlite3
make
make install
