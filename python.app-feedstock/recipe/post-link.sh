#!/bin/bash

cp -r "$PREFIX/pythonapp" "$PREFIX/python.app"
rm -rf "$PREFIX/pythonapp"

cd "$PREFIX/python.app/Contents"

# Added so that force re-installs of Anaconda or Miniconda work
ln -Ffs ../../lib lib || true
