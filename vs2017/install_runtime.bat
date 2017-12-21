set VC_PATH=x86
if "%ARCH%"=="64" (
   set VC_PATH=x64
)

set MSC_VER=2017

REM ========== REQUIRES Win 10 SDK be installed, or files otherwise copied to location below!
robocopy "C:\Program Files (x86)\Windows Kits\10\Redist\ucrt\DLLs\%VC_PATH%"  "%LIBRARY_BIN%" *.dll /E
robocopy "C:\Program Files (x86)\Windows Kits\10\Redist\ucrt\DLLs\%VC_PATH%"  "%PREFIX%" *.dll /E
if %ERRORLEVEL% GEQ 8 exit 1

REM ========== This one comes from visual studio 2017
set "UPDATE_VER=14.11.25325"
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

set "REDIST_ROOT=%BT_ROOT%\VC\Redist\MSVC\%UPDATE_VER%\onecore\%VC_PATH%"
robocopy "%REDIST_ROOT%\Microsoft.VC%VC_VER%.CRT" "%LIBRARY_BIN%" *.dll /E
if %ERRORLEVEL% LSS 8 exit 0
robocopy "%REDIST_ROOT%\Microsoft.VC%VC_VER%.CRT" "%PREFIX%" *.dll /E
if %ERRORLEVEL% LSS 8 exit 0
robocopy "%REDIST_ROOT%\Microsoft.VC%VC_VER%.OpenMP" "%LIBRARY_BIN%" *.dll /E
if %ERRORLEVEL% LSS 8 exit 0
robocopy "%REDIST_ROOT%\Microsoft.VC%VC_VER%.OpenMP" "%PREFIX%" *.dll /E
if %ERRORLEVEL% LSS 8 exit 0
