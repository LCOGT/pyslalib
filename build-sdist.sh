#!/bin/bash

# Build Python "source distribution" package.

set -e -x
cd /io
pip install numpy
python setup.py sdist
