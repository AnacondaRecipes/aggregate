#!/bin/bash

export CFLAGS="${CFLAGS} -D_FILE_OFFSET_BITS=64"
# -DUSE_UTF16 means use ICU on macOS. Otherwise libiconv is used.
# The build fails with you use modern ICU with namespaces; easily fixed, but ICU, yuck.
#if [[ -n ${icu} ]]; then
#  export CXXFLAGS="${CXXFLAGS} -D_FILE_OFFSET_BITS=64 -DUSE_UTF16"
#else
  export CXXFLAGS="${CXXFLAGS} -D_FILE_OFFSET_BITS=64"
#fi
export FATBINFLAGS="-arch x86_64 -mmacosx-version-min=10.10"
make -f Makefile.mac
cp gdisk sgdisk cgdisk fixparts ${PREFIX}/bin/
