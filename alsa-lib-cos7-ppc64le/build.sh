#!/bin/bash

RPM=$(find ${PWD}/binary -name "*.rpm")
mkdir -p ${PREFIX}/ppc64le-conda_cos7-linux-gnu/sysroot
pushd ${PREFIX}/ppc64le-conda_cos7-linux-gnu/sysroot > /dev/null 2>&1
  "${RECIPE_DIR}"/rpm2cpio "${RPM}" | cpio -idmv
popd > /dev/null 2>&1
