#!/bin/bash

# Remove the openssl include file which conflict with the internal boringssl
# include files
rm -rf ${PREFIX}/include/openssl*

# set these so the default in setup.py are not used
export GRPC_PYTHON_CFLAGS=""
export GRPC_PYTHON_LDFLAGS=""

python setup.py install --single-version-externally-managed --record=record.txt
