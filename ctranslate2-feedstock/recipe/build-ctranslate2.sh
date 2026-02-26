#!/bin/bash
set -ex

cd python
export CTRANSLATE2_ROOT=$PREFIX
$PYTHON -m pip install . --no-deps --no-build-isolation -vv
