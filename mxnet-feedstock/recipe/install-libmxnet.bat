REM Fire all the activation scripts
call %BUILD_PREFIX%\Scripts\activate.bat %BUILD_PREFIX%

set MKL_ROOT=%LIBRARY_PREFIX%

mkdir build
cd build

cmake -G"%CMAKE_GENERATOR%" ^
  -Wno-dev ^
  -DUSE_CUDA=0 ^
  -DUSE_CUDNN=0 ^
  -DUSE_OPENMP=ON ^
  -DUSE_OPENCV=ON ^
  -DUSE_JEMALLOC=OFF ^
  -DBLAS=%blas_impl% ^
  -DUSE_CPP_PACKAGE=ON ^
  -DCMAKE_BUILD_TYPE=Release ^
  -DOpenCV_DIR=%LIBRARY_PREFIX% ^
  -DOpenCV_LIB_PATH=%LIBRARY_LIB% ^
  -DOpenCV_INCLUDE_DIRS=%LIBRARY_INC% ^
  -DCMAKE_PREFIX_PATH=%LIBRARY_PREFIX% ^
  -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
  ..
if errorlevel 1 exit 1

cmake --build . --target INSTALL --config Release
if errorlevel 1 exit 1

REM https://github.com/apache/incubator-mxnet/tree/1.0.0/cpp-package
xcopy /s /y %SRC_DIR%\cpp-package\include %LIBRARY_INC%\
if errorlevel 1 exit 1
