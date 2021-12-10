#!/bin/bash

# Get an updated config.sub and config.guess
cp $BUILD_PREFIX/share/libtool/build-aux/config.* .

if [[ $(uname) == MSYS* ]]; then
  if [[ ${ARCH} == 32 ]]; then
    HOST_BUILD="--host=i686-w64-mingw32 --build=i686-w64-mingw32"
  else
    HOST_BUILD="--host=x86_64-w64-mingw32 --build=x86_64-w64-mingw32"
  fi
  PREFIX=${PREFIX}/Library/mingw-w64
fi

EXTRA_CONF="--enable-pic"

if [[ ${target_platform} == osx-* ]]; then
  EXTRA_CONF="${EXTRA_CONF} --disable-avx512 --disable-runtime-cpu-detect"
else
  EXTRA_CONF="${EXTRA_CONF} --enable-runtime-cpu-detect"
fi

if [[ $(uname) == Linux ]]; then
  LDFLAGS="$LDFLAGS -pthread"
fi

./configure --prefix=${PREFIX}           \
            ${HOST_BUILD}                \
            --as=yasm                    \
            --enable-shared              \
            --disable-install-docs       \
            --disable-install-srcs       \
            --enable-vp8                 \
            --enable-postproc            \
            --enable-vp9                 \
            --enable-vp9-highbitdepth    \
            ${EXTRA_CONF}                \
            --enable-experimental || exit 1

make -j${CPU_COUNT} ${VERBOSE_AT}
make install
