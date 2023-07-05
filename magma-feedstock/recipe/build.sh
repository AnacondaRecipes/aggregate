#!/bin/bash

export CMAKE_LIBRARY_PATH=$PREFIX/lib:$PREFIX/include:$CMAKE_LIBRARY_PATH
export CMAKE_PREFIX_PATH=$PREFIX
export PATH=$PREFIX/bin:/usr/local/cuda-${cudatoolkit}/bin:$PATH
export MKLROOT=$PREFIX/lib

mkdir build
cd build
cmake .. -DUSE_FORTRAN=OFF -DGPU_TARGET="Fermi Kepler Maxwell Pascal Volta Turing Ampere" -DMAGMA_ENABLE_CUDA=ON -DCMAKE_INSTALL_PREFIX=$PREFIX
make -j${CPU_COUNT} ${VERBOSE_AT}
make install
cd ..
