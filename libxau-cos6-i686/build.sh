#!/bin/bash

RPM=$(find ${PWD}/binary -name "*.rpm")
mkdir -p ${PREFIX}/x86_64-conda_cos6-linux-gnu/sysroot
pushd ${PREFIX}/x86_64-conda_cos6-linux-gnu/sysroot > /dev/null 2>&1
if [[ -n "${RPM}" ]]; then
  "${RECIPE_DIR}"/rpm2cpio "${RPM}" | cpio -idmv
  popd > /dev/null 2>&1
else
  mv "${SRC_DIR}"/* .
fi
