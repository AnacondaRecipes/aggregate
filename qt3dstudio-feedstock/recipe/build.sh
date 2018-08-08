#!/bin/bash

# Apply submodule patch
pushd src/Runtime/Qt3DSRuntime
  git am ${RECIPE_DIR}/0001-linux-Need-lrt-for-clock_gettime.patch
popd

# Avoid Xcode
if [[ ${target_platform} == osx-64 ]]; then
  PATH=${PREFIX}/bin/xc-avoidance:${PATH}
fi

mkdir build || true
pushd build

  # This appears in the "About" dialog, but qmake is not good and I cannot
  # find any way to prevent it getting mangled (-DAnaconda -DBuild ...)
  if [[ ! -f Makefile ]]; then
    qmake -r ../qt3dstudio.pro               \
          QMAKE_CC=${CC}                     \
          QMAKE_CXX=${CXX}                   \
          QMAKE_LINK=${CXX}                  \
          QMAKE_LINK_C=${CC}                 \
          QMAKE_CXXFLAGS="${CXXFLAGS}"       \
          QMAKE_LFLAGS_RELEASE="${LDFLAGS}"
  fi
  make -j${CPU_COUNT}
  make install

  if [[ ${HOST} =~ .*darwin.* ]]; then
  #  mkdir -p "${PREFIX}"/qtcreatorapp/Contents/Resources/
  #  cp -rf src/app/qtcreator.xcassets/qtcreator.appiconset src/app/qtcreator.xcassets/qtcreator.iconset
  #  iconutil -c icns -o "${PREFIX}"/qtcreatorapp/Contents/Resources/qtcreator.icns src/app/qtcreator.xcassets/qtcreator.iconset
  #  iconutil -c icns -o "${PREFIX}"/qtcreatorapp/Contents/Resources/profile.icns src/app/qtcreator.xcassets/profile.iconset
  #  iconutil -c icns -o "${PREFIX}"/qtcreatorapp/Contents/Resources/prifile.icns src/app/qtcreator.xcassets/prifile.iconset
  #  cat src/app/Info.plist | sed                                                   \
  #    -e "s|<string>10.8</string>|<string>${MACOSX_DEPLOYMENT_TARGET}</string>|g"  \
  #    -e "s|@FULL_VERSION@|${PKG_VERSION}|g"                                       \
  #    -e "s|@SHORT_VERSION@|${PKG_VERSION}|g"                                      \
  #    -e "s|<string>Qt Creator</string>|<string>qtcreator</string>|g"              \
  #    > "${PREFIX}"/qtcreatorapp/Contents/Info.plist
  #  cp "${RECIPE_DIR}"/osx-post.sh "${PREFIX}"/bin/.qtcreator-post-link.sh
  #  cp "${RECIPE_DIR}"/osx-pre.sh "${PREFIX}"/bin/.qtcreator-pre-unlink.sh
    echo "We may need to fixup:"
    echo "  bin/Qt3DViewer.app/Contents/Info.plist and"
    echo "  bin/Qt3DViewer.app/Contents/Info.plist and"
    echo "  do something with icons and/or post-link/pre-unlink scripts"
  elif [[ ${HOST} =~ .*linux.* ]]; then
    echo "It would be nice to add a .desktop file here, but it would"
    echo "be even nicer if menuinst handled both that and App bundles."
  fi

  # if [[ ${HOST} =~ .*linux.* ]]; then
  #   existing=$(patchelf --print-rpath ${PREFIX}/lib/qtcreator/plugins/qmldesigner/libcomponentsplugin.so)
  #   patchelf --force-rpath --set-rpath $existing:\$ORIGIN/../..:\$ORIGIN/.. ${PREFIX}/lib/qtcreator/plugins/qmldesigner/libcomponentsplugin.so
  # fi

popd

mkdir ${PREFIX}/share/qt3dstudio || true
cp -rf public-demos/* ${PREFIX}/share/qt3dstudio/
cp -rf examples/studio3d/* ${PREFIX}/share/qt3dstudio/
