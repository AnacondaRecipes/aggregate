#!/bin/bash

export NCCL_LIB_DIR="${PREFIX}/lib"
export NCCL_INCLUDE_DIR="${PREFIX}/include"

# Add path to find libcuda.so.
export LDFLAGS="-L/usr/local/cuda/lib64/stubs ${LDFLAGS}"

python setup.py install --single-version-externally-managed --record record.txt
