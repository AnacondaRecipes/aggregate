#!/usr/bin/env bash

# Find every recipe that depends upon python .. let us try linux repodata.json with jq for this:

function contains() {
  local e match="$1"
  shift
  for e; do [[ "$e" == "$match" ]] && return 0; done
  return 1
}

function get_order() {

  # Use this block to iterate on fixing recipe cycles.
  # c3i examine will give a list of things involved in a cycle, but often it will include more entries than are
  # necessary. If you feed that list back in here it will usually be able to give a smaller list next time.
  local OUTPUT=$1; shift
  local -a PKGS=$*

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

  [[ -d /tmp/build-order ]] && rm -rf /tmp/build-order
  c3i examine --matrix-base-dir ~/conda/private_conda_recipes/rays-scratch-scripts/c3i-build-orderer-config ${PWD} --output /tmp/build-order --folders ${RECIPE_DIRS[@]}

  # Skip already-seen duplicates (c3i examine bug?)
  cp /tmp/build-order/output_order_recipes_* ${OUTPUT}.tmp
  IFS=$'\n' read -d '' -r -a PYTHON_ORDER_TMP < ${OUTPUT}.tmp
  local -a PYTHON_ORDER
  for ENTRY in "${PYTHON_ORDER_TMP[@]}"; do
    if ! contains "${ENTRY}" "${PYTHON_ORDER[@]}"; then
      PYTHON_ORDER+=(${ENTRY})
    else
     echo "Skipped duplicate entry ${ENTRY}"
    fi
  done
  rm -f ${OUTPUT}
  for ENTRY in "${PYTHON_ORDER[@]}"; do
    echo ${ENTRY} >> ${OUTPUT}
  done

  echo "Done, please see ${OUTPUT}"
}

function get_downstreams_of() {
  local OF=$1; shift
  if ! type -P jq; then
    echo "Please install jq via"
    echo "conda install conda-forge::jq"
    exit 1
  fi
  [[ -f repodata.r.linux.json ]] || curl -o repodata.linux.json -SLO https://repo.continuum.io/pkgs/r/linux-64/repodata.json
  [[ -f repodata.linux.json ]] || curl -o repodata.linux.json -SLO https://repo.continuum.io/pkgs/main/linux-64/repodata.json
  [[ -f repodata.macos.json ]] || curl -o repodata.macos.json -SLO https://repo.continuum.io/pkgs/main/osx-64/repodata.json
  [[ -f repodata.win.json ]]   || curl -o repodata.win.json -SLO https://repo.continuum.io/pkgs/main/win-64/repodata.json
  local -a PKGS=$(cat repodata.r.linux.json repodata.linux.json repodata.macos.json repodata.win.json | jq --raw-output ".packages[] | select(.depends[] | contains(\"$OF\")) .name" | sort | uniq)
  echo ${PKGS[@]}
}

declare -a PKG_ARGS
DOWNSTREAMS_OF=
while [ "$#" -gt 0 ]; do
    OPT="$1"
    case "$1" in
        --enable-*)
            VAR=$(echo $1 | sed "s,^--enable-\(.*\),\1,")
            VAL=yes
            ;;
        --disable-*)
            VAR=$(echo $1 | sed "s,^--disable-\(.*\),\1,")
            VAL=no
            ;;
        --*=*)
            VAR=$(echo $1 | sed "s,^--\(.*\)=.*,\1,")
            VAL=$(echo $1 | sed "s,^--.*=\(.*\),\1,")
            ;;
        *)
            PKG_ARGS+=($1)
            ;;
    esac
    VAR=$(echo "$VAR" | tr '[a-z]-' '[A-Z]_')
    case "$VAR" in
        sources)
            if [ "$VAL" = "local" -o "$VAL" = "remote" ]; then
                eval "$VAR=\$VAL"
            else
                echo "$VAL can only be 'local' or 'remote'"
                exit 1
            fi
            ;;
        *)
            eval "$VAR=\$VAL"
            ;;
    esac
    shift
    OPTIONS_DEBUG=$OPTIONS_DEBUG" $VAR=$VAL"
done

declare -a PKGS
if [[ -n ${DOWNSTREAMS_OF} ]]; then
  PKGS=$(get_downstreams_of ${DOWNSTREAMS_OF})
else
  PKGS=${PKG_ARGS[@]}
fi

TEMPF=$(mktemp ${TMPDIR}/$(uuidgen).txt)
rm ${TEMPF} || true
get_order ${TEMPF} ${PKGS[@]}
cat ${TEMPF}
