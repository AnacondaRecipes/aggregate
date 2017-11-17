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

# This appears in the "About" dialog, but qmake is not good and I cannot
# find any way to prevent it getting mangled (-DAnaconda -DBuild ...)
echo DEFINES += IDE_VERSION_DESCRIPTION=\\\"Anaconda Build ${PKG_BUILDNUM}\\\" >> qtcreator.pro
qmake -r qtcreator.pro                   \
      QTC_PREFIX=/                       \
      QBS_INSTALL_PREFIX=/               \
      QMAKE_CC=${CC}                     \
      QMAKE_CXX=${CXX}                   \
      QMAKE_LINK=${CXX}                  \
      QMAKE_LINK_C=${CC}                 \
      QMAKE_CXXFLAGS="${CXXFLAGS}"       \
      QMAKE_LFLAGS_RELEASE="${LDFLAGS}"
make -j${CPU_COUNT}
make install INSTALL_ROOT=${PREFIX}
