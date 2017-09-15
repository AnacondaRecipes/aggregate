robocopy . "%PREFIX%"\NSIS /S /XF bld.bat
if errorlevel 1 exit 1
robocopy . "%RECIPE_DIR%"\NSIS /S /XF bld.bat
if errorlevel 1 exit 1
