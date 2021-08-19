#!/bin/bash

# Get an updated config.sub and config.guess
cp -r ${BUILD_PREFIX}/share/libtool/build-aux/config.* ./build-aux

./configure --prefix=${PREFIX}        \
            --enable-opie             \
            --enable-digest           \
            --enable-ntlm             \
            --enable-debug            \
            --with-ssl=openssl        \
            --with-openssl=${PREFIX}  \
            --with-zlib=${PREFIX}     \
            --with-metalink           \
            --with-cares              \
            --with-libpsl
make -j${CPU_COUNT} ${VERBOSE_AT}
make install
