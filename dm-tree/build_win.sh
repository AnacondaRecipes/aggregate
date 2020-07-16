${LIBRARY_BIN}/bazel build -c opt //tree:_tree || exit $?

PY_TEST_DIR="py_test_dir"
rm -fr ${PY_TEST_DIR}
mkdir -p ${PY_TEST_DIR}
cmd /c "mklink /J ${PY_TEST_DIR}\\tree .\\tree"

./bazel-bin/tree/tools/pip_package/build_pip_package "$PWD/${PY_TEST_DIR}"

PIP_NAME=$(ls ${PY_TEST_DIR}/tree-*.whl)
pip install ${PIP_NAME} --no-deps