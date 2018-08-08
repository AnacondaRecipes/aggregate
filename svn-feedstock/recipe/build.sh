#!/bin/bash

./configure \
    --prefix=$PREFIX \
    --host=$HOST \
    --with-sqlite=$PREFIX \
    --with-zlib=$PREFIX \
    --with-serf=$PREFIX \
    --with-lz4=$PREFIX \
    --with-utf8proc=$PREFIX \
    --with-expat=$PREFIX/include:$PREFIX/lib:expat

make -j${CPU_COUNT} ${VERBOSE_AT}
make install
