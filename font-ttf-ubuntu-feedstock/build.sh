#!/bin/bash

mkdir -p ${PREFIX}/fonts || true
install -m644 *.ttf ${PREFIX}/fonts/
