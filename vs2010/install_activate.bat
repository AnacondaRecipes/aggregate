set YEAR=2010
set VER=10

mkdir "%PREFIX%\etc\conda\activate.d"
COPY "%RECIPE_DIR%\activate.bat" "%PREFIX%\etc\conda\activate.d\vs%YEAR%_compiler_vars.bat"


if "%ARCH%" == "64" (
    :: 64-bit
    echo SET "CMAKE_GENERATOR=Visual Studio %VER% %YEAR% Win64" >> "%PREFIX%\etc\conda\activate.d\vs%YEAR%_compiler_vars.bat"
) else (
    :: 32-bit
    echo SET "CMAKE_GENERATOR=Visual Studio %VER% %YEAR%" >> "%PREFIX%\etc\conda\activate.d\vs%YEAR%_compiler_vars.bat"
)

IF "%target_platform%" == "win-64" (
  set "target_platform=amd64"
  ) else (
  set "target_platform=x86"
  )

echo CALL "%%VSINSTALLDIR%%\..\..\VC\vcvarsall.bat" %target_platform% >> "%PREFIX%\etc\conda\activate.d\vs%YEAR%_compiler_vars.bat"
