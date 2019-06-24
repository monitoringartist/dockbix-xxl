#!/bin/sh
#
# Configure access IP address for nginx status page under /nginx_status
#
set -eu
export TERM=xterm
# Bash Colors
red=`tput setaf 1`
green=`tput setaf 2`
yellow=`tput setaf 3`
white=`tput setaf 7`
bold=`tput bold`
reset=`tput sgr0`
separator=$(echo && printf '=%.0s' {1..100} && echo)

# Logging functions
log() {
  if [[ "$@" ]]; then echo "${bold}${green}`date +'%Y-%m-%d %H:%M:%S,000'` INFO${reset} $@";
  else echo -n; fi
}

sed -i "s|allow 127.0.0.1|allow ${STATUS_PAGE_ALLOWED_IP}|g" /etc/nginx/conf.d/stub-status.conf
log "Nginx status page: allowed address set to $STATUS_PAGE_ALLOWED_IP."
