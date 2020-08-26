#!/bin/bash

# FIXME:
# pythonw this should really be the compiled program Mac/Tools/pythonw.c
# note that PYTHONEXECUTABLE is used to fix argv[0] (see Modules/main.c)

APP_DIR=$PREFIX/python.app
mkdir $APP_DIR
cp -r $RECIPE_DIR/Contents $APP_DIR
MACOS_DIR=$APP_DIR/Contents/MacOS
mkdir -p $MACOS_DIR
cp $PREFIX/bin/python $MACOS_DIR
install_name_tool -change "@loader_path/../lib/libpython${PY_VER}.dylib" \
    "$PREFIX/lib/libpython${PY_VER}.dylib" $MACOS_DIR/python

PYAPP=$PREFIX/bin/python.app
cat <<EOF >$PYAPP
#!/bin/bash
export PYTHONEXECUTABLE=$PREFIX/bin/python
$PREFIX/python.app/Contents/MacOS/python "\$@"
EOF
chmod +x $PYAPP

BIN=$PREFIX/bin
cd $BIN
cp python.app pythonw
