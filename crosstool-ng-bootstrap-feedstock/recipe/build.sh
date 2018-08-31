#!/bin/bash

export EXTRA_CFLAGS="-I${PREFIX}/include -I${PREFIX}/include/ncurses"
export EXTRA_LDFLAGS="-L${PREFIX}/lib -Wl,-rpath,${PREFIX}/lib -lncursesw"
export CPPFLAGS="-I${PREFIX}/include -L${PREFIX}/lib"

if [[ $(uname) == Darwin ]]; then
  if ! which objcopy; then
    echo "#!/usr/bin/env bash" > ${PWD}/objcopy
    echo "exit 0"             >> ${PWD}/objcopy
    export OBJCOPY=${PWD}/objcopy
    chmod +x ${PWD}/objcopy
  fi
  if ! which readelf; then
    echo "#!/usr/bin/env bash" > ${PWD}/readelf
    echo "exit 0"             >> ${PWD}/readelf
    export READELF=${PWD}/readelf
    chmod +x ${PWD}/readelf
  fi
  if ! which help2man; then
    echo "#!/usr/bin/env bash" > ${PWD}/help2man
    echo "exit 0"             >> ${PWD}/help2man
    export HELP2MAN=${PWD}/help2man
    chmod +x ${PWD}/help2man
  fi
  export PATH="${PWD}:${PATH}"
  export LIBTOOL=${BUILD_PREFIX}/bin/libtool
  export LDFLAGS="${LDFLAGS} -lintl"
fi

# -rpath-link is needed because libncursesw.so dependes on libtinfo.so and
# configure will fail to find ncurses without it (if using the conda ncurses
# package).
if [[ ${target_platform} =~ .*linux.* ]]; then
  export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include -Wl,-rpath-link,${PREFIX}/lib"
else
  export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
fi

./bootstrap
./configure --prefix=${PREFIX}
make -j${CPU_COUNT} ${VERBOSE_AT}
make install
