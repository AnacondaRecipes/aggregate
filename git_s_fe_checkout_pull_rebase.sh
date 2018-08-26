#!/usr/bin/env bash

# Run this as:
# git submodule foreach '$toplevel/git_s_fe_checkout_pull_rebase.sh $name $path $sha1 $toplevel'

name=$1; shift
path=$1; shift
sha1=$1; shift
toplevel=$1; shift

echo name = ${name}
echo path = ${path}
echo sha1 = ${sha1}
echo toplevel = ${toplevel}

git checkout -p .
