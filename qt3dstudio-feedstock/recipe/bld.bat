:: Apply submodule patch
pushd src/Runtime/Qt3DSRuntime
  git am %RECIPE_DIR%/0001-linux-Need-lrt-for-clock_gettime.patch
popd

if not exist build mkdir build
pushd build

if not exist Makefile qmake -r ..\qt3dstudio.pro
jom
jom -f Makefile install
jom -f Makefile sub-examples-install_subtargets
if not exist %PREFIX%\share\qt3dstudio mkdir %PREFIX%\share\qt3dstudio
rename %PREFIX%\Library\examples %PREFIX%\Library\share
rename %PREFIX%\Library\share\studio3d %PREFIX%\Library\share\qt3dstudio
xcopy /f /s /y /i public-demos\* %PREFIX%\Library\share\qt3dstudio

exit 1
