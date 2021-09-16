#!/bin/sh

set -x

cd "${SRC_DIR}/apr"

# Get an updated config.sub and config.guess
cp $BUILD_PREFIX/share/libtool/build-aux/config.* ./build

if [[ "$CONDA_BUILD_CROSS_COMPILATION" == "1" && $target_platform == "osx-arm64" ]]; then
  export ac_cv_file__dev_zero=yes
  export ac_cv_func_setpgrp_void=yes
  export apr_cv_process_shared_works=yes
  export apr_cv_mutex_robust_shared=no
  export apr_cv_mutex_recursive=yes
  export apr_cv_tcp_nodelay_with_cork=no
  export ac_cv_sizeof_struct_iovec=16
  export ap_cv_atomic_builtins=yes
  export apr_cv_gai_addrconfig=yes
  export ac_cv_sizeof_pid_t=4
fi

autoreconf -vfi

ln -s $CC ./cc

export PATH=$PWD:$PATH

CC="${CC}" ./configure --prefix="${PREFIX}" --host="${HOST}"

make
make install
