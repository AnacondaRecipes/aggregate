set MSYSTEM=MINGW%ARCH%
set MSYS2_PATH_TYPE=inherit
set CHERE_INVOKING=1

FOR /F "DELIMS=. TOKENS=4" %%i IN ("%PKG_VERSION%") DO set buildnum=%%i
:: This strange syntax outputs a line without a newline at the end
<nul set /p ".=BUILD_NUMBER=%buildnum%" > gradle\buildnumber.properties

call ./gradlew.bat build --stacktrace --info -x test

:: gradle keeps workers running. we need to kill them so that we can remove files.
call ./gradlew.bat --stop