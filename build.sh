#!/usr/bin/env bash

A build-out for all Pythons for linux-ppc64le should be done via:
/opt/conda/bin/conda index /opt/conda/conda-bld/linux-ppc64le ; 
CONDA_ADD_PIP_AS_PYTHON_DEPENDENCY=0 \
  conda-build $(cat python-order.txt | \
    sed '/^cython-feedstock/,$!d' | \
    grep -v '# \[not ppc\]' | \
    sed 's/\s.*$//' | \
    tr '\n' ' ') -c local -c https://repo.anaconda.com/pkgs/main --skip-existing --error-overlinking 2>&1 | tee -a ~/conda/python-3.7.0-all-build-out.log
