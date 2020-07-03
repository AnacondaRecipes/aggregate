@echo off
setlocal EnableDelayedExpansion

:: Try to find actual vs2017 installations
for /f "usebackq tokens=*" %%i in (`vswhere.exe -nologo -products * -version ^[15.0^,16.0^) -property installationPath`) do (
  :: There is no trailing back-slash from the vswhere, and may make vcvars64.bat fail, so force add it
  set "_VSINSTALLDIR=%%i\"
)

if not exist "!_VSINSTALLDIR!" (
    :: VS2019 install but with vs2017 compiler stuff installed
	for /f "usebackq tokens=*" %%i in (`vswhere.exe -nologo -products * -requires Microsoft.VisualStudio.Component.VC.v141.x86.x64 -property installationPath`) do (
	:: There is no trailing back-slash from the vswhere, and may make vcvars64.bat fail, so force add it
	set "_VSINSTALLDIR=%%i\"
	)
)

if not exist "!_VSINSTALLDIR!" (
  set "_VSINSTALLDIR=%ProgramFiles(x86)%\Microsoft Visual Studio\2017\Professional\"
)
if not exist "!_VSINSTALLDIR!" (
  set "_VSINSTALLDIR=%ProgramFiles(x86)%\Microsoft Visual Studio\2017\Community\"
)
if not exist "!_VSINSTALLDIR!" (
  set "_VSINSTALLDIR=%ProgramFiles(x86)%\Microsoft Visual Studio\2017\BuildTools\"
)
if not exist "!_VSINSTALLDIR!" (
  echo Did not find VSINSTALLDIR
  exit /B 1
)

:: We can either do
:: echo !_VSINSTALLDIR!
:: .. then on the other side:
::  for /f "usebackq tokens=*" %%i in (`CALL %~dp0vs@YEAR@_get_vsinstall_dir.bat`) do (
::    There is no trailing back-slash from the vswhere, and may make vcvars64.bat fail, so force add it
::    set "VSINSTALLDIR=%%i"
::  )

:: .. but this is fine too
for /F "delims=" %%i in ("!_VSINSTALLDIR!") do (
  endlocal
  set "VSINSTALLDIR=%%i"
)
:: .. then on the other side, just
::   CALL %~dp0vs@YEAR@_get_vsinstall_dir.bat
