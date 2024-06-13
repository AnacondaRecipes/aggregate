#!/bin/bash

set -eu

echo "Building ${PKG_NAME}"

# For subpackages, we have named our extracted locations according to the subpackage name
# That's what this $PKG_NAME is doing - picking the right subfolder to copy

src="${SRC_DIR}/${PKG_NAME}"

# activate.py will set the user's PATH to:
#
# (old) PREFIX/Library/mingw-w64/bin:PREFIX/Library/usr/bin:PREFIX/Library/bin:
# (new) PREFIX/Library/CONDA_MSYSTEM/bin:PREFIX/Library/usr/bin:PREFIX/Library/bin:

dst="${PREFIX}"/Library
mkdir -p "${dst}"

rm -f "${src}"/{.BUILDINFO,.MTREE,.PKGINFO,.INSTALL}

# * will collect the mingw-64-* ucrt64/clang64/etc. directories as
# well as the msys2-* usr directory

cp -rv "${src}"/* "${dst}"
