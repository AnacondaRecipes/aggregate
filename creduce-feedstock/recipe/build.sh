#!/bin/bash

${SRC_DIR}/configure     \
  --prefix=${PREFIX}     \
  --with-llvm=${PREFIX}
make -j${CPU_COUNT} ${VERBOSE_AM}
make install
