@echo on
setlocal enabledelayedexpansion

mkdir build
cd build

cmake %SRC_DIR% ^
    -GNinja ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
    -DCMAKE_CUDA_ARCHITECTURES="60;70;75;80;86;89;90"
if errorlevel 1 exit 1

ninja
if errorlevel 1 exit 1

ninja install
if errorlevel 1 exit 1
