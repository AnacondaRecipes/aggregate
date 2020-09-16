:: This appears in the "About" dialog, but qmake is not good and I cannot
:: find any way to prevent it getting mangled (-DAnaconda -DBuild ...)
:: echo DEFINES += IDE_VERSION_DESCRIPTION=\"Anaconda Build %PKG_BUILDNUM%\" >> qtcreator.pri
echo on
qmake -r qbs.pro CONFIG+=release PREFIX=%PREFIX%\Library
jom
jom install INSTALL_ROOT=%PREFIX%\Library
if %ErrorLevel% neq 0 (
  echo "WARNING :: Install failed, this is probably due to qmake handling symlinks weirdly"
  echo "WARNING :: Ignoring"
  exit /b 0
)
