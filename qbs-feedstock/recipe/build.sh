#!/bin/bash

# Avoid Xcode
if [[ ${HOST} =~ .*darwin.* ]]; then
  mkdir xcode
  pushd xcode
    cp "${RECIPE_DIR}"/xcrun .
    cp "${RECIPE_DIR}"/xcodebuild .
    PATH=${PWD}:${PATH}
  popd
fi

qmake -r qbs.pro                         \
      QBS_INSTALL_PREFIX=${PREFIX}       \
      QMAKE_CC=${CC}                     \
      QMAKE_CXX=${CXX}                   \
      QMAKE_LINK=${CXX}                  \
      QMAKE_LINK_C=${CC}                 \
      QMAKE_CXXFLAGS="${CXXFLAGS}"       \
      QMAKE_LFLAGS_RELEASE="${LDFLAGS}"
make -j${CPU_COUNT}
make install
