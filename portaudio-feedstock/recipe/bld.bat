cmake -G"%CMAKE_GENERATOR%" ^
      -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
      -DCMAKE_BUILD_TYPE=Release ^
      -DTARGET_POSTFIX= ^
      .
cmake --build . --target ALL_BUILD --config Release
copy /y Release\*.dll %LIBRARY_BIN%
copy /y Release\*.lib %LIBRARY_LIB%
copy /y include\*.h %LIBRARY_INC%
