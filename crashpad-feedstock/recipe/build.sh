#!/usr/bin/env bash

declare -gA _system_libs=(
  [ffmpeg]=ffmpeg
  [flac]=flac
  [fontconfig]=fontconfig
  [freetype]=freetype2
  [harfbuzz-ng]=harfbuzz
  [icu]=icu
  [libdrm]=
  [libevent]=libevent
  [libjpeg]=libjpeg
  #[libpng]=libpng            # https://crbug.com/752403#c10
  [libvpx]=libvpx
  [libwebp]=libwebp
  [libxml]=libxml2
  [libxslt]=libxslt
  [opus]=opus
  [re2]=re2
  [snappy]=snappy
  [yasm]=
  [zlib]=minizip
)
_unwanted_bundled_libs=(
  ${!_system_libs[@]}
  ${_system_libs[libjpeg]+libjpeg_turbo}
)

PATH="${BUILD_PREFIX}/depot_tools:${PATH}"

python ${RECIPE_DIR}/replace_gn_files.py \
  --system-libraries "${!_system_libs[@]}"

git checkout -B master
find ${BUILD_PREFIX}/depot_tools | grep gclient
git pull -r

echo "LIZZY1"

${BUILD_PREFIX}/depot_tools/gclient config https://chromium.googlesource.com/crashpad/crashpad

echo "LIZZY2"

${BUILD_PREFIX}/depot_tools/gclient sync

echo "LIZZY3"

# find . | sort | tee files1
gn args out/Default --list

echo "LIZZY4"

gn gen out/Default

echo "LIZZY5"

ninja -C out/Default
find . | sort | tee files2
diff -urN files1 files2
