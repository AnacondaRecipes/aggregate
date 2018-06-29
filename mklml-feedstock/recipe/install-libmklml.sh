#!/usr/bin/env bash

if [[ ${HOST} =~ .*darwin.* ]]; then
  cp mklml/lib/libmklml${SHLIB_EXT} $PREFIX/lib
else
  cp mklml/lib/libmklml_intel${SHLIB_EXT} $PREFIX/lib
fi
