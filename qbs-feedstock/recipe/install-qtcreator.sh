#!/bin/bash

set -x -e
. activate "${PREFIX}"

make install INSTALL_ROOT="${PREFIX}"
