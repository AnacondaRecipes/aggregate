#!/bin/bash

set -ex

export CMAKE_LIBRARY_PATH=$PREFIX/lib:$PREFIX/include:$CMAKE_LIBRARY_PATH
export CMAKE_PREFIX_PATH=$PREFIX
export TH_BINARY_BUILD=1
export PYTORCH_BUILD_VERSION=$PKG_VERSION
export PYTORCH_BUILD_NUMBER=$PKG_BUILDNUM

if [[ ${cudatoolkit} == 8.0* ]]; then
    export TORCH_CUDA_ARCH_LIST="3.0;3.5;5.0;5.2+PTX;6.0;6.1"
elif [[ ${cudatoolkit} == 9.0* ]]; then
    export TORCH_CUDA_ARCH_LIST="3.0;3.5;5.0;5.2+PTX;6.0;6.1;7.0"
elif [[ ${cudatoolkit} == 9.2* ]]; then
    export TORCH_CUDA_ARCH_LIST="3.0;3.5;5.0;5.2+PTX;6.0;6.1;7.0"
elif [[ ${cudatoolkit} == 10.0* ]]; then
    export TORCH_CUDA_ARCH_LIST="3.0;3.5;5.0;5.2+PTX;6.0;6.1;7.0;7.5"
fi

export TORCH_NVCC_FLAGS="-Xfatbin -compress-all"
export NCCL_ROOT_DIR=/usr/local/cuda
export USE_STATIC_NCCL=1

export MAGMA_HOME="${PREFIX}"
export LIBRT=$(find ${BUILD_PREFIX} -name "librt.so")

python setup.py install
