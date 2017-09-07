#!/bin/bash

if [[ $(uname) == Darwin ]]; then
  pushd cmake-bin/CMake.app/Contents
    mkdir ${PREFIX}/cmake-bin
    rm -rf bin/cmake-gui
    cp -rf bin doc man share ${PREFIX}/cmake-bin
  popd
else
  cp -rf cmake-bin ${PREFIX}/
fi
