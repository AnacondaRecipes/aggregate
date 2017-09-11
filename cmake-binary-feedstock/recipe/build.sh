#!/bin/bash

if [[ $(uname) == Darwin ]]; then
  pushd cmake-bin/CMake.app/Contents
    mkdir ${PREFIX}/cmake-bin
    rm -rf bin/cmake-gui
    cp -rf bin doc man share ${PREFIX}/cmake-bin
  popd
else
  cp -rf cmake-bin ${PREFIX}/
  [[ -d curl-bin ]]    && cp -rf curl-bin/*    ${PREFIX}/cmake-bin/
  [[ -d expat-bin ]]   && cp -rf expat-bin/*   ${PREFIX}/cmake-bin/
  [[ -d krb5-bin ]]    && cp -rf krb5-bin/*    ${PREFIX}/cmake-bin/
  [[ -d libssh2-bin ]] && cp -rf libssh2-bin/* ${PREFIX}/cmake-bin/
  [[ -d ncurses-bin ]] && cp -rf ncurses-bin/* ${PREFIX}/cmake-bin/
  [[ -d openssl-bin ]] && cp -rf openssl-bin/* ${PREFIX}/cmake-bin/
  [[ -d xz-bin ]]      && cp -rf xz-bin/*      ${PREFIX}/cmake-bin/
  [[ -d zlib-bin ]]    && cp -rf zlib-bin/*    ${PREFIX}/cmake-bin/
  [[ -d bzip2-bin ]]   && cp -rf bzip2-bin/*   ${PREFIX}/cmake-bin/
fi
