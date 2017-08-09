:: Set env vars that tell distutils to use the compiler that we put on path
SET DISTUTILS_USE_SDK=1
SET MSSdk=1

:: http://stackoverflow.com/a/26874379/1170370
SET platform=
IF /I [%PROCESSOR_ARCHITECTURE%]==[amd64] set platform=true
IF /I [%PROCESSOR_ARCHITEW6432%]==[amd64] set platform=true

if defined platform (
set "VSREGKEY=HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\VisualStudio\9.0"
)  ELSE (
set "VSREGKEY=HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\VisualStudio\9.0"
)
for /f "skip=2 tokens=2,*" %%A in ('reg query "%VSREGKEY%" /v InstallDir') do SET "VSINSTALLDIR=%%B"

if not "%VSINSTALLDIR%" == "" (
   :: Look in VS90COMNTOOLS
   set "VSINSTALLDIR=%VS90COMNTOOLS%"
)

if "%VSINSTALLDIR%" == "" (
   ECHO "Did not find VS in registry or in VS90COMNTOOLS env var - exiting"
   exit 1
)

echo "Found VS2008 at"
echo "%VSINSTALLDIR%"

SET "VS_VERSION=9.0"
SET "VS_MAJOR=9"
SET "VS_YEAR=2008"

set "MSYS2_ARG_CONV_EXCL=/AI;/AL;/OUT;/out"
set "MSYS2_ENV_CONV_EXCL=CL"

:: other things added by install_activate.bat at package build time

