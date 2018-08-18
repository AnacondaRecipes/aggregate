#!/usr/bin/env bash

set -x

if [[ -n $1 ]]; then
  SRC_DIR=$1
else
  SRC_DIR=$(pwd)
fi

PKG_NAME=$(cat ${SRC_DIR}/conda_build.sh | grep PKG_NAME= | tr -d '"' | sed 's/.*=//')
PKG_VERSION=$(cat ${SRC_DIR}/conda_build.sh | grep PKG_VERSION= | tr -d '"' | sed 's/.*=//')

[[ -d /usr/local/src/conda/${PKG_NAME}-${PKG_VERSION} ]] && rm -rf /usr/local/src/conda/${PKG_NAME}-${PKG_VERSION}
ln -s ${SRC_DIR} /usr/local/src/conda/${PKG_NAME}-${PKG_VERSION}
