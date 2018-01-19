#!/bin/bash

set -ex

mkdir -p ./bazel_output_base
export BAZEL_OPTS="--batch --output_base=./bazel_output_base"

# Compile tensorflow from source
export PYTHON_BIN_PATH=${PYTHON}
export PYTHON_LIB_PATH=${SP_DIR}
if [ `uname -m`  == ppc64le ]; then
    export CC_OPT_FLAGS=" -mtune=powerpc64le"
else
    export CC_OPT_FLAGS="-march=nocona"
fi
export TF_NEED_MKL=1
export TF_DOWNLOAD_MKL=1

# disable jemmloc (needs MADV_HUGEPAGE macro which is not in glib <= 2.12)
export TF_NEED_JEMALLOC=0
export TF_NEED_GCP=1
export TF_NEED_HDFS=1
export TF_NEED_S3=1
export TF_ENABLE_XLA=0
export TF_NEED_GDR=0
export TF_NEED_VERBS=0
export TF_NEED_OPENCL=0
export TF_NEED_CUDA=0
export TF_NEED_MPI=0
./configure

# build using bazel
bazel ${BAZEL_OPTS} build --config=opt //tensorflow/tools/pip_package:build_pip_package

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
# remove the tensorboard tests as they cannot be built
rm -rf ${PIP_TEST_ROOT}/tensorflow/contrib/tensorboard

# Test which are known to fail and have been confirm to not effect the package
#   debug:session_debug_grpc_test requires grpcio to be installed
#   debug:dist_session_debug_grpc_test requires specific build env setup
KNOWN_FAIL="
   -${PIP_TEST_PREFIX}/tensorflow/python/debug:dist_session_debug_grpc_test
   -${PIP_TEST_PREFIX}/tensorflow/python/debug:session_debug_grpc_test"
if [ `uname -m`  == ppc64le ]; then
    # Python on ppc64le is built without the curses/readline module
    # Some tests are known fails on ppc64le but do not effect normal uses cases
    KNOWN_FAIL="
   -${PIP_TEST_PREFIX}/tensorflow/python/debug:curses_ui_test
   -${PIP_TEST_PREFIX}/tensorflow/python/debug:readline_ui_test
   -${PIP_TEST_PREFIX}/tensorflow/python/kernel_tests:denormal_test
   -${PIP_TEST_PREFIX}/tensorflow/python/kernel_tests:matrix_triangular_solve_op_test
   -${PIP_TEST_PREFIX}/tensorflow/python/kernel_tests:sparse_matmul_op_test
   -${PIP_TEST_PREFIX}/tensorflow/python/kernel_tests:sparse_tensor_dense_matmul_op_test
   -${PIP_TEST_PREFIX}/tensorflow/python/kernel_tests:svd_op_test
   -${PIP_TEST_PREFIX}/tensorflow/python/kernel_tests:tensordot_op_test
   -${PIP_TEST_PREFIX}/tensorflow/python:nn_test
   -${PIP_TEST_PREFIX}/tensorflow/python/kernel_tests:summary_image_op_test"
fi

PIP_TEST_FILTER_TAG="-no_pip"
BAZEL_FLAGS="--define=no_tensorflow_py_deps=true --test_lang_filters=py \
      --build_tests_only -k --test_tag_filters=${PIP_TEST_FILTER_TAG} \
      --test_timeout 9999999"
BAZEL_TEST_TARGETS="${PIP_TEST_PREFIX}/tensorflow/contrib/... \
    ${PIP_TEST_PREFIX}/tensorflow/python/..."
BAZEL_PARALLEL_TEST_FLAGS="--local_test_jobs=${CPU_COUNT}"
if [ "${CPU_COUNT}" -gt 20 ]; then
    BAZEL_PARALLEL_TEST_FLAGS="--local_test_jobs=20"
fi
bazel ${BAZEL_OPTS} test ${BAZEL_FLAGS} \
    ${BAZEL_PARALLEL_TEST_FLAGS} -- ${BAZEL_TEST_TARGETS} ${KNOWN_FAIL}
