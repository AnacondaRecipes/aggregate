echo [options]                      > %SRC_DIR%\site.cfg
echo embedded = False              >> %SRC_DIR%\site.cfg
echo threadsafe = True             >> %SRC_DIR%\site.cfg
echo static = False                >> %SRC_DIR%\site.cfg
echo connector = %LIBRARY_PREFIX%  >> %SRC_DIR%\site.cfg

type %LIBRARY_INC%\my_config.h > %LIBRARY_INC%\config-win.h

%PYTHON% setup.py install --single-version-externally-managed --record=record.txt
