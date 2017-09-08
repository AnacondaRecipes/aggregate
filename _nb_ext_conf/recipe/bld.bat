:: nb_conda_kernels
%PYTHON% -m nb_conda_kernels.install --enable --prefix %PREFIX%
if errorlevel 1 exit 1

:: nb_conda
jupyter-nbextension enable nb_conda --py --sys-prefix
if errorlevel 1 exit 1
jupyter-serverextension enable nb_conda --py --sys-prefix
if errorlevel 1 exit 1

:: nbpresent
jupyter-nbextension enable nbpresent --py --sys-prefix
if errorlevel 1 exit 1
jupyter-serverextension enable nbpresent --py --sys-prefix
if errorlevel 1 exit 1

:: nb_anacondacloud
jupyter-nbextension enable nb_anacondacloud --py --sys-prefix
if errorlevel 1 exit 1
jupyter-serverextension enable nb_anacondacloud --py --sys-prefix
if errorlevel 1 exit 1

:: ipywidgets
jupyter-nbextension enable widgetsnbextension --py --sys-prefix
if errorlevel 1 exit 1

:: ensure we don't ship any pyc's
rd /s /q %SP_DIR%
