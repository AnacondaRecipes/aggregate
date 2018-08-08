#!/bin/bash

# Remove old RStudio.app if it exists
rm -rf "${PREFIX}"/Applications/"Qt Creator.app" > /dev/null 2>&1 || true

[ -d "${PREFIX}"/Applications ] || mkdir -p "${PREFIX}"/Applications > /dev/null 2>%1

# Copy new one
cp -r "${PREFIX}"/qtcreatorapp "${PREFIX}"/Applications/"Qt Creator.app"

# Make a symlink. I used a shell script initially, but the icon changes to a default one
# very soon after launching for some reason (or at least it did in RStudio, but this could
# be due to the Dock icon changing code in RStudio itself, I am not sure..)
mkdir -p "${PREFIX}"/Applications/"Qt Creator.app"/Contents/MacOS
cd "${PREFIX}"/Applications/"Qt Creator.app"/Contents/MacOS
ln -s ../../../../bin/qtcreator qtcreator
cd ../../..

# Update Apple's cached information
/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -v -f "Qt Creator.app"

cd ..

rm -rf "${PREFIX}"/qtcreatorapp
