#!/bin/bash

set -ex

# Setup CMake build location
mkdir build
cd build

# Configure, build, test, and install.
if [ "$(uname)" == "Linux" ];
then
    # Stop Boost from using libquadmath.
    export CXXFLAGS="${CXXFLAGS} -DBOOST_MATH_DISABLE_FLOAT128"
fi

if [[ ${NOMKL} == 1 ]]; then
    BLAS=open
else
    BLAS=mkl
fi

if [[ ${ARCH} == 'ppc64le' ]]; then
    BLAS=open
fi

CUDA_ARCH_BIN="30 35 50 52 60 61"

cmake \
      -DUSE_CUDNN=1                                         \
      -DCUDA_ARCH_NAME="Manual"                             \
      -DCUDA_ARCH_BIN="${CUDA_ARCH_BIN}"                    \
      -DBLAS="${BLAS}"                                      \
      -DCMAKE_INSTALL_PREFIX="${PREFIX}"                    \
      -DNUMPY_INCLUDE_DIR="${SITE_PKGS}/numpy/core/include" \
      -DNUMPY_VERSION=${NPY_VER}                            \
      -DPYTHON_EXECUTABLE="${PREFIX}/bin/python"            \
      -DBUILD_docs="OFF"                                    \
      ..
make -j${CPU_COUNT}

# there's a math error associated with MKL seemingly
# https://github.com/BVLC/caffe/issues/4083#issuecomment-227046096
export OMP_NUM_THREADS=1
export MKL_NUM_THREADS=1
LD_LIBRARY_PATH=/usr/local/nvidia/lib:/usr/local/nvidia/lib64:${LD_LIBRARY_PATH} make -j${CPU_COUNT} runtest

make install

# Python installation is non-standard. So, we're fixing it.
mv "${PREFIX}/python/caffe" "${SP_DIR}/"
for FILENAME in $( cd "${PREFIX}/python/" && find . -name "*.py" | sed 's|./||' );
do
    chmod +x "${PREFIX}/python/${FILENAME}"
    cp "${PREFIX}/python/${FILENAME}" "${PREFIX}/bin/${FILENAME//.py}"
done
rm -rf "${PREFIX}/python/"

if [[ -d "${PREFIX}/lib64" ]]; then
    mv ${PREFIX}/lib64/* ${PREFIX}/lib/
    rmdir ${PREFIX}/lib64
fi
