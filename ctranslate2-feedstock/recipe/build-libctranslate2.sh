#!/bin/bash
set -ex

CMAKE_ARGS_EXTRA=""

# --- GPU selection ---
if [[ ${gpu_variant:0:5} = "cuda-" ]]; then
    CMAKE_ARGS_EXTRA="${CMAKE_ARGS_EXTRA} -DWITH_CUDA=ON -DWITH_CUDNN=ON -DCUDA_DYNAMIC_LOADING=ON"
    # cuda-compat provided libcuda.so.1
    LDFLAGS="$LDFLAGS -Wl,-rpath-link,${PREFIX}/cuda-compat/"
else
    CMAKE_ARGS_EXTRA="${CMAKE_ARGS_EXTRA} -DWITH_CUDA=OFF -DWITH_CUDNN=OFF"
fi

# --- BLAS selection (mutually exclusive) ---
if [[ ${blas_impl:-} = "mkl" ]]; then
    CMAKE_ARGS_EXTRA="${CMAKE_ARGS_EXTRA} -DWITH_MKL=ON -DWITH_OPENBLAS=OFF -DWITH_ACCELERATE=OFF"
    CMAKE_ARGS_EXTRA="${CMAKE_ARGS_EXTRA} -DOPENMP_RUNTIME=COMP"
elif [[ ${blas_impl:-} = "openblas" ]]; then
    CMAKE_ARGS_EXTRA="${CMAKE_ARGS_EXTRA} -DWITH_MKL=OFF -DWITH_OPENBLAS=ON -DWITH_ACCELERATE=OFF"
    CMAKE_ARGS_EXTRA="${CMAKE_ARGS_EXTRA} -DOPENMP_RUNTIME=COMP"
elif [[ ${blas_impl:-} = "accelerate" ]]; then
    CMAKE_ARGS_EXTRA="${CMAKE_ARGS_EXTRA} -DWITH_MKL=OFF -DWITH_OPENBLAS=OFF -DWITH_ACCELERATE=ON"
    CMAKE_ARGS_EXTRA="${CMAKE_ARGS_EXTRA} -DOPENMP_RUNTIME=COMP"
elif [[ ${blas_impl:-} = "cublas" ]]; then
    # CUDA provides cublas; no separate BLAS needed
    CMAKE_ARGS_EXTRA="${CMAKE_ARGS_EXTRA} -DWITH_MKL=OFF -DWITH_OPENBLAS=OFF -DWITH_ACCELERATE=OFF"
    CMAKE_ARGS_EXTRA="${CMAKE_ARGS_EXTRA} -DOPENMP_RUNTIME=COMP"
else
    CMAKE_ARGS_EXTRA="${CMAKE_ARGS_EXTRA} -DWITH_MKL=OFF -DWITH_OPENBLAS=OFF -DWITH_ACCELERATE=OFF"
    CMAKE_ARGS_EXTRA="${CMAKE_ARGS_EXTRA} -DOPENMP_RUNTIME=COMP"
fi

cmake -S . -B build \
    -G Ninja \
    ${CMAKE_ARGS} \
    -DCMAKE_INSTALL_PREFIX=${PREFIX} \
    -DCMAKE_PREFIX_PATH=${PREFIX} \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_SHARED_LIBS=ON \
    -DBUILD_CLI=OFF \
    -DBUILD_TESTS=OFF \
    -DENABLE_CPU_DISPATCH=ON \
    -DWITH_DNNL=OFF \
    -DWITH_RUY=OFF \
    ${CMAKE_ARGS_EXTRA}

cmake --build build --config Release --verbose
cmake --install build
