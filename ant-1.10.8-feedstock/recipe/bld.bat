@echo on
rem set JAVA_HOME=%LIBRARY_PREFIX%
set ANT_HOME=.\build
call build.bat install-lite
if errorlevel 1 exit 1

cd build

xcopy /f /s /y /i bin\* %LIBRARY_BIN%
xcopy /f /s /y /i etc %LIBRARY_PREFIX%\etc
xcopy /f /s /y /i lib\* %LIBRARY_LIB%

:: ensure that ANT_HOME is set correctly
mkdir %PREFIX%\etc\conda\activate.d
echo set "ANT_HOME_CONDA_BACKUP=%%ANT_HOME%%" > "%PREFIX%\etc\conda\activate.d\ant_home.bat"
echo set "ANT_HOME=%%CONDA_PREFIX%%\Library" >> "%PREFIX%\etc\conda\activate.d\ant_home.bat"
mkdir %PREFIX%\etc\conda\deactivate.d
echo set "ANT_HOME=%%ANT_HOME_CONDA_BACKUP%%" > "%PREFIX%\etc\conda\deactivate.d\ant_home.bat
