mkdir "%PREFIX%\etc\conda\activate.d"
set "OUT_FN=%PREFIX%\etc\conda\activate.d\intel_fortran_compiler_vars_%cross_compiler_target_platform%.bat"

COPY "%RECIPE_DIR%\activate.bat" "%OUT_FN%"

IF "%cross_compiler_target_platform%" == "win-64" (
  set "intel_platform=intel64"
  ) else (
  set "intel_platform=ia32"
  )

echo SET "TARGET_PLATFORM=" >> "%OUT_FN%"
:: Folder layout changed between 2013 and 2016
IF %compiler_version:~0,4% GEQ 2016 (
   echo CALL "C:\Program Files (x86)\IntelSWTools\compilers_and_libraries_%compiler_version%\windows\bin\ipsxe-comp-vars.bat" %intel_platform% %%c_compiler%% >> "%OUT_FN%"
) ELSE (
  echo CALL "C:\Program Files (x86)\Intel\Composer XE 2013 SP1\bin\ipsxe-comp-vars.bat" %intel_platform% %%c_compiler%% >> "%OUT_FN%"
)
echo SET "TARGET_PLATFORM=%%target_platform%%" >> "%OUT_FN%"
