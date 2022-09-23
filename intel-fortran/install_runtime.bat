COPY %RECIPE_DIR%\LICENSE.txt LICENSE.txt

IF %compiler_version:~0,4% GEQ 2022 (
    set "INSTALLDIR=C:\Program Files (x86)\Intel\oneAPI\compiler\%compiler_version%\windows\"
    set "SUFFIX=_win"
) else (
    IF %compiler_version:~0,4% GEQ 2016 (
        set "INSTALLDIR=C:\Program Files (x86)\IntelSWTools\compilers_and_libraries_%compiler_version%\windows\"
    ) else (
        set "INSTALLDIR=C:\Program Files (x86)\Intel\Composer XE 2013 SP1\"
    )
    set "SUFFIX="
)

IF "%target_platform%" == "win-64" (
  set "intel_platform=intel64"
  ) else (
  set "intel_platform=ia32"
  )

robocopy "%INSTALLDIR%\redist\%intel_platform%%SUFFIX%\compiler" "%LIBRARY_BIN%" *.dll /E
if %ERRORLEVEL% GEQ 8 exit 1
IF EXIST %LIBRARY_BIN%\irml\irml_debug.dll DEL %LIBRARY_BIN%\irml\irml_debug.dll
IF EXIST %LIBRARY_BIN%\irml_c\irml_debug.dll DEL %LIBRARY_BIN%\irml_c\irml_debug.dll
IF EXIST %LIBRARY_BIN%\libifcoremdd.dll DEL %LIBRARY_BIN%\libifcoremdd.dll
IF EXIST %LIBRARY_BIN%\libifcorertd.dll DEL %LIBRARY_BIN%\libifcorertd.dll
IF EXIST %LIBRARY_BIN%\libmmdd.dll DEL %LIBRARY_BIN%\libmmdd.dll
DEL %LIBRARY_BIN%\*.pdb
DEL %LIBRARY_BIN%\*.msm

:: openmp is left for another package
DEL %LIBRARY_BIN%\libiomp*

exit 0
