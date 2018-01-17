#!/bin/bash

# Ensure we do not end up linking to a shared libz
rm -f "${PREFIX}"/lib/libz*${SHLIB_EXT}
# .. if this doesn't work we will need to pass LLVM_ENABLE_ZLIB
# or add find_library() to LLVM.

pushd cctools
  if [[ ! -f configure ]]; then
    autoreconf -vfi
    # Yuck, sorry.
    [[ -d include/macho-o ]] || mkdir -p include/macho-o
    cp ld64/src/other/prune_trie.h include/mach-o/prune_trie.h
    cp ld64/src/other/prune_trie.h libprunetrie/prune_trie.h
    cp ld64/src/other/PruneTrie.cpp libprunetrie/PruneTrie.cpp
  fi
popd

if [[ ${MACOSX_DEPLOYMENT_TARGET} == 10.9 ]]; then
  DARWIN_TARGET=x86_64-apple-darwin13.4.0
fi

if [[ -z ${DARWIN_TARGET} ]]; then
  echo "Need a valid DARWIN_TARGET"
  exit 1
fi

declare -a _cctools_config
_cctools_config+=(--prefix=${PREFIX})
_cctools_config+=(--host=${HOST})
_cctools_config+=(--build=${BUILD})
_cctools_config+=(--target=${DARWIN_TARGET})
_cctools_config+=(--disable-static)
_cctools_config+=(--enable-shared)
_cctools_config+=(--with-llvm=${PREFIX})
_cctools_config+=(CC="${CC} -isysroot ${CONDA_BUILD_SYSROOT}")
_cctools_config+=(CXX="${CXX} -isysroot ${CONDA_BUILD_SYSROOT}")

mkdir -p cctools/build
pushd cctools/build
  ${SRC_DIR}/cctools/configure "${_cctools_config[@]}"
  make -j${CPU_COUNT} ${VERBOSE_AT}
  make install
popd
