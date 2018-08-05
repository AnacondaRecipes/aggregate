set VC_PATH=x86
if "%ARCH%"=="64" (
   set VC_PATH=x64
)

set MSC_VER=2017

REM ========== REQUIRES Win 10 SDK be installed, or files otherwise copied to location below!
robocopy "C:\Program Files (x86)\Windows Kits\10\Redist\ucrt\DLLs\%VC_PATH%"  "%LIBRARY_BIN%" *.dll /E
if %ERRORLEVEL% GEQ 8 exit 1
robocopy "C:\Program Files (x86)\Windows Kits\10\Redist\ucrt\DLLs\%VC_PATH%"  "%PREFIX%" *.dll /E
if %ERRORLEVEL% GEQ 8 exit 1
COPY "C:\Program Files (x86)\Windows Kits\10\Redist\ucrt\DLLs\%VC_PATH%\ucrtbase.dll" "%LIBRARY_BIN%"
COPY "C:\Program Files (x86)\Windows Kits\10\Redist\ucrt\DLLs\%VC_PATH%\ucrtbase.dll" "%PREFIX%"

REM ========== This one comes from visual studio 2017
set "UPDATE_VER=14.14.26405"
set "VC_VER=141"
set "BT_ROOT=C:\Program Files (x86)\Microsoft Visual Studio\%MSC_VER%\Enterprise"
if not exist "%BT_ROOT%" (
set "BT_ROOT=C:\Program Files (x86)\Microsoft Visual Studio\%MSC_VER%\Community"
)
if not exist "%BT_ROOT%" (
set "BT_ROOT=C:\Program Files (x86)\Microsoft Visual Studio\%MSC_VER%\BuildTools"
)
if not exist "%BT_ROOT%" (
set "BT_ROOT=C:\Program Files (x86)\Microsoft Visual Studio\%MSC_VER%\Professional"
)

set "REDIST_ROOT=%BT_ROOT%\VC\Redist\MSVC\%UPDATE_VER%\%VC_PATH%"
robocopy "%REDIST_ROOT%\Microsoft.VC%VC_VER%.CRT" "%LIBRARY_BIN%" *.dll /E
if %ERRORLEVEL% GTR 8 exit 1
robocopy "%REDIST_ROOT%\Microsoft.VC%VC_VER%.CRT" "%PREFIX%" *.dll /E
if %ERRORLEVEL% GTR 8 exit 1
robocopy "%REDIST_ROOT%\Microsoft.VC%VC_VER%.OpenMP" "%LIBRARY_BIN%" *.dll /E
if %ERRORLEVEL% GTR 8 exit 1
robocopy "%REDIST_ROOT%\Microsoft.VC%VC_VER%.OpenMP" "%PREFIX%" *.dll /E
if %ERRORLEVEL% GTR 8 exit 1

