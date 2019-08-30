#!/bin/bash

declare -a CMAKE_PLATFORM_FLAGS
if [[ ${HOST} =~ .*darwin.* ]]; then
  CMAKE_PLATFORM_FLAGS+=(-DCMAKE_OSX_SYSROOT="${CONDA_BUILD_SYSROOT}")
  # We have a problem with over-stripping of dylibs in the test programs:
  # nm ${PREFIX}/lib/libdf.dylib | grep error_top
  #   000000000006197c S _error_top
  # Then, despite this being linked to explicitly when creating the test programs:
  # ./hdf4_test_tst_chunk_hdf4
  # dyld: Symbol not found: _error_top
  #   Referenced from: ${PREFIX}/lib/libmfhdf.0.dylib
  #   Expected in: flat namespace
  #  in ${PREFIX}/lib/libmfhdf.0.dylib
  # Abort trap: 56
  # Now clearly libmfhdf should autoload libdf but it does not and that is not going to change:
  # https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=556439
  # .. so we must remove our unused stripping instead :-(
  # (it may be possible to arrange this symbol to be in the 'D'ata section instead of 'S'
  #  (symbol in a section other than those above according to man nm), instead though
  #  or to fix ld64 so that it checks for symbols being used in this section).
  export LDFLAGS=$(echo "${LDFLAGS}" | sed "s/-Wl,-dead_strip_dylibs//g")
else
  CMAKE_PLATFORM_FLAGS+=(-DCMAKE_TOOLCHAIN_FILE="${RECIPE_DIR}/cross-linux.cmake")
fi

# Build shared lib
cmake . \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DCMAKE_INSTALL_LIBDIR=lib \
    -DBUILD_SHARED_LIBS=ON \
    -DBUILD_TESTING=ON \
    ${CMAKE_PLATFORM_FLAGS[@]}
make -j

test/cctest/cctest --list | tr -d '<' | xargs test/cctest/cctest

make install

# Build static lib
cmake . \
  -DCMAKE_INSTALL_PREFIX=$PREFIX \
  -DCMAKE_INSTALL_LIBDIR=lib \
  -DBUILD_SHARED_LIBS=OFF \
  -DBUILD_TESTING=OFF \
  ${CMAKE_PLATFORM_FLAGS[@]}
make -j
make install
