@if not defined CONDA_PREFIX goto:eof

@set "PATH=%CONDA_PREFIX%\NSIS;%PATH%"
