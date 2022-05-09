export PREFIX_NSIS=$PREFIX/NSIS

pushd binary
cp -r . "$PREFIX_NSIS"
rm -rf $PREFIX_NSIS/Docs
rm -rf $PREFIX_NSIS/Examples
popd

pushd plugins
cp "BgWorker/BgWorker.dll" "$PREFIX_NSIS/Plugins/x86-unicode/"
cp "UAC/Plugins/x86-unicode/UAC.dll" "$PREFIX_NSIS/Plugins/x86-unicode/"
cp "untgz/Plugins/x86-unicode/untgz.dll" "$PREFIX_NSIS/Plugins/x86-unicode/"
cp "UnicodePathTest/Plugin/UnicodePathTest.dll" "$PREFIX_NSIS/Plugins/x86-unicode/"
popd

cd src

scons \
  CC="${CC}" CXX="${CXX}" APPEND_CCFLAGS="${CXXFLAGS}" APPEND_LINKFLAGS="${LDFLAGS}" \
  SKIPSTUBS=all SKIPPLUGINS=all SKIPUTILS=all SKIPMISC=all \
  NSIS_CONFIG_CONST_DATA_PATH=yes PREFIX=$PREFIX_NSIS \
  -Q PATH=$PATH install-compiler

mkdir -p $PREFIX/bin
ln -sf $PREFIX_NSIS/bin/makensis $PREFIX_NSIS/makensis.exe
ln -sf $PREFIX_NSIS/bin/makensis $PREFIX/bin/makensis

pushd $PREFIX_NSIS
  mkdir share
  cd share
  ln -sf $PREFIX_NSIS nsis
popd
