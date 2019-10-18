#!/bin/bash

mkdir -p ${PREFIX}/i686-conda_cos6-linux-gnu/sysroot
pushd ${PREFIX}/i686-conda_cos6-linux-gnu/sysroot > /dev/null 2>&1
cp -Rf "${SRC_DIR}"/binary/* .
