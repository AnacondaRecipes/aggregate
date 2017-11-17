#!/bin/bash

set -x -e
. activate "${PREFIX}"

make install INSTALL_ROOT=${SRC_DIR}/qbs_install

pushd ${SRC_DIR}/qbs_install
  mkdir -p ${PREFIX}/{share/doc,bin,include,libexec,lib}
  cp -rf share/doc/qbs ${PREFIX}/share/doc/
  cp -rf share/qbs ${PREFIX}/share/
  cp -rf bin/qbs* ${PREFIX}/bin/
  cp -rf include/qbs ${PREFIX}/include/
  cp -rf libexec/qbs ${PREFIX}/libexec/
  cp -rf lib/*qbs* ${PREFIX}/lib/
popd
