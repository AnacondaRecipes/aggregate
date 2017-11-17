#!/bin/bash

set -x -e
. activate "${PREFIX}"

make install INSTALL_ROOT=${SRC_DIR}/qbs_install

pushd ${SRC_DIR}/qbs_install
  # Docs seem not to be getting built?
  # mkdir -p ${PREFIX}/{share/doc,bin,include,libexec,lib}
  # cp -rf share/doc/qbs ${PREFIX}/share/doc/
  mkdir -p ${PREFIX}/{bin,include,libexec,lib}
  pushd share/qtcreator/qbs/share

  cp -rf share/qbs ${PREFIX}/share/
  cp -rf bin/qbs* ${PREFIX}/bin/
  cp -rf include/qbs ${PREFIX}/include/
  cp -rf libexec/qbs ${PREFIX}/libexec/
  cp -rf lib/*qbs* ${PREFIX}/lib/
popd
