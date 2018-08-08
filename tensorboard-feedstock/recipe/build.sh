#!/bin/bash

set -ex

# remove files in setuptools that have spaces, these cause issues with bazel
rm -rf "${SP_DIR}/setuptools/command/launcher manifest.xml"
rm -rf "${SP_DIR}/setuptools/script (dev).tmpl"

# Adapted from: https://github.com/tensorflow/tensorboard/blob/0.1.5/tensorboard/pip_package/build_pip_package.sh
# build using bazel
mkdir -p ./bazel_output_base
export BAZEL_OPTS="--batch"
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

# Remove bin/tensorboard from as it is include in the
# tensorflow-base/tensorflow-gpu-base packages.
# TODO for next release: keep this file and remove the file in the -base packages.
rm $PREFIX/bin/tensorboard
