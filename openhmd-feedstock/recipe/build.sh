#!/usr/bin/env bash

mkdir build || true
pushd build
cmake                                                     \
  -DCMAKE_INSTALL_PREFIX="${PREFIX}"                      \
  -DBUILD_BOTH_STATIC_SHARED_LIB=ON                       \
  -DCMAKE_OSX_SYSROOT=${CONDA_BUILD_SYSROOT}              \
  -DHIDAPI_LIBRARY="${PREFIX}"/lib/libhidapi${SHLIB_EXT}  \
  -DHIDAPI_INCLUDE_DIR="${PREFIX}"/include/hidapi         \
  -DOPENHMD_DRIVER_OCULUS_RIFT=ON                         \
  -DOPENHMD_DRIVER_DEEPOON=ON                             \
  -DOPENHMD_DRIVER_WMR=ON                                 \
  -DOPENHMD_DRIVER_PSVR=ON                                \
  -DOPENHMD_DRIVER_HTC_VIVE=ON                            \
  -DOPENHMD_DRIVER_NOLO=ON                                \
  -DOPENHMD_DRIVER_EXTERNAL=ON                            \
  -DOPENHMD_DRIVER_ANDROID=OFF                            \
  ..
cmake --build . --config Release -- ${VERBOSE_CM}
cmake --build . --config Release --target install -- ${VERBOSE_CM}
popd
