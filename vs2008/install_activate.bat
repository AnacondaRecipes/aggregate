set YEAR=2008
set VER=9

mkdir "%PREFIX%\etc\conda\activate.d"
COPY "%RECIPE_DIR%\activate.bat" "%PREFIX%\etc\conda\activate.d\vs%YEAR%_compiler_vars.bat"

IF "%cross_compiler_target_platform%" == "win-64" (
  set "target_platform=amd64"
  echo SET "CMAKE_GENERATOR=Visual Studio %VER% %YEAR% Win64" >> "%PREFIX%\etc\conda\activate.d\vs%YEAR%_compiler_vars.bat"
  ) else (
  set "target_platform=x86"
    echo SET "CMAKE_GENERATOR=Visual Studio %VER% %YEAR%" >> "%PREFIX%\etc\conda\activate.d\vs%YEAR%_compiler_vars.bat"
  )

echo CALL "%%VSINSTALLDIR%%\..\..\VC\vcvarsall.bat" %target_platform% >> "%PREFIX%\etc\conda\activate.d\vs%YEAR%_compiler_vars.bat"
echo set INCLUDE=%%INCLUDE%%;%%LIBRARY_INC%% >> "%PREFIX%\etc\conda\activate.d\vs%YEAR%_compiler_vars.bat"
echo set LIB=%%LIB%%;%%LIBRARY_LIB%% >> "%PREFIX%\etc\conda\activate.d\vs%YEAR%_compiler_vars.bat"
