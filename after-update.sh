#!/bin/sh

git submodule sync
git submodule update --init
if [ -x /usr/local/bin/pre-commit ]; then
  pre-commit install
fi
