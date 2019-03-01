set YEAR=2015
set VER=14

mkdir "%PREFIX%\etc\conda\activate.d"
COPY "%RECIPE_DIR%\activate.bat" "%PREFIX%\etc\conda\activate.d\vs%YEAR%_compiler_vars.bat"

echo if "%%VC140_ON_VS2017%%" == "" ( >> "%PREFIX%\etc\conda\activate.d\vs%YEAR%_compiler_vars.bat"

IF "%cross_compiler_target_platform%" == "win-64" (
  echo SET "CMAKE_GENERATOR=Visual Studio 15 2017 Win64" -T "v140" >> "%PREFIX%\etc\conda\activate.d\vs%YEAR%_compiler_vars.bat"
  echo CALL "%%VSINSTALLDIR%%..\..\VC\vcvarsall.bat" x64 -vcvars_ver=14.0 >> "%PREFIX%\etc\conda\activate.d\vs%YEAR%_compiler_vars.bat"
  ) else (
  echo SET "CMAKE_GENERATOR=Visual Studio 15 2017" -T "v140" >> "%PREFIX%\etc\conda\activate.d\vs%YEAR%_compiler_vars.bat"
  echo CALL "%%VSINSTALLDIR%%..\..\VC\vcvarsall.bat" x86 -vcvars_ver=14.0 >> "%PREFIX%\etc\conda\activate.d\vs%YEAR%_compiler_vars.bat"
  )

echo ) else ( >> "%PREFIX%\etc\conda\activate.d\vs%YEAR%_compiler_vars.bat"

IF "%cross_compiler_target_platform%" == "win-64" (
  set "target_platform=amd64"
  echo SET "CMAKE_GENERATOR=Visual Studio %VER% %YEAR% Win64" >> "%PREFIX%\etc\conda\activate.d\vs%YEAR%_compiler_vars.bat"
  ) else (
  set "target_platform=x86"
    echo SET "CMAKE_GENERATOR=Visual Studio %VER% %YEAR%" >> "%PREFIX%\etc\conda\activate.d\vs%YEAR%_compiler_vars.bat"
  )

echo CALL "%%VSINSTALLDIR%%..\..\VC\vcvarsall.bat" %target_platform% >> "%PREFIX%\etc\conda\activate.d\vs%YEAR%_compiler_vars.bat"

echo ) >> "%PREFIX%\etc\conda\activate.d\vs%YEAR%_compiler_vars.bat"
