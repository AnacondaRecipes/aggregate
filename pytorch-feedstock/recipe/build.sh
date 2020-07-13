#!/bin/bash

set -ex

# clean up an existing cmake build directory
rm -rf build

# uncomment to debug cmake build
#export CMAKE_VERBOSE_MAKEFILE=1

export LDFLAGS="-Wl,-pie -Wl,-headerpad_max_install_names -Wl,-rpath,$PREFIX/lib -L$PREFIX/lib"
export LDFLAGS_LD="-Wl,-pie -Wl,-headerpad_max_install_names -Wl,-rpath,$PREFIX/lib -L$PREFIX/lib"

re='^(.*)-Wl,--as-needed(.*)$'
if [[ ${LDFLAGS} =~ $re ]]; then
  export LDFLAGS="${BASH_REMATCH[1]}${BASH_REMATCH[2]}"
fi
re='^(.*)-Wl,-dead_strip_dylins(.*)$'
if [[ ${LDFLAGS} =~ $re ]]; then
  export LDFLAGS="${BASH_REMATCH[1]}${BASH_REMATCH[2]}"
fi

# Dynamic libraries need to be lazily loaded so that torch
# can be imported on system without a GPU
LDFLAGS="${LDFLAGS//-Wl,-z,now/-Wl,-z,lazy}"

export CMAKE_SYSROOT=$CONDA_BUILD_SYSROOT
export CMAKE_LIBRARY_PATH=$PREFIX/lib:$PREFIX/include:$CMAKE_LIBRARY_PATH
export CMAKE_PREFIX_PATH=$PREFIX
export TH_BINARY_BUILD=1
export PYTORCH_BUILD_VERSION=$PKG_VERSION
export PYTORCH_BUILD_NUMBER=$PKG_BUILDNUM

export USE_NINJA=OFF
export INSTALL_TEST=0

# MacOS build is simple, and will not be for CUDA
if [[ "$OSTYPE" == "darwin"* ]]; then
    export MACOSX_DEPLOYMENT_TARGET=10.9
    python -m pip install . --no-deps -vv
    exit 0
fi

# std=c++11 is required to compile some .cu files
CPPFLAGS="${CPPFLAGS//-std=c++17/-std=c++14}"
CXXFLAGS="${CXXFLAGS//-std=c++17/-std=c++14}"


if [[ ${pytorch_variant} = "gpu" ]]; then
    export USE_CUDA=1
    export TORCH_CUDA_ARCH_LIST="3.5;5.0+PTX"
    if [[ ${cudatoolkit} == 9.0* ]]; then
        export TORCH_CUDA_ARCH_LIST="$TORCH_CUDA_ARCH_LIST;6.0;7.0"
    elif [[ ${cudatoolkit} == 9.2* ]]; then
        export TORCH_CUDA_ARCH_LIST="$TORCH_CUDA_ARCH_LIST;6.0;6.1;7.0"
    elif [[ ${cudatoolkit} == 10.0* ]]; then
        export TORCH_CUDA_ARCH_LIST="$TORCH_CUDA_ARCH_LIST;6.0;6.1;7.0;7.5"
    elif [[ ${cudatoolkit} == 10.1* ]]; then
        export TORCH_CUDA_ARCH_LIST="$TORCH_CUDA_ARCH_LIST;6.0;6.1;7.0;7.5"
    fi
    export TORCH_NVCC_FLAGS="-Xfatbin -compress-all"
    export NCCL_ROOT_DIR=/usr/local/cuda
    export USE_STATIC_NCCL=1
    export CUDA_TOOLKIT_ROOT_DIR=/usr/local/cuda
    export MAGMA_HOME="${PREFIX}"
else
    export BLAS="MKL"
    export USE_CUDA=0
    export USE_MKL_DNN=1
    export CMAKE_TOOLCHAIN_FILE="${RECIPE_DIR}/cross-linux.cmake"
fi

python  -m pip install . --no-deps -vv
