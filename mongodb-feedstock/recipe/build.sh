#!/bin/bash

if [[ ${HOST} =~ .*linux.* ]]; then
    # https://jira.mongodb.org/browse/SERVER-30711
    CXXFLAGS="$CXXFLAGS -Wno-noexcept-type"
    LDFLAGS="$LDFLAGS -Wl,--disable-new-dtags"
elif [[ ${HOST} =~ .*darwin.* ]]; then
    CXXFLAGS="$CXXFLAGS -fvisibility=hidden -Og"
fi

# link to our openssl
# someday, a braveheart will unvendor all deps
CCFLAGS="$CCFLAGS -I$PREFIX/include"
LDFLAGS="$LDFLAGS -L$PREFIX/lib -Wl,-rpath,${PREFIX}/lib"

# time to go for a walk
scons install \
    --prefix=$PREFIX \
    --ssl \
    CC="$CC" \
    CCFLAGS="$CCFLAGS" \
    LINKFLAGS="$LDFLAGS" \
    CXX="$CXX" \
    CXXFLAGS="$CXXFLAGS" \
    OBJCOPY="$OBJCOPY" \
    VERBOSE=on \
    -j${CPU_COUNT} \
    all

# comment these out if you are not patient (skipped on ppc64 due to 1 failure)
if [[ ${target_platform} != linux-ppc64le ]]; then
  $PYTHON buildscripts/resmoke.py --suites=dbtest --jobs=${CPU_COUNT}
  $PYTHON buildscripts/resmoke.py --suites=unittests --jobs=${CPU_COUNT}
fi

# scons install doesn't strip'em
strip $PREFIX/bin/mongo*
