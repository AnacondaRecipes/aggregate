#!/bin/bash

RPM=$(find ${PWD}/binary -name "*.rpm")
mkdir -p ${PREFIX}/powerpc64le-conda_cos7-linux-gnu/sysroot
pushd ${PREFIX}/powerpc64le-conda_cos7-linux-gnu/sysroot > /dev/null 2>&1
  "${RECIPE_DIR}"/rpm2cpio "${RPM}" | cpio -idmv
popd > /dev/null 2>&1

pushd "${PREFIX}"
ln -s powerpc64le-conda_cos7-linux-gnu powerpc64le-conda-linux-gnu
popd


