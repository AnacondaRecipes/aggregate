md build
if errorlevel 1 exit /b 1

cmake ^
  -S . ^
  -B build ^
  -G "Ninja" ^
  -DUSE_FORTRAN=OFF ^
  -DMAGMA_ENABLE_CUDA=ON ^
  -DCMAKE_BUILD_TYPE=Release ^
  -DGPU_TARGET="Fermi Kepler Maxwell Pascal Volta Turing Ampere" ^
  -DMAGMA_WITH_MKL ^
  -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
  -DCUDA_NVCC_FLAGS="--use-local-env" ^
if errorlevel 1 exit /b 1

cmake --build build ^
      --config Release ^
      --parallel %CPU_COUNT% ^
      --target magma magma_sparse ^
      --verbose
if errorlevel 1 exit /b 1

cmake --install .
