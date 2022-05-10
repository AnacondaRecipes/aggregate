@if not defined CONDA_PREFIX goto:eof

@setlocal enabledelayedexpansion
@call set "PATH=%%PATH:!CONDA_PREFIX!\NSIS;=%%"
@endlocal & set "PATH=%PATH%"
