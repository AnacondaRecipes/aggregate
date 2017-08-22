#!/bin/bash

./configure --prefix=${PREFIX}  \
            --host=${HOST}      \
            CFLAGS="${CFLAGS} -I${PREFIX}/include" \
            LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
make -j ${CPU_COUNT}
make install
