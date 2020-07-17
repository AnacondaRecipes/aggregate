@echo on
%LIBRARY_BIN%\bazel build -c opt //tree:_tree

python setup.py install
