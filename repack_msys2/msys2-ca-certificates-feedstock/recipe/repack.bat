echo "Building %PKG_NAME%"

@REM For subpackages, we have named our extracted locations according to the subpackage name
@REM That's what this %PKG_NAME% is doing - picking the right subfolder to copy

set src="%SRC_DIR%\%PKG_NAME%"

@REM activate.py will set the user's PATH to:
@REM
@REM (old) PREFIX/Library/mingw-w64/bin:PREFIX/Library/usr/bin:PREFIX/Library/bin:
@REM (new) PREFIX/Library/CONDA_MSYSTEM/bin:PREFIX/Library/usr/bin:PREFIX/Library/bin:

set dst="%PREFIX%\Library"
@REM %dst% already exists
md %dst%

del /f /q %src%\.BUILDINFO
del /f /q %src%\.MTREE
del /f /q %src%\.PKGINFO
@REM .PKGINFO should exist because we read it earlier and therefore
@REM something has gone badly wrong in the packaging if it is not here
@REM now
if errorlevel 1 exit %ERRORLEVEL%

@REM .INSTALL often doesn't exist
del /f /q %src%\.INSTALL

@REM robocopy will collect the mingw-64-* ucrt64/clang64/etc. directories as
@REM well as the msys2-* usr directory

robocopy /E /NFL /NDL /NP /NJH /NJS %src% %dst%
if %ERRORLEVEL% GEQ 8 exit 1

@set "SCRIPTS_DIR=%PREFIX%\Scripts"
if not exist %SCRIPTS_DIR% mkdir %SCRIPTS_DIR%
if errorlevel 1 exit /b %errorlevel%

copy "%RECIPE_DIR%\post-link.bat" "%SCRIPTS_DIR%\.msys2-ca-certificates-post-link.bat"
if errorlevel 1 exit /b %errorlevel%

