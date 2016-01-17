#!/bin/sh

#
# This script will be placed in /config/init/ and run when container starts.
# It creates (if they're not exist yet) necessary Nginx directories
# @see /etc/nginx/addon.d/fastcgi-cache.example
#

set -e

mkdir -p /run/user/nginx-cache
mkdir -p /run/user/nginx-cache-tmp
chown -R www:www /run/user/nginx-cache*
