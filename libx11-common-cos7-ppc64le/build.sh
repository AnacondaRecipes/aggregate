#!/bin/bash

set -e

mkdir -p ${PREFIX}/powerpc64le-conda_cos7-linux-gnu/sysroot
RPMS=$(find "${SRC_DIR}"/binary -name "*.rpm" -printf "." | wc -c)
RPM=$(find "${SRC_DIR}"/binary -name "*.rpm")
TOTAL=$(find "${SRC_DIR}"/binary -type f -printf "." | wc -c)
  pushd ${PREFIX}/powerpc64le-conda_cos7-linux-gnu/sysroot > /dev/null 2>&1
if [[ ${RPMS} == 1 ]] && [[ ${TOTALS} == 1 ]] && [[ -f ${RPM} ]]; then
  "${RECIPE_DIR}"/rpm2cpio "${RPM}" | cpio -idmv
else
  cp -Rf "${SRC_DIR}"/binary/* .
fi
popd > /dev/null 2>&1
