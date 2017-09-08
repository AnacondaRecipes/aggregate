:: ipywidgets
jupyter-nbextension enable widgetsnbextension --py --sys-prefix
if errorlevel 1 exit 1

:: jupyterlab
jupyter-serverextension enable jupyterlab --py --sys-prefix
if errorlevel 1 exit 1

:: ensure we don't ship any pyc's
rd /s /q %SP_DIR%
