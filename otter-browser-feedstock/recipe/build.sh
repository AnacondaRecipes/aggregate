#!/bin/bash

declare -a CMAKE_EXTRA_ARGS

# Avoid Xcode
if [[ ${target_platform} == osx-64 ]]; then
  PATH=${PREFIX}/bin/xc-avoidance:${PATH}
  CMAKE_EXTRA_ARGS+=(-DCMAKE_OSX_SYSROOT=${CONDA_BUILD_SYSROOT})
fi

mkdir build || true

pushd build
  cmake -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
        "${CMAKE_EXTRA_ARGS[@]}" \
        ..
  make -j${CPU_COUNT} ${VERBOSE_CM}
  make install ${VERBOSE_CM}
popd
