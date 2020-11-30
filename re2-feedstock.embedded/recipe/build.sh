#!/bin/bash
set -e
set -x

export CXXFLAGS="-fPIC ${CXXFLAGS}"
export CFLAGS="-fPIC ${CFLAGS}"

# Build shared libraries
make -j "${CPU_COUNT}" prefix=${PREFIX} install
