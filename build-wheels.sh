#!/bin/bash

# Build Python "manylinux" binary wheels. See the following documentation:
# - https://github.com/pypa/manylinux
# - https://github.com/pypa/python-manylinux-demo

set -e -x

# Install a system package required by our library
#yum install -y atlas-devel

# Create intermediate wheelhouse to store the initial wheels, before
# the external shared libraries have been incorporated
mkdir -p /tmp/wheelhouse

# And also create the final wheelhouse, where Jenkins can pick it up
mkdir -p /io/wheelhouse

# Change directory to /io/ so that pip requirements depending
# on setup.py work as expected
cd /io/

# Compile wheels
for PYBIN in /opt/python/*/bin; do
    ${PYBIN}/pip install -r /io/requirements.pip
    ${PYBIN}/pip wheel /io/ -w /tmp/wheelhouse/
done

# Bundle external shared libraries into the wheels
for whl in /tmp/wheelhouse/pySLALIB-*.whl; do
    auditwheel repair $whl -w /io/wheelhouse/
done

# Install packages and test
for PYBIN in /opt/python/*/bin/; do
    ${PYBIN}/pip install tox
    ${PYBIN}/pip install pySLALIB --no-index -f /io/wheelhouse
    (rm -rf .tox ; ${PYBIN}/tox)
done
