set YEAR=2017
set VER=15

mkdir "%PREFIX%\etc\conda\activate.d"
COPY "%RECIPE_DIR%\activate.bat" "%PREFIX%\etc\conda\activate.d\vs%YEAR%_compiler_vars.bat"

IF "%cross_compiler_target_platform%" == "win-64" (
  set "target_platform=amd64"
  set "CMAKE_GENERATOR=Visual Studio %VER% %YEAR% Win64"
  set "BITS=64"
) else (
  set "target_platform=x86"
  set "CMAKE_GENERATOR=Visual Studio %VER% %YEAR%"
  set "BITS=32"
)

echo pushd "%%VSINSTALLDIR%%" >> "%PREFIX%\etc\conda\activate.d\vs%YEAR%_compiler_vars.bat"
echo CALL "VC\Auxiliary\Build\vcvars%BITS%.bat" >> "%PREFIX%\etc\conda\activate.d\vs%YEAR%_compiler_vars.bat"
echo popd >> "%PREFIX%\etc\conda\activate.d\vs%YEAR%_compiler_vars.bat"

echo IF "%%CMAKE_GENERATOR%%" == "" ( >> "%PREFIX%\etc\conda\activate.d\vs%YEAR%_compiler_vars.bat"
echo SET "CMAKE_GENERATOR=%CMAKE_GENERATOR%" >> "%PREFIX%\etc\conda\activate.d\vs%YEAR%_compiler_vars.bat"
echo ) >> "%PREFIX%\etc\conda\activate.d\vs%YEAR%_compiler_vars.bat"
