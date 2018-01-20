#!/bin/bash

if [[ -n ${HOST} ]]; then
  # Since this is involved in bootstrapping on
  # macOS we will not have HOST set to anything.
  HOST_CFG="--host=${HOST}"
elif [[ $(uname) == Darwin ]]; then
  export CFLAGS="${CFLAGS} -isysroot /opt/MacOSX10.9.sdk"
  export AR=ar
  export RANLIB=ranlib
fi

pushd xar
  ./autogen.sh --noconfigure
  # Because --disable-shared happily links to shared libs:
  # (here the xar executable dynamically links them, while
  #  the shared library just contains undefined references)
  rm -f "${PREFIX}"/lib/lib{xml2,bz2,z,lzma,iconv}*.dylib
  ./configure --prefix=${PREFIX}     \
              ${HOST_CFG}            \
              --build=${BUILD}       \
              --with-lzma=${PREFIX}  \
              --disable-shared       \
              --enable-static
  make -j${CPU_COUNT} ${VERBOSE_AT}
  make install
  # Since libxar is linked to ld64 it's imperative that we
  # do not have any transitive static library dependencies.
  # The reason being that these can end up as dynamic libs
  # at the point of consumption. If this library generated
  # .pc files and if my port of ld64 read those this would
  # not be necessary; still it should be safe. One thing to
  # take care about is that libcrypto.dylib is needed and
  # we want that to come from a 10.9 sysroot and not from
  # a conda openssl package. The way to ensure this happens
  # is by linking to '/usr/lib/libcrypto.dylib' directly,
  # instead of using '-L/usr/lib -lcrypto'
  declare -a _statics
  _statics+=(libxar.a)
  _statics+=(libxml2.a)
  _statics+=(libz.a)
  _statics+=(liblzma.a)
  if [[ $(uname) == Darwin ]]; then
    _statics+=(libiconv.a)
  fi
  _statics+=(libbz2.a)
  mkdir -p tmp_reform
  pushd tmp_reform
    for _static in "${_statics[@]}"; do
      _full_a=${PREFIX}/lib/${_static}
      if [[ ! -e ${_full_a} ]]; then
         echo "${_full_a} does not exist"
         ls $(dirname ${_full_a})/*.a
         exit 1
      fi
      ${AR} -x ${_full_a}
    done
    [[ -f ../libxar.a ]] && rm -rf ../libxar.a
    ${AR} crv ../libxar.a *.o
  popd
  ${RANLIB} libxar.a
  cp -f libxar.a ${PREFIX}/lib
popd
