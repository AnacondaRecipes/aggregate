#!/bin/sh

sed -i.bak 's/c89/c99/g' SConstruct

if [[ "${target_platform}" == osx-* ]]; then
  export CPPFLAGS="$CPPFLAGS -isysroot $CONDA_BUILD_SYSROOT"
  export CFLAGS="$CPPFLAGS -isysroot $CONDA_BUILD_SYSROOT"
  export LDFLAGS="$LDFLAGS -isysroot $CONDA_BUILD_SYSROOT"
fi

scons APR="$PREFIX" APU="$PREFIX" OPENSSL="$PREFIX" ZLIB="$PREFIX" \
    PREFIX="$PREFIX" CC="$CC" CPPFLAGS="$CPPFLAGS" LINKFLAGS="$LDFLAGS" CFLAGS="$CFLAGS"

scons install
