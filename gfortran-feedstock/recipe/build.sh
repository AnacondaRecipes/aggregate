#!/bin/bash

pushd ${PREFIX}/bin
  # It is expected this will be built on macOS only:
  ln -s gfortran ${BUILD}-gfortran
popd
