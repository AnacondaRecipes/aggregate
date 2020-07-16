@echo on

set MSYSTEM=MINGW%ARCH%
set MSYS2_PATH_TYPE=inherit
set CHERE_INVOKING=1


bash -lc "%RECIPE_DIR%"/build_win.sh
if errorlevel 1 exit 1