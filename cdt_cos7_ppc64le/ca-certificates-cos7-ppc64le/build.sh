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

pushd ${PREFIX}/powerpc64le-conda_cos7-linux-gnu/sysroot/etc/pki/java
  rm -f cacerts
  mkdir -p ${PREFIX}/powerpc64le-conda_cos7-linux-gnu/sysroot/etc/pki/ca-trust/extracted/java/cacerts
  ln -s ${PREFIX}/powerpc64le-conda_cos7-linux-gnu/sysroot/etc/pki/ca-trust/extracted/java/cacerts cacerts
popd

pushd ${PREFIX}/powerpc64le-conda_cos7-linux-gnu/sysroot/etc/pki/tls
  rm -f cert.pem
  echo "PLACEHOLDER"> ${PREFIX}/powerpc64le-conda_cos7-linux-gnu/sysroot/etc/pki/ca-trust/extracted/pem/tls-ca-bundle.pem
  ln -s ${PREFIX}/powerpc64le-conda_cos7-linux-gnu/sysroot/etc/pki/ca-trust/extracted/pem/tls-ca-bundle.pem cert.pem
popd

pushd ${PREFIX}/powerpc64le-conda_cos7-linux-gnu/sysroot/etc/pki/tls/certs
  rm -f ca-bundle.crt
  ln -s ${PREFIX}/powerpc64le-conda_cos7-linux-gnu/sysroot/etc/pki/ca-trust/extracted/pem/tls-ca-bundle.pem ca-bundle.crt
popd

pushd ${PREFIX}/powerpc64le-conda_cos7-linux-gnu/sysroot/etc/pki/tls/certs
  rm ca-bundle.trust.crt
  echo "PLACEHOLDER"> ${PREFIX}/powerpc64le-conda_cos7-linux-gnu/sysroot/etc/pki/ca-trust/extracted/openssl/ca-bundle.trust.crt
  ln -s ${PREFIX}/powerpc64le-conda_cos7-linux-gnu/sysroot/etc/pki/ca-trust/extracted/openssl/ca-bundle.trust.crt ca-bundle.trust.crt
popd
