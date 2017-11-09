robocopy cmake-bin %PREFIX%\cmake-bin /E

mkdir %PREFIX%\etc\conda\activate.d
echo set "PATH=%%PATH%%;%PREFIX%\cmake-bin\bin" > %PREFIX%\etc\conda\activate.d\cmake-bin.bat
mkdir %PREFIX%\etc\conda\deactivate.d
echo set "PATH=%%PATH:%PREFIX%\cmake-bin\bin=%%" > %PREFIX%\etc\conda\deactivate.d\cmake-bin.bat

exit /b 0