#!/bin/bash

export NCCL_LIB_DIR="${PREFIX}/lib"
export NCCL_INCLUDE_DIR="${PREFIX}/include"

export CMAKE_LIBRARY_PATH=$PREFIX/lib:$PREFIX/include:$CMAKE_LIBRARY_PATH
export CMAKE_PREFIX_PATH=$PREFIX
if [ ${CUDA_VERSION} == "8.0" ]; then
    # compile for Kepler, Kepler+Tesla, Maxwell, Volta
    export TORCH_CUDA_ARCH_LIST="3.0;3.5;5.0;5.2+PTX;6.0;6.1"
fi
if [ ${CUDA_VERSION} == "9.0" ]; then
    # compile for Kepler, Kepler+Tesla, Maxwell, Volta
    export TORCH_CUDA_ARCH_LIST="3.0;3.5;5.0;5.2+PTX;6.0;6.1;7.0"
fi
export TORCH_NVCC_FLAGS="-Xfatbin -compress-all"
export PYTORCH_BINARY_BUILD=1
export TH_BINARY_BUILD=1
export PYTORCH_BUILD_VERSION=$PKG_VERSION
export PYTORCH_BUILD_NUMBER=$PKG_BUILDNUM
python setup.py install
