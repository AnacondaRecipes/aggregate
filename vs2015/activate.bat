:: Set env vars that tell distutils to use the compiler that we put on path
SET DISTUTILS_USE_SDK=1
:: This is probably not good. It is for the pre-UCRT msvccompiler.py *not* _msvccompiler.py
SET MSSdk=1

:: http://stackoverflow.com/a/26874379/1170370
SET platform=
IF /I [%PROCESSOR_ARCHITECTURE%]==[amd64] set "platform=true"
IF /I [%PROCESSOR_ARCHITEW6432%]==[amd64] set "platform=true"

if defined platform (
set "VSREGKEY=HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\VisualStudio\14.0"
)  ELSE (
set "VSREGKEY=HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\VisualStudio\14.0"
)
for /f "skip=2 tokens=2,*" %%A in ('reg query "%VSREGKEY%" /v InstallDir') do SET "VSINSTALLDIR=%%B"

if not "%VSINSTALLDIR%" == "" (
   set "VSINSTALLDIR=%VS140COMNTOOLS%"
)

if "%VSINSTALLDIR%" == "" (
   ECHO "Did not find VS in registry or in VS140COMNTOOLS env var - exiting"
   exit 1
)

echo "Found VS2014 at %VSINSTALLDIR%"

SET "VS_VERSION=14.0"
SET "VS_MAJOR=14"
SET "VS_YEAR=2015"

set "MSYS2_ARG_CONV_EXCL=/AI;/AL;/OUT;/out"
set "MSYS2_ENV_CONV_EXCL=CL"

:: For Python 3.5+, ensure that we link with the dynamic runtime.  See
:: http://stevedower.id.au/blog/building-for-python-3-5-part-two/ for more info
set "PY_VCRUNTIME_REDIST=%PREFIX%\vcruntime140.dll"

:: ensure that we use the DLL part of the ucrt
set "CFLAGS=%CFLAGS% -MD -GL"
set "CXXFLAGS=%CXXFLAGS% -MD -GL"
set "LDFLAGS_SHARED=%LDFLAGS_SHARED% -LTCG ucrt.lib"

:: other things added by install_activate.bat at package build time
