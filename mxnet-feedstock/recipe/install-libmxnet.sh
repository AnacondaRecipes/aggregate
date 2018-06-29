#!/bin/bash
# Fire all the activation scripts
source activate "${BUILD_PREFIX}"

set -ex

cp make/config.mk config.mk

export OPENMP_OPT=1
export JEMALLOC_OPT=1

if [[ ${HOST} =~ .*darwin.* ]]; then
  cp make/osx.mk config.mk
  export OPENMP_OPT=0
  # On macOS, jemalloc defaults to JEMALLOC_PREFIX: 'je_'
  # for which mxnet source code isn't ready yet.
  export JEMALLOC_OPT=0
fi

export BLAS_OPTS="USE_BLAS=$blas_impl"
if [[ "${blas_impl}" == "mkl" ]]; then
  BLAS_OPTS="${BLAS_OPTS} USE_MKLDNN=1 USE_INTEL_PATH=NONE USE_STATIC_MKL=NONE MKLDNN_ROOT=${PREFIX}"
  export MKLDNNROOT="$PREFIX"
fi

make -j${CPU_COUNT} \
  AR="$AR" \
  CC="$CC" \
  CXX="$CXX" \
  USE_CUDA=0 \
  USE_CUDNN=0 \
  USE_OPENCV=1 \
  ${BLAS_OPTS} \
  USE_PROFILER=1 \
  USE_CPP_PACKAGE=1 \
  USE_SIGNAL_HANDLER=1 \
  ADD_CFLAGS="$CFLAGS" \
  ADD_LDFLAGS="$LDFLAGS" \
  USE_OPENMP="$OPENMP_OPT" \
  USE_JEMALLOC="$JEMALLOC_OPT" \
  VERBOSE=${VERBOSE_AT}

mkdir -p $PREFIX/bin
cp bin/* $PREFIX/bin/

mkdir -p $PREFIX/include
cp -rv include/* $PREFIX/include/
cp -rv 3rdparty/dmlc-core/include/* $PREFIX/include/
cp -rv 3rdparty/nnvm/include/* $PREFIX/include/

# https://github.com/apache/incubator-mxnet/tree/1.0.0/cpp-package
cp -rv cpp-package/include/mxnet-cpp $PREFIX/include/mxnet-cpp

cp -rv lib/* $PREFIX/lib/
