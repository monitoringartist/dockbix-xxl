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
  cid=$(md5sum <<< $(hostname) | awk -F - '{print $1}' | tr -d ' ')
  XXL_analytics=${XXL_analytics:-true}
  # disable/enable XXL features  
  if ! $XXL_searcher; then
    sed -i "/'searcher.php'/d" /usr/local/src/zabbix/frontends/php/include/menu.inc.php
    rm -rf /usr/local/src/zabbix/frontends/php/searcher/ /usr/local/src/zabbix/frontends/php/searcher.php
  else
    if $XXL_analytics; then
      curl -ks -o /dev/null "http://www.google-analytics.com/r/collect?v=1&tid=UA-72810204-2&cid=${cid}&t=event&ec=Bootstrap&ea=Start&el=XXL_searcher&ev=1&dp=%2F&dl=http%3A%2F%2Fgithub.com%2Fmonitoringartist%2Fzabbix-xxl" &> /dev/null
    fi
  fi
  if ! $XXL_zapix; then
    sed -i "/'zapix.php'/d" /usr/local/src/zabbix/frontends/php/include/menu.inc.php
    rm -rf /usr/local/src/zabbix/frontends/php/zapix/ /usr/local/src/zabbix/frontends/php/zapix.php
  else
    if $XXL_analytics; then
      curl -ks -o /dev/null "http://www.google-analytics.com/r/collect?v=1&tid=UA-72810204-2&cid=${cid}&t=event&ec=Bootstrap&ea=Start&el=XXL_zapix&ev=1&dp=%2F&dl=http%3A%2F%2Fgithub.com%2Fmonitoringartist%2Fzabbix-xxl" &> /dev/null
    fi  
  fi
  if ! $XXL_grapher; then
    sed -i "/'grapher.php'/d" /usr/local/src/zabbix/frontends/php/include/menu.inc.php
    rm -rf /usr/local/src/zabbix/frontends/php/grapher/ /usr/local/src/zabbix/frontends/php/grapher.php
  else
    if $XXL_analytics; then
      curl -ks -o /dev/null "http://www.google-analytics.com/r/collect?v=1&tid=UA-72810204-2&cid=${cid}&t=event&ec=Bootstrap&ea=Start&el=XXL_grapher&ev=1&dp=%2F&dl=http%3A%2F%2Fgithub.com%2Fmonitoringartist%2Fzabbix-xxl" &> /dev/null
    fi  
  fi
  if ! $XXL_analytics; then
    sed -i "/<script>(function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){(i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)})(window,document,'script','//www.google-analytics.com/analytics.js','ga');ga('create','UA-72810204-2','auto');ga('send','pageview');</script>/d" /usr/local/src/zabbix/frontends/php/include/menu.inc.php
  fi  
}

xxl_api() {
  XXL_apiuser=${XXL_apiuser:-Admin}
  XXL_apipass=${XXL_apipass:-zabix}

  # wait 120sec for Zabbix API start
  retry=24
  until curl --output /dev/null --silent --head --fail localhost:80 &>/dev/null
  do
    log "Waiting for API, it's still not available"
    retry=`expr $retry - 1`
    if [ $retry -eq 0 ]; then
      error "API is not available!"
      exit 1
    fi
    sleep 5
  done
  log "API is available"  
  
  AUTH_TOKEN=$(curl -s -X POST -H 'Content-Type: application/json-rpc' -d "{\"jsonrpc\":\"2.0\",\"method\":\"user.login\",\"id\":0,\"auth\":null,\"params\":{\"user\":\"guest\",\"password\":\"\"}}" http://0.0.0.0/api_jsonrpc.php | jq -r .result)
  if [ "$AUTH_TOKEN" != "null" ]; then
    log "API access succesfull"
    if [ -d "/etc/zabbix/api" ]; then
      files=$(find /etc/zabbix/api -name '*.curl'|sort)
      for file in $files; do
        ID=1
        for line in $(cat $file); do
          log $line              
          command=$(echo $line | sed -e "s/<ID>/$ID/g" | sed -e "s/<AUTH_TOKEN>/$AUTH_TOKEN/g")
          log $(curl -s -X POST -H 'Content-Type: application/json-rpc' -d "${command}" http://0.0.0.0/api_jsonrpc.php) 
          ID=$((ID+1))
        done
      done 
    fi          
  else
    log "API access not succesfull - try to set up variables XXL_apiuser/XXL_apipass"
  fi    
}

log "Preparing XXL features"
xxl_config
xxl_api &
log "XXL configuration done."
