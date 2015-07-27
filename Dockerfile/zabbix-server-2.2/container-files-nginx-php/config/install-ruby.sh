#!/bin/bash

#
# Currently not used, Ruby from yum repo is installed.
#

RUBY_INSTALL_VERSION=0.5.0
RUBY_VERSION=2.2.2

echo "=============================================================="
echo "Installing Ruby ${RUBY_VERSION}...                            "
echo "=============================================================="

cd /tmp
wget -O ruby-install-$RUBY_INSTALL_VERSION.tar.gz \
  https://github.com/postmodern/ruby-install/archive/v$RUBY_INSTALL_VERSION.tar.gz
tar -xzf ruby-install-$RUBY_INSTALL_VERSION.tar.gz --no-same-owner
cd ruby-install-*
make install

ruby-install -i /usr/local ruby $RUBY_VERSION

make uninstall

rm -rf /tmp/ruby* && cd /tmp
echo && echo "Ruby installed." && echo
