#!/bin/sh

sed -i.bak 's/c89/c99/g' SConstruct

scons APR="$PREFIX" APU="$PREFIX" OPENSSL="$PREFIX" ZLIB="$PREFIX" \
    PREFIX="$PREFIX" CC="$CC" CPPFLAGS="$CPPFLAGS" LINKFLAGS="$LDFLAGS" CFLAGS="$CFLAGS"

scons install
