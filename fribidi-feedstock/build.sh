meson builddir -Ddocs=false --prefix=$PREFIX -Ddefault_library=shared
cd builddir
ninja
ninja install

# stuff gets installed into lib64 when we only use lib for conda
if [[ ${HOST} =~ .*linux.* ]]; then
    mkdir -p $PREFIX/lib
    mv $PREFIX/lib64/* $PREFIX/lib
    rm -rf $PREFIX/lib64
fi
