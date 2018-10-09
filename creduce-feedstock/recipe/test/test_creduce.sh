#!/bin/bash

if ! creduce --debug interestingness_test.sh interestingness_input; then
  echo "ERROR: creduce failed"
  exit 1
fi

# The grep is just to make sure we have a newline
NUM_LINES=$(cat interestingness_input | wc -l | grep "" | tr -d '[:space:]')
if [[ ${NUM_LINES} != 1 ]]; then
  echo "ERROR: creduce failed to reduce the testcase to a single line"
  exit 2
fi

NUM_BAD_EGGS=$(cat interestingness_input | grep "a bad egg" | wc -l | tr -d '[:space:]')
if [[ ${NUM_BAD_EGGS} != 1 ]]; then
  echo "ERROR: creduce failed to reduce the testcase to a single bad egg"
  exit 3
fi
