
mkdir build
if errorlevel 1 exit 1
cd build
if errorlevel 1 exit 1
cmake -G "NMake Makefiles" ^
  -DCMAKE_BUILD_TYPE:STRING="Release" ^
  -DCMAKE_INSTALL_PREFIX:PATH="%LIBRARY_PREFIX%" ^
  -DCMAKE_PREFIX_PATH:PATH="%LIBRARY_PREFIX%" ^
  -DCMAKE_POSITION_INDEPENDENT_CODE:BOOL=ON ^
  -DBUILD_SHARED_LIBS:BOOL=ON ^
  "%SRC_DIR%"

if errorlevel 1 exit 1
cmake --build . --config Release
cmake --build . --target install --config Release

exit 0
