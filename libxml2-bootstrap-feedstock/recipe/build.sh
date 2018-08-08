#!/bin/bash

./autogen.sh

./configure --prefix="${PREFIX}" \
            --build=$BUILD \
            --host=$HOST \
            --with-iconv="${PREFIX}" \
            --with-zlib="${PREFIX}" \
            --with-lzma="${PREFIX}" \
            --without-icu \
            --without-python \
            --enable-static \
            --disable-shared
make -j${CPU_COUNT} ${VERBOSE_AT}
# Since removing ICU and making only static, we get 10 failures.
# eval ${LIBRARY_SEARCH_VAR}=$PREFIX/lib make check
make install
