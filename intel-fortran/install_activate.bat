mkdir "%PREFIX%\etc\conda\activate.d"
set "OUT_FN=%PREFIX%\etc\conda\activate.d\intel_fortran_compiler_vars_%cross_compiler_target_platform%.bat"

IF "%cross_compiler_target_platform%" == "win-64" (
  set "intel_platform=intel64"
  ) else (
  set "intel_platform=ia32"
  )

:: only pay attention to the year, everything is interleaved, seemingly
set PKG_VERSION=%PKG_VERSION:~0,4%

echo SET "TARGET_PLATFORM=" >> "%OUT_FN%"
echo CALL "C:\Program Files (x86)\IntelSWTools\compilers_and_libraries_%PKG_VERSION%\windows\bin\ifortvars.bat" %intel_platform% vs2015 >> "%OUT_FN%"
echo SET "TARGET_PLATFORM=%cross_compiler_target_platform%" >> "%OUT_FN%"
