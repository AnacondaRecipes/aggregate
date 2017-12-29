#!/bin/bash
# Fire all the activation scripts
source activate "${BUILD_PREFIX}"

set -ex

cp make/config.mk config.mk

for file in Makefile dmlc-core/Makefile nnvm/Makefile
do
  # We wish to use the ar from our packages
  sed -i.bak -e 's/ar cr/$(AR) crv/' $file
done

export OPENMP_OPT=1
export JEMALLOC_OPT=1

if [[ ${HOST} =~ .*darwin.* ]]; then
  cp make/osx.mk config.mk
  export OPENMP_OPT=0
  # On macOS, jemalloc defaults to JEMALLOC_PREFIX: 'je_'
  # for which mxnet source code isn't ready yet.
  export JEMALLOC_OPT=0
  export LDFLAGS="${LDFLAGS_CC}"
fi

export BLAS_OPTS="USE_BLAS=$blas_impl"
if [[ "${blas_impl}" == "mkl" ]]; then
  BLAS_OPTS="${BLAS_OPTS} USE_STATIC_MKL=NONE USE_INTEL_PATH=NONE USE_MKL2017=1"
  export MKLROOT="${PREFIX}"
fi

make -j${CPU_COUNT} \
  AR="$AR" \
  CC="$CC" \
  CXX="$CXX" \
  USE_CUDA=0 \
  USE_CUDNN=0 \
  USE_OPENCV=1 \
  USE_LAPACK=1 \
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
cp -rv dmlc-core/include/* $PREFIX/include/
cp -rv nnvm/include/* $PREFIX/include/

# https://github.com/apache/incubator-mxnet/tree/1.0.0/cpp-package
cp -rv cpp-package/include/mxnet-cpp $PREFIX/include/mxnet-cpp

cp -rv lib/* $PREFIX/lib/
