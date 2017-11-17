#!/bin/bash

# We will have cloned the qbs submodule. Remove it.
rm -rf qbs || true

if [[ ! -f ${PREFIX}/bin/llvm-config ]]; then
  echo "You need to add a host dep of llvmdev for the Clang Code Model"
  exit 1
fi

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
      QTC_PREFIX=${PREFIX}               \
      QBS_INSTALL_PREFIX=${PREFIX}       \
      LLVM_INSTALL_DIR=${PREFIX}         \
      QMAKE_CC=${CC}                     \
      QMAKE_CXX=${CXX}                   \
      QMAKE_LINK=${CXX}                  \
      QMAKE_LINK_C=${CC}                 \
      QMAKE_CXXFLAGS="${CXXFLAGS}"       \
      QMAKE_LFLAGS_RELEASE="${LDFLAGS}"
make -j${CPU_COUNT}
make install
