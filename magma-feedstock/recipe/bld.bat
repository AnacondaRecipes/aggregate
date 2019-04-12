cmake ^
  -H. ^
  -Bbuild ^
  -G"Ninja" ^
  -DUSE_FORTRAN=OFF ^
  -DCMAKE_BUILD_TYPE=Release ^
  -DCMAKE_PREFIX_PATH=%LIBRARY_PREFIX% ^
  -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX%

cmake --build build

cmake --build build -- install
