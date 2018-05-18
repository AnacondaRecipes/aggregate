#!/bin/bash

# Remove the openssl include file which conflict with the internal boringssl
# include files
rm -rf ${PREFIX}/include/openssl*

# set these so the default in setup.py are not used
export GRPC_PYTHON_CFLAGS=""
export GRPC_PYTHON_LDFLAGS=""

if [[ ${HOST} =~ .*darwin.* ]]; then
    # the makefile uses $AR for creating libraries, set it correctly here
    export AR="$LIBTOOL -no_warning_for_no_symbols -o"

    # we need a single set of openssl include files, the ones in PREFIX were
    # removed above
    export CFLAGS="${CFLAGS} -I./third_party/boringssl/include"
    export CXXFLAGS="${CXXFLAGS} -I./third_party/boringssl/include"

    # the Python extension has an unresolved _deflate symbol, link to libz to
    # resolve
    export LDFLAGS="${LDFLAGS} -lz"
fi

python setup.py install --single-version-externally-managed --record=record.txt
