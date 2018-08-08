#!/usr/bin/env bash

# Run this as:
# git submodule foreach '$toplevel/git_s_fe_check_fix_status.sh $name $path $sha1 $toplevel <--dry-run>'

name=$1; shift
path=$1; shift
sha1_super=$1; shift
toplevel=$1; shift
dryrun=$1; shift
if [[ ${dryrun} == --dry-run ]]; then
  dryrun=yes
elif [[ -z ${dryrun} ]]; then
  dryrun=no
else
  echo "ERROR :: Unknown command: ${dryrun}, did you mean to pass: --dry-run"
  exit 1
fi

sha1_h=$(git rev-parse HEAD)

function anc_print() {
  if git merge-base --is-ancestor $1 $2; then
    echo "1"
  else
    echo "0"
  fi
}

function maybe_do() {
  if [[ ${dry_run} == yes ]]; then
    echo "DRYRUN: $*"
  else
    $*
  fi
}

function git_dirty {
  [[ $(git diff --shortstat 2> /dev/null | tail -n1) != "" ]] && echo "1"
  echo 0
}

function git_num_untracked_files {
  expr echo $(git status --porcelain 2>/dev/null| grep "^??" | wc -l)
}

function git_num_added_to_index {
  expr $(git status --porcelain 2>/dev/null| grep "^M" | wc -l)
}

set -x
SUCCESS=0
# DEBUG=yes
if [[ $name == dbus-feedstock-no ]]; then
  DEBUG=yes
fi

if [[ ${DEBUG} == yes ]]; then
  SUCCESS=1
#  set -x
fi

# There is a '--name-only' flag to 'git config', but no '--value-only' flag .. onward and awkward
wanted_branch=$(git config -f ${toplevel}/.gitmodules --get-regexp "^submodule\.${name}\.branch$" | awk '{ print $2 }')
if [[ ! ${wanted_branch} ]]; then
  echo "FATAL: Could not detemine branch for ${name}, please fix .gitmodules"
  exit 1
fi

# We have sha1s for each of HEAD, master (really wanted) and other
sha1_m=$(git rev-parse ${wanted_branch})
sha1_o=$(git rev-parse origin/${wanted_branch})

if [[ ${DEBUG} == yes ]]; then
  echo name = ${name}
  echo path = ${path}
  echo sha1_super = ${sha1_super}
  echo sha1_HEAD = ${sha1_h}
  echo sha1_${wanted_branch} = ${sha1_m}
  echo sha1_origin/${wanted_branch} = ${sha1_o}
  echo toplevel = ${toplevel}
fi

on_wanted=no
if current_branch=$(git symbolic-ref --short -q HEAD); then
  if [[ ${current_branch} != ${wanted_branch} ]]; then
    echo "${name} not on wanted branch: ${wanted_branch}"
    maybe_do git checkout ${wanted_branch}
    [[ ${dryrun} == no ]] && current_branch=wanted_branch
    [[ ${dryrun} == no ]] && on_wanted=yes
    maybe_do git branch -u origin/${wanted_branch}
    maybe_do git pull --rebase
  else
    on_wanted=yes
  fi
fi

if [[ ! ${current_branch} ]]; then
  echo "${name} not on any branch, wanted branch: ${wanted_branch}"
fi

if [[ ${sha1_h} == ${sha1_m} ]] && [[ ${sha1_h} == ${sha1_o} ]]; then
  # Simple case, maybe checkout ${wanted_branch} and move on
  if [[ ${on_wanted} == no ]]; then
    maybe_do git checkout ${wanted_branch}
  fi
  echo SUCCESS=$SUCCESS
  exit ${SUCCESS}
fi

h_anc_m=$(anc_print ${sha1_h} ${sha1_m})
h_anc_o=$(anc_print ${sha1_h} ${sha1_o})
m_anc_h=$(anc_print ${sha1_m} ${sha1_h})
m_anc_o=$(anc_print ${sha1_m} ${sha1_o})
o_anc_m=$(anc_print ${sha1_o} ${sha1_m})
o_anc_h=$(anc_print ${sha1_o} ${sha1_h})

if [[ ${DEBUG} == yes ]]; then
  spaces="                          "
  echo "          sha1_h: ${sha1_h}     sha1_m: ${sha1_m}    sha1_o: ${sha1_o}"
  echo "is_anc of:"
  echo "sha1_h: ${spaces}1${spaces}${spaces}${m_anc_h}${spaces}${spaces}${o_anc_h}"
  echo "sha1_m: ${spaces}${h_anc_m}${spaces}${spaces}1${spaces}${spaces}${o_anc_m}"
  echo "sha1_o: ${spaces}${h_anc_o}${spaces}${spaces}${m_anc_o}${spaces}${spaces}1"
fi

# There are 4 stages to worry about and they need to be progressed in that order
# 1. Local uncommitted changes   => commit them to HEAD
# 2. Committed changes to HEAD   => get master to agree
# 3. Agreement b/ HEAD, master   => get origin to agree
# 4. Agreement b/ master, origin => all done

# Agreement between the branches, but HEAD differs.
if [[ ${sha1_m} == ${sha_o} ]]; then
  # If HEAD is an ancestor of (both of) the branches ..
  if ${h_anc_m}; then
    echo "${name} HEAD is an ancestor of origin/${wanted_branch} (which is equal to ${wanted_branch}), I suggest you: git checkout ${wanted_branch}"
    exit ${SUCCESS}
  else
    echo "${name} HEAD is *not* an ancestor of origin/${wanted_branch} (which is equal to ${wanted_branch}), your branches have diverged. Please manually rectify this"
    exit 1
  fi
fi

if [[ ${sha1_h} == ${sha1_o} ]]; then
  # HEAD is equal to origin ..
  if [[ ${m_anc_o} ]]; then
    # .. and master is an ancestor of these
    if [[ ${on_wanted} == no ]]; then
      maybe_do git checkout ${wanted_branch}
      [[ ${dryrun} == no ]] && on_wanted=yes
    fi
    maybe_do git branch -u origin/${wanted_branch}
    maybe_do git pull --rebase
    exit ${SUCCESS}
  fi
fi

# Suggestions only after this point.
if [[ ${on_wanted} == no ]]; then
  echo "# ${name} :: You are not on the wanted branch, I suggest you:"
  echo "pushd ${name} && git checkout ${wanted_branch} && popd"
fi
if [[ ${o_anc_m} == 1 ]] && [[ ${sha1_o} != ${sha1_m} ]]; then
  echo "# ${name} :: Your local ${wanted_branch} has new commits, I suggest you:"
  echo "pushd ${name} && git checkout ${wanted_branch} && git push origin/${wanted_branch} && popd"
  exit ${SUCCESS}
elif [[ ${m_anc_o} == 1 ]] && [[ ${sha1_m} != ${sha1_o} ]]; then
  echo "# ${name} :: Your local ${wanted_branch} is behind origin/${wanted_branch}, I suggest you:"
  echo "pushd ${name} && git checkout ${wanted_branch} && git pull --rebase origin/${wanted_branch} && popd"
  exit ${SUCCESS}
elif [[ ${m_anc_o} == 0 ]]; then
  echo "# ${name} :: Your local ${wanted_branch} is *not* an ancestor of origin/${wanted_branch}, has origin/${wanted_branch} been rebased? I suggest you:"
  echo "pushd ${name} && git reset ${wanted_branch} origin/${wanted_branch} && popd"
  exit ${SUCCESS}
fi
echo "${name} :: We should not get to here"
exit 0
