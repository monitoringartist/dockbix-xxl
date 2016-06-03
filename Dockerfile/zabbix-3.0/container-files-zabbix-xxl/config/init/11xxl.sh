#!/bin/sh

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
  if [[ "$@" ]]; then echo "${bold}${green}[LOG `date +'%T'`]${reset} $@";
  else echo; fi
}

xxl_config() {
  # disable/enable XXL features
  if ! $XXL_searcher; then
    sed -i "/'searcher.php'/d" /usr/local/src/zabbix/frontends/php/include/menu.inc.php
    rm -rf /usr/local/src/zabbix/frontends/php/searcher/ /usr/local/src/zabbix/frontends/php/searcher.php
  fi
  if ! $XXL_zapix; then
    sed -i "/'zapix.php'/d" /usr/local/src/zabbix/frontends/php/include/menu.inc.php
    rm -rf /usr/local/src/zabbix/frontends/php/zapix/ /usr/local/src/zabbix/frontends/php/zapix.php
  fi
  if ! $XXL_grapher; then
    sed -i "/'grapher.php'/d" /usr/local/src/zabbix/frontends/php/include/menu.inc.php
    rm -rf /usr/local/src/zabbix/frontends/php/grapher/ /usr/local/src/zabbix/frontends/php/grapher.php
  fi
}
log "Preparing XXL features"
xxl_config
log "XXL configuration done."
