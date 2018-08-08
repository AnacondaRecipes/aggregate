#!/bin/bash

./getPlugins.sh
ant
mv out/artifacts/* ${PREFIX}
