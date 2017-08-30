#!/bin/bash

pushd cmake-bin/CMake.app/Contents
  mkdir ${PREFIX}/cmake-bin
  rm -rf bin/cmake-gui
  cp -rf bin doc man share ${PREFIX}/cmake-bin
popd
