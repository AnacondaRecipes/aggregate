#!/bin/bash

set -o errexit -o pipefail

mkdir -p "${PREFIX}"/s390x-conda-linux-gnu/sysroot
if [[ -d usr/lib ]]; then
  if [[ ! -d lib ]]; then
    ln -s usr/lib lib
  fi
fi
if [[ -d usr/lib64 ]]; then
  if [[ ! -d lib64 ]]; then
    ln -s usr/lib64 lib64
  fi
fi
pushd "${PREFIX}"/s390x-conda-linux-gnu/sysroot > /dev/null 2>&1
cp -Rf "${SRC_DIR}"/binary/* .
