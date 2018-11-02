#!/bin/bash

if [[ ${HOST} =~ .*linux.* ]]; then
    # https://jira.mongodb.org/browse/SERVER-30711
    CXXFLAGS="$CXXFLAGS -Wno-noexcept-type"
    LDFLAGS="$LDFLAGS -Wl,--disable-new-dtags"
elif [[ ${HOST} =~ .*darwin.* ]]; then
    CXXFLAGS="$CXXFLAGS -fvisibility=hidden -Og"
fi

declare -a _scons_xtra_flags
declare -a _tests_xtra_args
declare -a _build_targets
if [[ $target_platform == linux-32 ]]; then
  _scons_xtra_flags+=(--wiredtiger=off)
  _scons_xtra_flags+=(--disable-warnings-as-errors)
  _scons_xtra_flags+=(--js-engine=none)
  _scons_xtra_flags+=(--allocator=system)
  _scons_xtra_flags+=(--noshell)
  _tests_xtra_args+=(--storageEngine=mmapv1)
  _build_targets+=(core)
  _build_targets+=(tools)
else
  _build_targets+=(all)
fi

# SERVER-37135 Broken tls13 support, removing to fix
# build. Fixed upstream, remove this in next release
sed -i.bak '/counts.tls13/d' src/mongo/util/net/ssl_manager_openssl.cpp

# link to our openssl
# someday, a braveheart will unvendor all deps
CCFLAGS="$CCFLAGS -I$PREFIX/include"
LDFLAGS="$LDFLAGS -L$PREFIX/lib -Wl,-rpath,${PREFIX}/lib"

# time to go for a walk
scons install \
    --prefix=$PREFIX \
    --ssl \
    --release \
    --ssl-provider=openssl \
    "${_scons_xtra_flags[@]}" \
    CC="$CC" \
    CCFLAGS="$CCFLAGS" \
    LINKFLAGS="$LDFLAGS" \
    CXX="$CXX" \
    CXXFLAGS="$CXXFLAGS" \
    OBJCOPY="$OBJCOPY" \
    VERBOSE=on \
    -j${CPU_COUNT} \
    "${_build_targets[@]}"

# comment these out if you are not patient (skipped on ppc64 due to 1 failure)
if [[ ${target_platform} != linux-ppc64le && ${target_platform} != linux-32 ]]; then
  $PYTHON buildscripts/resmoke.py --suites=dbtest --jobs=${CPU_COUNT} "${_tests_xtra_args[@]}"
  $PYTHON buildscripts/resmoke.py --suites=unittests --jobs=${CPU_COUNT} "${_tests_xtra_args[@]}"
fi

# scons install doesn't strip'em
strip $PREFIX/bin/mongo*
