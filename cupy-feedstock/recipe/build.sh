#!/bin/bash

export NCCL_LIB_DIR="${PREFIX}/lib"
export NCCL_INCLUDE_DIR="${PREFIX}/include"

# To find libcuda.so.  Not sure why this is required...
export LDFLAGS=-L/usr/lib64

pip install .
