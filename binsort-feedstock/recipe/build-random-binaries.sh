#!/usr/bin/env bash

pushd random_binaries
  python corrupt.py -a -n 100 -o the-comedy-of-errors.1.txt the-comedy-of-errors.0.txt
  python corrupt.py -a -n 100 -o the-comedy-of-errors.2.txt the-comedy-of-errors.1.txt
  python corrupt.py -a -n 100 -o the-comedy-of-errors.3.txt the-comedy-of-errors.2.txt
  python corrupt.py -a -n 100 -o the-comedy-of-errors.4.txt the-comedy-of-errors.3.txt
popd
