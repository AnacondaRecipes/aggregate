#!/bin/bash

mkdir -p ${PREFIX}/powerpc64le-conda_cos7-linux-gnu/sysroot
pushd ${PREFIX}/powerpc64le-conda_cos7-linux-gnu/sysroot > /dev/null 2>&1
  cp -Rf "${SRC_DIR}"/binary/* .
popd > /dev/null 2>&1
