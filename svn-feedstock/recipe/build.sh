#!/bin/bash

./configure \
    --prefix=$PREFIX \
    --with-sqlite=$PREFIX \
    --with-zlib=$PREFIX \
    --with-serf=$PREFIX

make -j${CPU_COUNT} ${VERBOSE_AT}
make install
