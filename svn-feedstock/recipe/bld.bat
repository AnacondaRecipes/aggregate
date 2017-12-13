if "%ARCH%"=="32" (
   set "PLATFORM=Win32"
) else (
  set "PLATFORM=x64"
)

python gen-make.py -t vcproj --vsnet-version=%VS_YEAR% ^
             --with-openssl=%LIBRARY_PREFIX% ^
             --with-zlib=%LIBRARY_PREFIX% ^
             --with-apr=%LIBRARY_PREFIX% ^
             --with-apr-util=%LIBRARY_PREFIX% ^
             --with-apr-iconv=%LIBRARY_PREFIX% ^
             --with-sqlite=%LIBRARY_PREFIX% ^
             --with-serf=%LIBRARY_INC% ^
             --release

msbuild subversion_vcnet.sln /t:__ALL_TESTS__ /p:Configuration=Release /p:Platform=%PLATFORM%

pushd Release\subversion

FOR /D %%D in (.\*svn*) do (
    pushd %%D
    for %%F in (.\*.exe) do MOVE %%F %LIBRARY_BIN%\
    for %%F in (.\*.dll) do MOVE %%F %LIBRARY_BIN%\
    for %%F in (.\*.lib) do MOVE %%F %LIBRARY_LIB%\
    popd
)

popd
