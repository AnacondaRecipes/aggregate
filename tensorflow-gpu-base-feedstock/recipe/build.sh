#!/bin/bash

set -vex

mkdir -p ./bazel_output_base
export BAZEL_OPTS="--batch "

# Compile tensorflow from source
export PYTHON_BIN_PATH=${PYTHON}
export PYTHON_LIB_PATH=${SP_DIR}
export USE_DEFAULT_PYTHON_LIB_PATH=1

# MKL settings, use the full version of MKL from the mkl conda package
export TF_NEED_MKL=1
export TF_MKL_ROOT=${PREFIX}

# MKL needs a license.txt file, create an empty one which will be removed later
touch ${PREFIX}/license.txt

# fortran files in the include directory confuse bazel, remove them
rm -f ${PREFIX}/include/*.fi
rm -f ${PREFIX}/include/*.f90

# This is just a placeholder to satisfy the configure prompt.
# It gets overwritten by --config=mkl below.
export CC_OPT_FLAGS="-march=nocona"

# additional settings
# disable jemmloc (needs MADV_HUGEPAGE macro which is not in glib <= 2.12)
export TF_NEED_JEMALLOC=0
export TF_NEED_GCP=1
export TF_NEED_HDFS=1
export TF_NEED_S3=1
export TF_ENABLE_XLA=0
export TF_NEED_GDR=0
export TF_NEED_VERBS=0
export TF_NEED_OPENCL=0
export TF_NEED_OPENCL_SYCL=0
export TF_NEED_MPI=0

# CUDA details
export TF_NEED_CUDA=1
export TF_CUDA_VERSION="${cudatoolkit}"
export TF_CUDNN_VERSION="${cudnn}"
if [ ${cudnn} == "6.0" ]; then
    export TF_CUDNN_VERSION="6"
fi
export TF_CUDA_CLANG=0
# Additional compute capabilities can be added if desired but these increase
# the build time and size of the package. The ones here are the ones supported
# by CUDA 7.5 and used in the devel-gpu tensorflow docker image:
# https://github.com/tensorflow/tensorflow/blob/master/tensorflow/tools/docker/Dockerfile.devel-gpu
# 6.0 and 6.1 should be added with CUDA version 8.0
export TF_CUDA_COMPUTE_CAPABILITIES="3.0,3.5,5.2"
if [ ${cudatoolkit} == "8.0" ]; then
    export TF_CUDA_COMPUTE_CAPABILITIES="3.0,3.5,5.2,6.0,6.1"
fi
export GCC_HOST_COMPILER_PATH="${CC}"
# Use system paths here rather than $PREFIX to allow Bazel to find the correct
# libraries.  RPATH is adjusted post build to link to the DSOs in $PREFIX
export CUDA_TOOLKIT_PATH="/usr/local/cuda"
export CUDNN_INSTALL_PATH="/usr/local/cuda/"

# libcuda.so.1 needs to be symlinked to libcuda.so
# ln -s /usr/local/cuda/lib64/stubs/libcuda.so /usr/local/cuda/lib64/stubs/libcuda.so.1
# on a "real" system the so.1 library is typically in /usr/local/nvidia/lib64
# add the stubs directory to LD_LIBRARY_PATH so libcuda.so.1 can be found
export LD_LIBRARY_PATH="/usr/local/cuda/lib64/stubs/:${LD_LIBRARY_PATH}"

yes "" | ./configure

# build using bazel
# for debugging the following lines may be helpful
#    --logging=6 \
#    --subcommands \
bazel ${BAZEL_OPTS} build \
    --linkopt="-L${PREFIX}/lib" \
    --verbose_failures \
    --config=opt \
    --config=cuda \
    --config=mkl --copt="-DEIGEN_USE_VML" \
    --color=yes \
    --curses=no \
    //tensorflow/tools/pip_package:build_pip_package

# build a whl file
mkdir -p $SRC_DIR/tensorflow_pkg
bazel-bin/tensorflow/tools/pip_package/build_pip_package $SRC_DIR/tensorflow_pkg

# install using pip from the whl file
pip install --no-deps $SRC_DIR/tensorflow_pkg/*.whl

# Run unit tests on the pip installation
# Logic here is based off run_pip_tests.sh in the tensorflow repo
# https://github.com/tensorflow/tensorflow/blob/v1.1.0/tensorflow/tools/ci_build/builds/run_pip_tests.sh
# Note that not all tensorflow tests are run here, only python specific

# tests neeed to be moved into a sub-directory to prevent python from picking
# up the local tensorflow directory
PIP_TEST_PREFIX=bazel_pip
PIP_TEST_ROOT=$(pwd)/${PIP_TEST_PREFIX}
rm -rf $PIP_TEST_ROOT
mkdir -p $PIP_TEST_ROOT
ln -s $(pwd)/tensorflow ${PIP_TEST_ROOT}/tensorflow

# Test which are known to fail on a given platform
KNOWN_FAIL=""

PIP_TEST_FILTER_TAG="-no_pip_gpu,-no_pip"
BAZEL_FLAGS="--define=no_tensorflow_py_deps=true --test_lang_filters=py \
      --build_tests_only -k --test_tag_filters=${PIP_TEST_FILTER_TAG} \
      --test_timeout 9999999"
BAZEL_TEST_TARGETS="${PIP_TEST_PREFIX}/tensorflow/contrib/... \
    ${PIP_TEST_PREFIX}/tensorflow/python/... \
    ${PIP_TEST_PREFIX}/tensorflow/tensorboard/..."
BAZEL_PARALLEL_TEST_FLAGS="--local_test_jobs=1"
# Tests take ~3 hours to run and therefore are skipped in most builds
# These should be run at least once for each new release
#LD_LIBRARY_PATH="/usr/local/nvidia/lib64:/usr/local/cuda/extras/CUPTI/lib64:$LD_LIBRARY_PATH" bazel ${BAZEL_OPTS} test ${BAZEL_FLAGS} \
#    ${BAZEL_PARALLEL_TEST_FLAGS} -- ${BAZEL_TEST_TARGETS} ${KNOWN_FAIL}
