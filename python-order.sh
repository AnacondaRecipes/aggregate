#!/usr/bin/env bash

# Find every recipe that depends upon python .. let us try linux repodata.json with jq for this:

function get_order() {
  [[ -f repodata.linux.json ]] || curl -o repodata.linux.json -SLO https://repo.continuum.io/pkgs/main/linux-64/repodata.json
  [[ -f repodata.macos.json ]] || curl -o repodata.macos.json -SLO https://repo.continuum.io/pkgs/main/osx-64/repodata.json
  [[ -f repodata.win.json ]]   || curl -o repodata.win.json -SLO https://repo.continuum.io/pkgs/main/win-64/repodata.json
  local -a PKGS=$(cat repodata.linux.json repodata.macos.json repodata.win.json | jq --raw-output '.packages[] | select(.depends[] | contains("python")) .name' | sort | uniq)

  # Use this block to iterate on fixing recipe cycles.
  # c3i examine will give a list of things involved in a cycle, but often it will include more entries than are
  # necessary. If you feed that list back in here it will usually be able to give a smaller list next time.
  if [[ no == yes ]]; then
    PKGS=()
    PKGS+=(pip)
    PKGS+=(wheel)
    PKGS+=(pytest)
    PKGS+=(pytest-cov)
    PKGS+=(more-itertools)
  fi

  local -a RECIPE_DIRS
  local -a PKGS_MISSING
  for PKG in ${PKGS[@]}; do
    local FOUND_AT=
    if [[ -d ${PKG}-feedstock ]]; then
      FOUND_AT=${PKG}-feedstock
    elif [[ -d ${PKG} ]]; then
      FOUND_AT=${PKG}
    fi

    # Skip some (NYI)

    if [[ -n ${FOUND_AT} ]]; then
      RECIPE_DIRS+=(${FOUND_AT})
    else
      PKGS_MISSING+=(${PKG})
    fi
  done

  if [[ ${#PKGS_MISSING[@]} != 0 ]]; then
    echo "WARNING :: Could not determine the recipes needed to build the following ${#PKGS_MISSING[@]} packages:"
    echo "WARNING :: ${PKGS_MISSING[@]}"
  fi

  c3i examine --matrix-base-dir ~/conda/private_conda_recipes/rays-scratch-scripts/c3i-build-orderer-config ~/conda/aggregate --output /tmp/build-order --folders ${RECIPE_DIRS[@]}
  cp /tmp/build-order/output_order_recipes_* python-order.txt
  echo "Done, please see python-order.txt"
}

get_order
