#!/bin/bash

# nb_conda_kernels
$PYTHON -m nb_conda_kernels.install --enable --prefix $PREFIX

# nb_conda
jupyter-nbextension enable nb_conda --py --sys-prefix
jupyter-serverextension enable nb_conda --py --sys-prefix

# nbpresent
jupyter-nbextension enable nbpresent --py --sys-prefix
jupyter-serverextension enable nbpresent --py --sys-prefix

# nb_anacondacloud
jupyter-nbextension enable nb_anacondacloud --py --sys-prefix
jupyter-serverextension enable nb_anacondacloud --py --sys-prefix

# ipywidgets
jupyter-nbextension enable widgetsnbextension --py --sys-prefix

# jupyterlab
jupyter-serverextension enable jupyterlab --py --sys-prefix
