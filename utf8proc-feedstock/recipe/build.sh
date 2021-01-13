echo "Current prefix: ${PREFIX}"
# link to 
ln -s "${CC}" cc
export PATH=${PWD}:${PATH}

make
make check
export DESTDIR=${PREFIX}
make DESTDIR=${PREFIX} install


