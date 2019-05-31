mkdir build && cd build

cmake -G"%CMAKE_GENERATOR%" ^
  -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
  -DCMAKE_BUILD_TYPE=Release ^
  -DMKLROOT="%LIBRARY_PREFIX%" ^
  %SRC_DIR%
if errorlevel 1 exit 1

cmake --build . --config Release
if errorlevel 1 exit 1

ctest

cmake --build . --target install
if errorlevel 1 exit 1
