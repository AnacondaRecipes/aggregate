#!/bin/bash
set -x

# ++awful .. broken configure script here, it does not look in include/openssl
cp -f ${PREFIX}/include/openssl/des.h ${PREFIX}/include

if [[ ${target_platform} == osx-64 ]]; then
  DISABLE_MACOS_FRAMEWORK=--disable-macos-framework
fi

if [[ ${target_platform} =~ .*ppc.* ]]; then
  # We should probably run autoreconf here instead, but I am tired of this software.
  BUILD_FLAG="--build=${HOST}"
  if [[ 0 == 1 ]]; then
    echo libtoolize
    libtoolize
    echo aclocal -I cmulocal -I config
    aclocal -I cmulocal -I config
    echo autoheader
    autoheader
    echo autoconf
    autoconf
    echo automake --add-missing --include-deps
    automake --add-missing --include-deps
  fi
elif [[ ${target_platform} =~ osx.* ]]; then
  # Using ${HOST}.different results in:
  # configure:17682: checking for SPNEGO support in GSSAPI libraries
  # configure:17685: error: in `/opt/conda/conda-bld/cyrus-sasl-2.1.27_21/work':
  # configure:17687: error: cannot run test program while cross compiling
  # BUILD_FLAG="--build=${HOST}.different"
  # (my hope was it would stop running gcc for build tools!)
  BUILD_FLAG="--build=${HOST}"
  export CFLAGS="${CFLAGS} -DTARGET_OS_MAC=1"
fi

# Cyrus sasl REALLY wants something called gcc to exist.  Desperately
# ln -s ${CC} ${BUILD_PREFIX}/bin/gcc
echo false >> ${BUILD_PREFIX}/bin/gcc
chmod +x ${BUILD_PREFIX}/bin/gcc
export CC_FOR_BUILD=${CC}
export CFLAGS_FOR_BUILD=${CFLAGS}

if [[ ${PKG_VERSION} != 2.1.27 ]]; then
  pushd git-master
  cp -rf m4 ..
  cp -rf configure.ac ..
  cp -rf autogen.sh ..
  find . -name "configure.*" -exec cp {} ../{} \;
  mv Makefile.am Makefile.am.orig
  find . -name "Makefile*" -exec cp {} ../{} \;
  mv Makefile.am.orig Makefile.am
fi
aclocal --verbose --install || exit 1
autoreconf --verbose --force --install -Wno-portability || exit 1

# --disable-dependency-tracking works around:
# https://forums.gentoo.org/viewtopic-t-366917-start-0.html
./configure --prefix=${PREFIX}                    \
            --host=${HOST}                        \
            ${BUILD_FLAG}                         \
            --enable-gssapi                       \
            --enable-digest                       \
            --enable-ntlm                         \
            --with-des=${PREFIX}                  \
            --with-plugindir=${PREFIX}/lib/sasl2  \
            --with-configdir=${PREFIX}/etc/sasl2  \
            --with-openssl=${PREFIX}              \
            --disable-dependency-tracking         \
            ${DISABLE_MACOS_FRAMEWORK} || { cat config.log; exit 1; }
cat config.log

echo "Makefile looks like:"
cat include/Makefile

# Parallel builds fail frequently.
make -j1 ${VERBOSE_AT}
make install

# awful--
rm -f ${PREFIX}/include/des.h

# ++awful
if [[ ${target_platform} == osx-64 ]]; then
  if [ -f ${PREFIX}/sbin/${HOST}-pluginviewer ]; then
    mv ${PREFIX}/sbin/${HOST}-pluginviewer ${PREFIX}/sbin/pluginviewer
  fi
  if [ -f ${PREFIX}/sbin/${HOST}-pluginviewer ]; then
    mv ${PREFIX}/sbin/${HOST}-saslpasswd2 ${PREFIX}/sbin/saslpasswd2
  fi
  if [ -f ${PREFIX}/sbin/${HOST}-sasldblistusers2 ]; then
    mv ${PREFIX}/sbin/${HOST}-sasldblistusers2 ${PREFIX}/sbin/sasldblistusers2
  fi
  ${INSTALL_NAME_TOOL:-install_name_tool} -id @rpath/libsasl2.dylib ${PREFIX}/lib/libsasl2.dylib
  ${INSTALL_NAME_TOOL:-install_name_tool} -change /libsasl2.dylib @rpath/libsasl2.dylib ${PREFIX}/sbin/pluginviewer
  ${INSTALL_NAME_TOOL:-install_name_tool} -change /libsasl2.dylib ${PREFIX}/lib/libsasl2.dylib ${PREFIX}/sbin/saslpasswd2
  ${INSTALL_NAME_TOOL:-install_name_tool} -change /libsasl2.dylib ${PREFIX}/lib/libsasl2.dylib ${PREFIX}/sbin/sasldblistusers2
fi

pushd utils
  make testsuite
  cp .libs/testsuite ${PREFIX}/bin/cyrus-sasl-testsuite
popd
