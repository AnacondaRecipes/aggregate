#!/bin/bash

# Debugging
# set -x

### ----------------------------------------------------------------------
txtred='\033[0;31m'       # red
bldred='\033[1;31m'       # red bold
txtgrn='\033[0;32m'       # green
bldgrn='\033[1;32m'       # green bold
txtyel='\033[0;33m'       # yellow
bldyel='\033[1;33m'       # yellow bold
txtrst='\033[0m'          # Text reset

# ------------------------------
# regex
SUBMODULE_REGEX_STATUS="([\+-uU[:space:]])([^[:space:]]*) ([^[:space:]]*)( ([^[:space:]]*))?"
SUBMODULE_REGEX_MODULE="\[submodule \"(.*)\"\]"
GIT_REGEX_DIFF_COMMIT=".*commit (.*)"

# ------------------------------
print_error() {
  echo -e "${bldred}$1${txtrst}"
}

# ------------------------------
print_success() {
  echo -e "${bldgrn}$1${txtrst}"
}

# ------------------------------
print_warning() {
  echo -e "${bldyel}$1${txtrst}"
}

# ------------------------------
print_warning_with_title() {
  echo -e "${txtyel}$1: ${bldyel}$2${txtrst}"
}

# ------------------------------
parse_git_branch() {
  git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'
}

# ------------------------------
find_submodule_remote_ref() {
  local l_remote_ref=`git rev-parse --remotes=*$1`
  echo ${l_remote_ref}
  return 0
}

# ------------------------------
# $1 = path
find_submodule_commit_hash() {
  local l_br=`git diff HEAD -- $1 | sed '1,6 d'` # too specific?
  if [[ ${l_br} =~ $GIT_REGEX_DIFF_COMMIT ]]; then
    # return commit HASH
    echo ${BASH_REMATCH[1]}
    return 0
  fi
  return -1
}

# ------------------------------
# $1 = hash
# $2 = path
#
check_submodule_is_pushed() {
  # need to find the path for this module
  local l_hash=$1
  local l_path=$2

  done_processing=
  while read line
  do
    if [[ "$line" =~ $SUBMODULE_REGEX_MODULE ]]; then
      if [[ ${BASH_REMATCH[1]} == ${l_path} ]]; then
        diffed_submodule=`find_submodule_commit_hash ${l_path}`
        if [[ "$?" -eq 0 ]]; then
          pushd . > /dev/null
          # echo "let's go to submodule folder... [${BASH_REMATCH[1]}]"
          cd ${BASH_REMATCH[1]}
          local l_branch=$(parse_git_branch)
          # echo "BRANCH is <<${l_branch}>>"
          local l_remote_ref=$(find_submodule_remote_ref ${l_branch})
          # echo "remote REF is <<${l_remote_ref}>>"
          popd > /dev/null

          # finally!!!!!
          if [[ $l_hash == $l_remote_ref ]]; then
            print_success "All is good with this submodule..."
            return 0
          else
            echo " "
            print_error "Stop! Pre-commit condition failed."
            echo "Did you forget to push submodule [$l_path] to remote?"
            echo "Cannot proceed until you do so."
            print_warning_with_title "Remote HASH" ${l_remote_ref}
            print_warning_with_title "Local HASH." ${l_hash}
            echo " "
            return -1
          fi
        # else
          # should we just skip instead of break?
          # print_error ">> [$l_path] - No commit HASH found..."
          # return -1
          # noop
        fi
      fi
    # else
      # print_error "NOT submodule line... continue"
      # return -1
    fi
  done < ${SUBMODULE_CONFIG_FILE}

  if [[ -z done_processing ]]; then
    print_error ">> Could not process submodule..."
    return -1  #signal error
  fi
}

### ----------------------------------------------------------------------
### MAIN
### ----------------------------------------------------------------------

PROJECT_ROOT=`git rev-parse --git-dir`/..
# echo "root is ${PROJECT_ROOT}"

# ------------------------------
# exit if nothing to do here...
SUBMODULE_CONFIG_FILE=${PROJECT_ROOT}/.gitmodules
if [[ ! -f ${SUBMODULE_CONFIG_FILE} ]]; then
  # echo "NO SUBMODULE -- exit"
  exit 0
fi

echo "Checking submodules..."

# ------------------------------
IFS=$'\x0A'$'\x0D'
#save initial dir
pushd . > /dev/null
cd ${PROJECT_ROOT}

FAILED=0
# loop through all submodules
git_submodules=`git submodule`
for l in $git_submodules
do
  if [[ "$l" =~ $SUBMODULE_REGEX_STATUS ]]; then
    status=${BASH_REMATCH[1]}
    hash=${BASH_REMATCH[2]}
    path=${BASH_REMATCH[3]}
    branch=${BASH_REMATCH[5]}

    # if [[ $status =~ " " ]]; then
    #   print_success "  Submodule [$path] ... OK"
    if [[ $status == "-" ]]; then
      print_error "  Submodule [$path] ... NOT initialized"
    else
      # echo "submodule changed!!! let's check revisions"
      success=`check_submodule_is_pushed ${hash} ${path}`
      if [[ "$?" -eq 0 ]]; then
        print_success "  Submodule [$path] ... OK"
      else
        IFS=$''
        print_error "  Submodule [$path] ... FAILED"
        echo $success
        FAILED=1
        exit 1 # break as soon as submodule fails
      fi
    fi
  fi
done

# go back to original folder
popd > /dev/null

echo "returning state $FAILED"
exit $FAILED