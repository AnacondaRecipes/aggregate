#!/bin/bash

set -e

mkdir -p ${PREFIX}/powerpc64le-conda_cos7-linux-gnu/sysroot
RPMS=$(find "${SRC_DIR}"/binary -name "*.rpm" -exec printf "." \; | wc -c | tr -d " ")
THE_RPM=$(find "${SRC_DIR}"/binary -name "*.rpm")
TOTAL=$(find "${SRC_DIR}"/binary -type f -exec printf "." \; | wc -c | tr -d " ")
pushd ${PREFIX}/powerpc64le-conda_cos7-linux-gnu/sysroot > /dev/null 2>&1
  if [[ ${RPMS} == 1 ]] && [[ ${TOTAL} == 1 ]] && [[ -f ${THE_RPM} ]]; then
    "${RECIPE_DIR}"/rpm2cpio "${THE_RPM}" | cpio -idmv
  else
    cp -Rf "${SRC_DIR}"/binary/* .
  fi
popd > /dev/null 2>&1

pushd ${PREFIX}/powerpc64le-conda_cos7-linux-gnu/sysroot/usr/lib/jvm/java-1.7.0-openjdk-1.7.0.171-2.6.13.2.el7.ppc64le/jre-abrt
  rm -rf lib
  ln -s ${PREFIX}/powerpc64le-conda_cos7-linux-gnu/sysroot/usr/lib/jvm/java-1.7.0-openjdk-1.7.0.171-2.6.13.2.el7.ppc64le/jre/lib lib
popd

pushd ${PREFIX}/powerpc64le-conda_cos7-linux-gnu/sysroot/usr/lib/jvm/java-1.7.0-openjdk-1.7.0.171-2.6.13.2.el7.ppc64le/jre/lib/security
  mkdir -p ../../../../../../../etc/pki/java/cacerts
popd
