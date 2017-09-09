#!/bin/bash

# ipywidgets
jupyter-nbextension enable widgetsnbextension --py --sys-prefix

# jupyterlab
jupyter-serverextension enable jupyterlab --py --sys-prefix
