#!/bin/bash
set -ex

cp $SRC_DIR/$PKG_NAME/info/LICENSE.txt $SRC_DIR
# for subpackages, we have named our extracted locations according to the subpackage name
#    That's what this $PKG_NAME is doing - picking the right subfolder to rsync

if [[ `uname` == "MINGW64_NT-10.0" ]]; then
    src=$(cygpath -u "$SRC_DIR/$PKG_NAME/")
    cp -rv $src/* "$PREFIX/"
else
    mv -v $SRC_DIR/$PKG_NAME/* "$PREFIX/"
fi

rm -rf $PREFIX/info

if [[ `uname` == Darwin && -d $SRC_DIR/$PKG_NAME/lib ]]; then
    # Strip off support for PPC - saves about 100 MB
    python $RECIPE_DIR/deuniversalize.py --ignore-wrong-arch $SRC_DIR/$PKG_NAME/lib/* $PREFIX/lib
fi
