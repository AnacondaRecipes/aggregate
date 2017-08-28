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

# There is a '--name-only' flag to 'git config', but no '--value-only' flag .. onward and awkward
wanted_branch=$(git config -f ${toplevel}/.gitmodules --get-regexp "^submodule\.${name}\.branch$" | awk '{ print $2 }')
if current_branch=$(git symbolic-ref --short -q HEAD); then
  if [[ ${current_branch} != ${wanted_branch} ]]; then
    git checkout -B ${wanted_branch} && git branch -u origin/${wanted_branch} && git pull --rebase
  else
    git branch -u origin/${wanted_branch} && git pull --rebase
  fi
else
  # Not on any branch, you may have detached commits though, but you may have commits in ${wanted_branch} too
  # .. TODO :: need to be careful with that.
  git checkout -B ${wanted_branch} && git branch -u origin/${wanted_branch} && git pull --rebase
fi
