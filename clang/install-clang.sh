#!/bin/bash

mkdir -p ${PREFIX}/etc/conda/activate.d/

cp ${RECIPE_DIR}/activate.sh ${PREFIX}/etc/conda/activate.d/conda_"${PKG_NAME}".sh
# hard-code the sdk version we build for
sed -i '' "s/@macos_min_version@/${macos_min_version}/" ${PREFIX}/etc/conda/activate.d/conda_"${PKG_NAME}".sh
