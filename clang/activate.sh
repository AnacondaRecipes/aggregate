#!/bin/bash

# check if clang exists. stderr is thrown away by dev/null
if hash clang 2>/dev/null && xcodebuild -showsdks | grep -q "\-sdk macosx@macos_min_version@"
then
    # for Mac OSX
    export CC=clang
    export CXX=clang++
    export MACOSX_DEPLOYMENT_TARGET="@macos_min_version@"
    export CMAKE_OSX_DEPLOYMENT_TARGET="@macos_min_version@"
    export CFLAGS="${CFLAGS} -mmacosx-version-min=@macos_min_version@"
    export CXXFLAGS="${CXXFLAGS} -mmacosx-version-min=@macos_min_version@"
    export CXXFLAGS="${CXXFLAGS} -stdlib=libc++"
    export LDFLAGS="${LDFLAGS} -headerpad_max_install_names"
    export LDFLAGS="${LDFLAGS} -mmacosx-version-min=@macos_min_version@"
    export LDFLAGS="${LDFLAGS} -lc++"
    export LINKFLAGS="${LDFLAGS}"
else
    echo "This system is unsupported by this recipe."
    exit 1
fi
