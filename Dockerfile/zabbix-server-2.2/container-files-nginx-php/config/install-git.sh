#!/bin/bash

GIT_VERSION="2.4.5"

echo "=============================================================="
echo "Installing Git ${GIT_VERSION}...                              "
echo "=============================================================="

cd /tmp
wget https://www.kernel.org/pub/software/scm/git/git-$GIT_VERSION.tar.gz

tar -zxf git-$GIT_VERSION.tar.gz --no-same-owner
cd git-$GIT_VERSION
make prefix=/usr/local all
make prefix=/usr/local install

rm -rf /tmp/git* && cd /tmp

echo && echo "Git installed." && echo
