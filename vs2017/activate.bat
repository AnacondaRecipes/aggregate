@echo on
:: Set env vars that tell distutils to use the compiler that we put on path
SET DISTUTILS_USE_SDK=1
SET MSSdk=1

SET "VS_VERSION=15.0"
SET "VS_MAJOR=15"
SET "VS_YEAR=2017"

set "MSYS2_ARG_CONV_EXCL=/AI;/AL;/OUT;/out"
set "MSYS2_ENV_CONV_EXCL=CL"

:: For Python 3.5+, ensure that we link with the dynamic runtime.  See
:: http://stevedower.id.au/blog/building-for-python-3-5-part-two/ for more info
set "PY_VCRUNTIME_REDIST=%PREFIX%\\bin\\vcruntime140.dll"

set "VSINSTALLDIR="
if exist "%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe" (
  for /f "usebackq tokens=*" %%i in (`"%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe" -nologo -products * -version ^[15.0^,16.0^) -property installationPath`) do (
    :: There is no trailing back-slash from the vswhere, and may make vcvars64.bat fail, so force add it
    set "VSINSTALLDIR=%%i\"
  )
)
if not exist "%VSINSTALLDIR%" (
set "VSINSTALLDIR=%ProgramFiles(x86)%\Microsoft Visual Studio\2017\Professional\"
)
if not exist "%VSINSTALLDIR%" (
set "VSINSTALLDIR=%ProgramFiles(x86)%\Microsoft Visual Studio\2017\Community\"
)
if not exist "%VSINSTALLDIR%" (
set "VSINSTALLDIR=%ProgramFiles(x86)%\Microsoft Visual Studio\2017\BuildTools\"
)
if not exist "%VSINSTALLDIR%" (
set "VSINSTALLDIR=%ProgramFiles(x86)%\Microsoft Visual Studio\2017\Enterprise\"
)

IF NOT "%CONDA_BUILD%" == "" (
  set "INCLUDE=%LIBRARY_INC%;%INCLUDE%"
  set "LIB=%LIBRARY_LIB%;%LIB%"
  set "CMAKE_PREFIX_PATH=%LIBRARY_PREFIX%;%CMAKE_PREFIX_PATH%"
)

:GetWin10SdkDir

call :GetWin10SdkDirHelper HKLM\SOFTWARE\Wow6432Node > nul 2>&1
if errorlevel 1 call :GetWin10SdkDirHelper HKCU\SOFTWARE\Wow6432Node > nul 2>&1
if errorlevel 1 call :GetWin10SdkDirHelper HKLM\SOFTWARE > nul 2>&1
if errorlevel 1 call :GetWin10SdkDirHelper HKCU\SOFTWARE > nul 2>&1
if errorlevel 1 exit /B 1
exit /B 0


:GetWin10SdkDirHelper

@REM `Get Windows 10 SDK installed folder`
for /F "tokens=1,2*" %%i in ('reg query "%1\Microsoft\Microsoft SDKs\Windows\v10.0" /v "InstallationFolder"') DO (
    if "%%i"=="InstallationFolder" (
        SET WindowsSdkDir=%%~k
    )
)

@REM `get windows 10 sdk version number`
setlocal enableDelayedExpansion

@REM `Due to the SDK installer changes beginning with the 10.0.15063.0 (RS2 SDK), there is a chance that the
@REM Windows SDK installed may not have the full set of bits required for all application scenarios.
@REM We check for the existence of a file we know to be included in the "App" and "Desktop" portions
@REM of the Windows SDK, depending on the Developer Command Prompt's -app_platform configuration.
@REM If "windows.h" (UWP) or "winsdkver.h" (Desktop) are not found, the directory will be skipped as
@REM a candidate default value for [WindowsSdkDir].`
set __check_file=winsdkver.h
if /I "%VSCMD_ARG_APP_PLAT%"=="UWP" set __check_file=Windows.h

if not "%WindowsSdkDir%"=="" for /f %%i IN ('dir "%WindowsSdkDir%include\" /b /ad-h /on') DO (
    @REM `Skip if Windows.h|winsdkver (based upon -app_platform configuration) is not found in %%i\um.`
    if EXIST "%WindowsSdkDir%include\%%i\um\%__check_file%" (
        set result=%%i
        if "!result:~0,3!"=="10." (
            set SDK=!result!
            if "!result!"=="%VSCMD_ARG_WINSDK%" set findSDK=1
        )
    )
)
exit /B 0

call :GetWin10SdkDirHelper
if errorlevel 1 (
    echo "Didn't find any windows 10 SDK. I'm not sure if things will work, but let's try..."
) else (
    echo Windows SDK dir found as: "%WindowsSDKDir%"
)

:: other things added by install_activate.bat at package build time
