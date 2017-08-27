#!/bin/bash

./configure --prefix=${PREFIX}  \
            --host=${HOST}      \
            CFLAGS="${CFLAGS} -I${PREFIX}/include" \
            LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
make -j ${CPU_COUNT} ${VERBOSE_AT}
make install
# This symlink conflicts with a file in readline
rm -f ${PREFIX}/share/man/man3/history.3
