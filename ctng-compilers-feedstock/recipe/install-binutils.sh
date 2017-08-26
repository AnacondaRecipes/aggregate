set -e -x

CHOST=$(${SRC_DIR}/.build/*-*-*-*/build/build-cc-gcc-final/gcc/xgcc -dumpmachine)

pushd ${SRC_DIR}/.build/${CHOST}/build/build-binutils-host-*
  PATH=${SRC_DIR}/.build/${CHOST}/buildtools/bin:$PATH \
  make prefix=${PREFIX} install
popd

# Copy the liblto_plugin.so from the build tree. This is something of a hack and, on OSes other
# than the build OS, may cause segfaults. This plugin is used by gcc-ar, gcc-as and gcc-ranlib.
pushd ${SRC_DIR}/.build/*-*-*-*/build/build-cc-gcc-core-pass-2/gcc/
  mkdir -p ${PREFIX}/libexec/gcc/${CHOST}/${TOP_PKG_VERSION}/
  cp -a liblto* ${PREFIX}/libexec/gcc/${CHOST}/${TOP_PKG_VERSION}/
popd

mkdir -p ${PREFIX}/etc/conda/{de,}activate.d
cp "${SRC_DIR}"/activate-binutils.sh ${PREFIX}/etc/conda/activate.d/activate-${PKG_NAME}.sh
cp "${SRC_DIR}"/deactivate-binutils.sh ${PREFIX}/etc/conda/deactivate.d/deactivate-${PKG_NAME}.sh

# Strip executables, we may want to install to a different prefix
# and strip in there so that we do not change files that are not
# part of this package.
pushd ${PREFIX}
  _files=$(find . -type f)
  for _file in ${_files}; do
    _type="$( file "${_file}" | cut -d ' ' -f 2- )"
    case "${_type}" in
      *script*executable*)
      ;;
      *executable*)
        ${SRC_DIR}/gcc_built/bin/${CHOST}-strip --strip-all -v "${_file}"
      ;;
    esac
  done
popd
