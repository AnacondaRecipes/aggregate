#!/bin/bash

bazel build tensorflow_metadata:build_pip_package
bazel run tensorflow_metadata:build_pip_package
pip install --no-deps dist/*.whl
