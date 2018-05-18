#!/bin/bash

set -ex

mkdir -p ./bazel_output_base
export BAZEL_OPTS="--batch "

# set up bazel config file for conda provided clang toolchain
if [[ ${HOST} =~ .*darwin.* ]]; then
    cp -r ${RECIPE_DIR}/custom_clang_toolchain .
    cd custom_clang_toolchain
    sed -e "s:\${CLANG}:${CLANG}:" \
        -e "s:\${INSTALL_NAME_TOOL}:${INSTALL_NAME_TOOL}:" \
        -e "s:\${CONDA_BUILD_SYSROOT}:${CONDA_BUILD_SYSROOT}:" \
        cc_wrapper.sh.template > cc_wrapper.sh
    chmod +x cc_wrapper.sh
    sed -e "s:\${PREFIX}:${BUILD_PREFIX}:" \
        -e "s:\${LD}:${LD}:" \
        -e "s:\${NM}:${NM}:" \
        -e "s:\${STRIP}:${STRIP}:" \
        -e "s:\${LIBTOOL}:${LIBTOOL}:" \
        -e "s:\${CONDA_BUILD_SYSROOT}:${CONDA_BUILD_SYSROOT}:" \
        CROSSTOOL.template > CROSSTOOL
    cd ..
fi

# Python settings
export PYTHON_BIN_PATH=${PYTHON}
export PYTHON_LIB_PATH=${SP_DIR}
export USE_DEFAULT_PYTHON_LIB_PATH=1

if [[ ${HOST} =~ .*linux.* ]]; then
    # MKL settings, use the full version of MKL from the mkl conda package
    export TF_NEED_MKL=1
    export TF_MKL_ROOT=${PREFIX}

    # MKL needs a license.txt file, create an empty one which will be removed later
    touch ${PREFIX}/license.txt

    # fortran files in the include directory confuse bazel, remove them
    rm -f ${PREFIX}/include/*.fi
    rm -f ${PREFIX}/include/*.f90
fi

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
export TF_NEED_CUDA=0
export TF_NEED_MPI=0
yes "" | ./configure

# build using bazel
# add the following when debugging
#    --logging=6 \
#    --subcommands \
if [[ ${HOST} =~ .*darwin.* ]]; then
    export  BAZEL_USE_CPP_ONLY_TOOLCHAIN=1
    bazel ${BAZEL_OPTS} build \
        --crosstool_top=//custom_clang_toolchain:toolchain \
        --verbose_failures \
        --config=opt \
        //tensorflow/tools/pip_package:build_pip_package
else
    bazel ${BAZEL_OPTS} build \
        --verbose_failures \
        --config=mkl \
        //tensorflow/tools/pip_package:build_pip_package
fi

# build a whl file
mkdir -p $SRC_DIR/tensorflow_pkg
bazel-bin/tensorflow/tools/pip_package/build_pip_package $SRC_DIR/tensorflow_pkg

# install the whl using pip
pip install --no-deps $SRC_DIR/tensorflow_pkg/*.whl

# Remove extra cruft from MKL.  These file are already available in the mkl
# conda package and are not needed in the the tensorflow package.
rm -rf ${SP_DIR}/_solib_k8
rm -rf ${SP_DIR}/external/mkl
rm -f ${PREFIX}/license.txt

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

# Test which are known to fail and do not effect the package
KNOWN_FAIL="
    -${PIP_TEST_PREFIX}/tensorflow/contrib/factorization:gmm_ops_test
    -${PIP_TEST_PREFIX}/tensorflow/contrib/lite/python:lite_test
    -${PIP_TEST_PREFIX}/tensorflow/python/keras:convolutional_recurrent_test
    -${PIP_TEST_PREFIX}/tensorflow/python/kernel_tests:cholesky_op_test
    -${PIP_TEST_PREFIX}/tensorflow/python/kernel_tests:conv_ops_test
    -${PIP_TEST_PREFIX}/tensorflow/python/kernel_tests:matrix_logarithm_op_test
    -${PIP_TEST_PREFIX}/tensorflow/python/kernel_tests:self_adjoint_eig_op_test
    -${PIP_TEST_PREFIX}/tensorflow/python:timeline_test"
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
# to reduce build time on worker skip tests, run when testing
#bazel ${BAZEL_OPTS} test ${BAZEL_FLAGS} \
#    ${BAZEL_PARALLEL_TEST_FLAGS} -- ${BAZEL_TEST_TARGETS} ${KNOWN_FAIL}
