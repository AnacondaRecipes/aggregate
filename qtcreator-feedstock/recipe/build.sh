#!/bin/bash

# We will have cloned the qbs submodule. Remove it.
rm -rf src/shared/qbs || true

if [[ ! -f "${PREFIX}"/bin/llvm-config ]]; then
  echo "You need to add a host dep of llvmdev for the Clang Code Model"
  exit 1
fi

# Avoid:
# ${PREFIX}/include/sqlite3.h:654:8: error: redefinition of 'struct sqlite3_file'
#  struct sqlite3_file
rm -f "${PREFIX}"/include/sqlite3.h

# Avoid Xcode
if [[ ${HOST} =~ .*darwin.* ]]; then
  mkdir -p xcode
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
      QTC_PREFIX="${PREFIX}"             \
      QBS_INSTALL_PREFIX="${PREFIX}"     \
      LLVM_INSTALL_DIR="${PREFIX}"       \
      QMAKE_CC=${CC}                     \
      QMAKE_CXX=${CXX}                   \
      QMAKE_LINK=${CXX}                  \
      QMAKE_LINK_C=${CC}                 \
      QMAKE_CXXFLAGS="${CXXFLAGS}"       \
      QMAKE_LFLAGS_RELEASE="${LDFLAGS}"
make -j${CPU_COUNT}
make install

if [[ ${HOST} =~ .*darwin.* ]]; then
  mkdir -p "${PREFIX}"/qtcreatorapp/Contents/Resources/
  cp -rf src/app/qtcreator.xcassets/qtcreator.appiconset src/app/qtcreator.xcassets/qtcreator.iconset
  iconutil -c icns -o "${PREFIX}"/qtcreatorapp/Contents/Resources/qtcreator.icns src/app/qtcreator.xcassets/qtcreator.iconset
  iconutil -c icns -o "${PREFIX}"/qtcreatorapp/Contents/Resources/profile.icns src/app/qtcreator.xcassets/profile.iconset
  iconutil -c icns -o "${PREFIX}"/qtcreatorapp/Contents/Resources/prifile.icns src/app/qtcreator.xcassets/prifile.iconset
  cat src/app/Info.plist | sed                                                   \
    -e "s|<string>10.8</string>|<string>${MACOSX_DEPLOYMENT_TARGET}</string>|g"  \
    -e "s|@FULL_VERSION@|${PKG_VERSION}|g"                                       \
    -e "s|@SHORT_VERSION@|${PKG_VERSION}|g"                                      \
    -e "s|<string>Qt Creator</string>|<string>qtcreator</string>|g"              \
    > "${PREFIX}"/qtcreatorapp/Contents/Info.plist
  cp "${RECIPE_DIR}"/osx-post.sh "${PREFIX}"/bin/.qtcreator-post-link.sh
  cp "${RECIPE_DIR}"/osx-pre.sh "${PREFIX}"/bin/.qtcreator-pre-unlink.sh
elif [[ ${HOST} =~ .*linux.* ]]; then
  echo "It would be nice to add a .desktop file here, but it would"
  echo "be even nicer if menuinst handled both that and App bundles."
fi
