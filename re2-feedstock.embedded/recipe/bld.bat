@echo on

:: Remove -GL from CXXFLAGS as this causes a fatal error
set "CFLAGS= -MD"
set "CXXFLAGS= -MD"

mkdir -p cmake-build
cd cmake-build
set "VS_VERSION=14.0"
set "VS_MAJOR=14"
set "VS_YEAR=2015"
cmake -DBUILD_SHARED_LIBS=ON ^
      -DCMAKE_BUILD_TYPE=Release ^
      -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
      -G "NMake Makefiles" ^
      %SRC_DIR%
if errorlevel 1 exit 1

nmake
if errorlevel 1 exit 1

ctest -E "dfa|exhaustive|random"
if errorlevel 1 exit 1

nmake install
if errorlevel 1 exit 1

@rem Build static libraries, install as re2_static.lib
cmake -DBUILD_SHARED_LIBS=OFF ^
      -DCMAKE_BUILD_TYPE=Release ^
      -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
      -G "NMake Makefiles" ^
      %SRC_DIR%
if errorlevel 1 exit 1

nmake
if errorlevel 1 exit 1

copy re2.lib %LIBRARY_LIB%\re2_static.lib
if errorlevel 1 exit 1
