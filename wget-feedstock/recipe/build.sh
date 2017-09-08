#!/bin/bash

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
