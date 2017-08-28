#!/usr/bin/env bash

# Run this as:
# git submodule foreach '$toplevel/git_s_fe_add_all_commit_rebase_push.sh $name $path $sha1 $toplevel ["Commit message"] [-F "commit_msg.txt"]'

name=$1; shift
path=$1; shift
sha1=$1; shift
toplevel=$1; shift

git diff-files --quiet --ignore-submodules -- || changes_in_files=1
git diff-index --cached --quiet HEAD --ignore-submodules -- || changes_in_index=1

if [[ ${changes_in_files} != 1 ]] && [[ ${changes_in_index} != 1 ]]; then
  exit 0
fi

echo "Changes in $name"

# There is a '--name-only' flag to 'git config', but no '--value-only' flag .. onward and awkward
wanted_branch=$(git config -f ${toplevel}/.gitmodules --get-regexp "^submodule\.${name}\.branch$" | awk '{ print $2 }')
if ! git rev-parse --verify refs/heads/${wanted_branch}; then
  git checkout -b ${wanted_branch} --track origin/${wanted_branch}
fi

current_branch=$(git rev-parse --abbrev-ref HEAD)
if [[ ${current_branch} != ${wanted_branch} ]]; then
  git checkout ${wanted_branch}
fi

from_file=$1; shift
if [[ ${from_file} == -F ]]; then
  git commit -a -F "$@"
else
  git commit -a -m "${from_file} $@"
fi

git fetch origin
if git rebase origin/${wanted_branch}; then
  git push origin ${wanted_branch}:${wanted_branch}
fi
