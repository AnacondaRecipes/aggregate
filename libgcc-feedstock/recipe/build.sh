#!/bin/bash

if [[ $(uname) == Linux ]]; then
  ln -s ${PREFIX}/lib/libstdc++.so.6.0.24 ${PREFIX}/lib/libstdc++.so.6.0.21
fi
