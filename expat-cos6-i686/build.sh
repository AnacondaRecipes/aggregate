#!/bin/bash

RPM=$(find ${PWD}/binary -name "*.rpm")
mkdir -p ${PREFIX}/i686-conda_cos6-linux-gnu/sysroot
pushd ${PREFIX}/i686-conda_cos6-linux-gnu/sysroot > /dev/null 2>&1
  "${RECIPE_DIR}"/rpm2cpio "${RPM}" | cpio -idmv
popd > /dev/null 2>&1
