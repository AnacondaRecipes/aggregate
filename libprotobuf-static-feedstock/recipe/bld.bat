:: Setup directory structure per protobuf's instructions.
cd cmake
if errorlevel 1 exit 1
mkdir build
if errorlevel 1 exit 1
cd build
if errorlevel 1 exit 1
mkdir release
if errorlevel 1 exit 1
cd release
if errorlevel 1 exit 1

:: Configure and install based on protobuf's instructions and other `bld.bat`s.
cmake -G "NMake Makefiles" ^
         -DCMAKE_BUILD_TYPE=Release ^
         -DCMAKE_PREFIX_PATH=%LIBRARY_PREFIX% ^
         -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
         -Dprotobuf_WITH_ZLIB=ON ^
         -Dprotobuf_BUILD_SHARED_LIBS=OFF ^
         -Dprotobuf_BUILD_STATIC_LIBS=ON ^
         -Dprotobuf_MSVC_STATIC_RUNTIME=OFF ^
         ../..
if errorlevel 1 exit 1
nmake
if errorlevel 1 exit 1
nmake check
if errorlevel 1 exit 1
nmake install
if errorlevel 1 exit 1
