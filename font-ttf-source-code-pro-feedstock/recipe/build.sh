#!/bin/bash

mkdir -p ${PREFIX}/fonts || true
install -m644 TTF/*.ttf ${PREFIX}/fonts/
