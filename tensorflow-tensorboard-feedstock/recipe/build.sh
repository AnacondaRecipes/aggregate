#!/bin/bash

set -ex

# Adapted from: https://github.com/tensorflow/tensorboard/blob/0.1.5/tensorboard/pip_package/build_pip_package.sh
# build using bazel
mkdir -p ./bazel_output_base
export BAZEL_OPTS="--batch --output_base=./bazel_output_base"
bazel ${BAZEL_OPTS} build //tensorboard/pip_package:build_pip_package

# collect files for the python package
TMPDIR=tmp_pip_dir
mkdir -p ${TMPDIR}
# The whl file contains all dependencies in an external directory, there is
# no need for this in a conda packages as these requirements are provided by
# other packages.
#cp -R bazel-bin/tensorboard/pip_package/build_pip_package.runfiles/org_tensorflow_tensorboard/external "${TMPDIR}"
cp -R bazel-bin/tensorboard/pip_package/build_pip_package.runfiles/org_tensorflow_tensorboard/tensorboard "${TMPDIR}"

cp tensorboard/pip_package/MANIFEST.in ${TMPDIR}
cp README.md ${TMPDIR}
cp tensorboard/pip_package/setup.py ${TMPDIR}
cd tmp_pip_dir
rm -f MANIFEST

# install the package
python setup.py install --single-version-externally-managed --record record.txt
