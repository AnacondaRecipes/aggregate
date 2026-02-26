@echo off

cd python
set CTRANSLATE2_ROOT=%LIBRARY_PREFIX%
%PYTHON% -m pip install . --no-deps --no-build-isolation -vv
if errorlevel 1 exit 1
