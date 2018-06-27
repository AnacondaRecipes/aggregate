@echo on
:: Delegate to the Unixy script. We need to translate the key path variables
:: to be Unix-y rather than Windows-y, though.
set "saved_recipe_dir=%RECIPE_DIR%"
set "saved_source_dir=%SRC_DIR%"

FOR /F "delims=" %%i IN ('cygpath.exe -u "%PYTHON%"') DO set "BAZEL_PYTHON=%%i"
FOR /F "delims=" %%i IN ('cygpath.exe -u "%LIBRARY_PREFIX%\usr\bin\bash.exe"') DO set "BAZEL_SH=%%i"

FOR /F "delims=" %%i IN ('cygpath.exe -u -p "%PATH%"') DO set "PATH_OVERRIDE=%%i"
FOR /F "delims=" %%i IN ('cygpath.exe -u "%PREFIX%"') DO set "PREFIX=%%i"
FOR /F "delims=" %%i IN ('cygpath.exe -u "%PYTHON%"') DO set "PYTHON=%%i"
FOR /F "delims=" %%i IN ('cygpath.exe -u "%RECIPE_DIR%"') DO set "RECIPE_DIR=%%i"
FOR /F "delims=" %%i IN ('cygpath.exe -u "%SP_DIR%"') DO set "SP_DIR=%%i"
FOR /F "delims=" %%i IN ('cygpath.exe -u "%SRC_DIR%"') DO set "SRC_DIR=%%i"
FOR /F "delims=" %%i IN ('cygpath.exe -u "%STDLIB_DIR%"') DO set "STDLIB_DIR=%%i"

:: LIBRARY_PREFIX gets translated to '/' instead of the absolute path
FOR /F "delims=" %%i IN ('cygpath.exe -u "%PREFIX%"') DO set "JAVA_HOME=%%i/Library"
FOR /F "delims=" %%i IN ('cygpath.exe -u "%PREFIX%"') DO set "LIBRARY_BIN=%%i/Library/bin"

:: Need a very short TMPDIR otherwise we hit the max path limit while compiling bazel
FOR /F "delims=" %%i IN ('cygpath.exe -u "%SYSTEMDRIVE%\t"') DO set "TMPDIR=%%i"

set MSYSTEM=MINGW%ARCH%
set MSYS2_PATH_TYPE=inherit
set CHERE_INVOKING=1
bash -lc "%RECIPE_DIR%"/build_win.sh
if errorlevel 1 exit 1
