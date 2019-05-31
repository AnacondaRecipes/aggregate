#!/bin/bash

# bash -x ./fetchDependencies

pushd External/VulkanSamples/Sample-Programs/Hologram
  ./generate-dispatch-table HelpersDispatchTable.h
  ./generate-dispatch-table HelpersDispatchTable.cpp
popd

make install
