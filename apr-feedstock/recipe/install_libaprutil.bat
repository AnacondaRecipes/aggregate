set SUBPKG=apr-util

cmake -GNinja ^
    -S%SRC_DIR%\%SUBPKG% ^
    -B%SRC_DIR%\%SUBPKG%.build ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX%
if errorlevel 1 exit 1

cmake --build %SRC_DIR%\%SUBPKG%.build -- install
if errorlevel 1 exit 1
