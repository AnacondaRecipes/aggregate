#!/bin/bash

# export JAVA_HOME="${PREFIX}"
export ANT_HOME="${PREFIX}"

for i in etc lib bin; do
  mkdir -p "${PREFIX}/$i"
done

./build.sh install-lite

# ensure that ANT_HOME is set correctly
mkdir -p $PREFIX/etc/conda/activate.d
echo 'export ANT_HOME_CONDA_BACKUP=$ANT_HOME' > "$PREFIX/etc/conda/activate.d/ant_home.sh"
echo 'export ANT_HOME=$CONDA_PREFIX' >> "$PREFIX/etc/conda/activate.d/ant_home.sh"
mkdir -p $PREFIX/etc/conda/deactivate.d
echo 'export ANT_HOME=$ANT_HOME_CONDA_BACKUP' > "$PREFIX/etc/conda/deactivate.d/ant_home.sh"
