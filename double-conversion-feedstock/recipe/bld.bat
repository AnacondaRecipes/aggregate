setlocal EnableDelayedExpansion

:: Build shared library
mkdir build-shared
pushd build-shared

cmake -G "NMake Makefiles" ^
      -DCMAKE_INSTALL_PREFIX:PATH="%LIBRARY_PREFIX%" ^
      -DCMAKE_PREFIX_PATH:PATH="%LIBRARY_PREFIX%" ^
      -DCMAKE_BUILD_TYPE:STRING=Release ^
      -DBUILD_TESTING=OFF -DBUILD_SHARED_LIBS=ON ^
      .. || exit 1
nmake || exit 1
nmake install || exit 1

popd

:: Build static library
mkdir build-static
pushd build-static

cmake -G "NMake Makefiles" ^
      -DCMAKE_INSTALL_PREFIX:PATH="%LIBRARY_PREFIX%" ^
      -DCMAKE_PREFIX_PATH:PATH="%LIBRARY_PREFIX%" ^
      -DCMAKE_BUILD_TYPE:STRING=Release ^
      -DBUILD_TESTING=OFF -DBUILD_SHARED_LIBS=OFF ^
      .. || exit 1
nmake || exit 1
nmake install || exit 1

popd

