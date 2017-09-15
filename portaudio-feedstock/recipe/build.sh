#!/bin/bash

./configure --with-pic --prefix=${PREFIX}
make
make install

if [[ ${HOST} =~ .*darwin.* ]]; then
  cp include/pa_mac_core.h ${PREFIX}/include
fi
