#!/bin/bash

# activate the GCC 5.5.0 toolchain

# gxx
export CXXFLAGS="-fvisibility-inlines-hidden -std=c++11 -fmessage-length=0 -march=nocona -mtune=haswell -ftree-vectorize -fPIC -fstack-protector-strong -O2 -pipe -I${PREFIX}/include -fdebug-prefix-map=${SRC_DIR}=/usr/local/src/conda/${PKG_NAME}-${PKG_VERSION} -fdebug-prefix-map=${PREFIX}=/usr/local/src/conda-prefix"
export CXX="${BUILD_PREFIX}/bin/x86_64-conda_cos6-linux-gnu-c++"
export DEBUG_CXXFLAGS="-fvisibility-inlines-hidden -std=c++11 -fmessage-length=0 -march=nocona -mtune=haswell -ftree-vectorize -fPIC -fstack-protector-all -Og -g -Wall -Wextra -fvar-tracking-assignments -pipe -I${PREFIX}/include -fdebug-prefix-map=${SRC_DIR}=/usr/local/src/conda/${PKG_NAME}-${PKG_VERSION} -fdebug-prefix-map=${PREFIX}=/usr/local/src/conda-prefix"
export GXX="${BUILD_PREFIX}/bin/x86_64-conda_cos6-linux-gnu-g++"
export HOST="x86_64-conda_cos6-linux-gnu"

# binutils
export ADDR2LINE="${BUILD_PREFIX}/bin/x86_64-conda_cos6-linux-gnu-addr2line"
export AR="${BUILD_PREFIX}/bin/x86_64-conda_cos6-linux-gnu-ar"
export AS="${BUILD_PREFIX}/bin/x86_64-conda_cos6-linux-gnu-as"
export CXXFILT="${BUILD_PREFIX}/bin/x86_64-conda_cos6-linux-gnu-c++filt"
export ELFEDIT="${BUILD_PREFIX}/bin/x86_64-conda_cos6-linux-gnu-elfedit"
export GPROF="${BUILD_PREFIX}/bin/x86_64-conda_cos6-linux-gnu-gprof"
export LD_GOLD="${BUILD_PREFIX}/bin/x86_64-conda_cos6-linux-gnu-ld.gold"
export LD="${BUILD_PREFIX}/bin/x86_64-conda_cos6-linux-gnu-ld"
export NM="${BUILD_PREFIX}/bin/x86_64-conda_cos6-linux-gnu-nm"
export OBJCOPY="${BUILD_PREFIX}/bin/x86_64-conda_cos6-linux-gnu-objcopy"
export OBJDUMP="${BUILD_PREFIX}/bin/x86_64-conda_cos6-linux-gnu-objdump"
export RANLIB="${BUILD_PREFIX}/bin/x86_64-conda_cos6-linux-gnu-ranlib"
export READELF="${BUILD_PREFIX}/bin/x86_64-conda_cos6-linux-gnu-readelf"
export SIZE="${BUILD_PREFIX}/bin/x86_64-conda_cos6-linux-gnu-size"
export STRINGS="${BUILD_PREFIX}/bin/x86_64-conda_cos6-linux-gnu-strings"
export STRIP="${BUILD_PREFIX}/bin/x86_64-conda_cos6-linux-gnu-strip"

# gcc
export CC="${BUILD_PREFIX}/bin/x86_64-conda_cos6-linux-gnu-cc"
export CFLAGS="-march=nocona -mtune=haswell -ftree-vectorize -fPIC -fstack-protector-strong -O2 -pipe -I${PREFIX}/include -fdebug-prefix-map=${SRC_DIR}=/usr/local/src/conda/${PKG_NAME}-${PKG_VERSION} -fdebug-prefix-map=${PREFIX}=/usr/local/src/conda-prefix"
export CPPFLAGS="-DNDEBUG -D_FORTIFY_SOURCE=2 -O2"
export CPP="${BUILD_PREFIX}/bin/x86_64-conda_cos6-linux-gnu-cpp"
export DEBUG_CFLAGS="-march=nocona -mtune=haswell -ftree-vectorize -fPIC -fstack-protector-all -Og -g -Wall -Wextra -fvar-tracking-assignments -pipe -I${PREFIX}/include -fdebug-prefix-map=${SRC_DIR}=/usr/local/src/conda/${PKG_NAME}-${PKG_VERSION} -fdebug-prefix-map=${PREFIX}=/usr/local/src/conda-prefix"
export DEBUG_CPPFLAGS="-D_DEBUG -D_FORTIFY_SOURCE=2 -Og"
export GCC_AR="${BUILD_PREFIX}/bin/x86_64-conda_cos6-linux-gnu-gcc-ar"
export GCC_NM="${BUILD_PREFIX}/bin/x86_64-conda_cos6-linux-gnu-gcc-nm"
export GCC="${BUILD_PREFIX}/bin/x86_64-conda_cos6-linux-gnu-gcc"
export GCC_RANLIB="${BUILD_PREFIX}/bin/x86_64-conda_cos6-linux-gnu-gcc-ranlib"
export LDFLAGS="-Wl,-O2 -Wl,--sort-common -Wl,--as-needed -Wl,-z,relro -Wl,-z,now -Wl,-rpath,${PREFIX}/lib -L${PREFIX}/lib"
export _PYTHON_SYSCONFIGDATA_NAME="_sysconfigdata_x86_64_conda_cos6_linux_gnu"
