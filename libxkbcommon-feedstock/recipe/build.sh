#!/usr/bin/env bash

meson setup build                             \
  --prefix ${PREFIX}                          \
  --libdir lib                                \
  -Denable-x11=false                          \
  -Denable-wayland=false                      \
  -Denable-docs=false                         \
  -Dxkb-config-root=${PREFIX}/share/X11/xkb   \
  -Dx-locale-root=${PREFIX}/share/X11/locale

ninja -C build
ninja -C build install
