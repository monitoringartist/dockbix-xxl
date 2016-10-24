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
  else echo -n; fi
}

xxl_config() {
  cid=$(md5sum <<< $(hostname) | awk -F - '{print $1}' | tr -d ' ')
  XXL_updatechecker=${XXL_updatechecker:-true}
  XXL_analytics=${XXL_analytics:-true}
  # disable/enable XXL features
  if ! $XXL_searcher; then
    sed -i "/'searcher.php'/d" /usr/local/src/zabbix/frontends/php/include/menu.inc.php
    rm -rf /usr/local/src/zabbix/frontends/php/searcher/ /usr/local/src/zabbix/frontends/php/searcher.php
  else
    if $XXL_analytics; then
      curl --connect-timeout 20 --max-time 30 -ks -o /dev/null "http://www.google-analytics.com/r/collect?v=1&tid=UA-72810204-2&cid=${cid}&t=event&ec=Stat&ea=XXL_searcher&el=${XXL_searcher}&ev=1&dp=%2F&dl=http%3A%2F%2Fgithub.com%2Fmonitoringartist%2Fzabbix-xxl" &> /dev/null &
    fi
  fi
  if ! $XXL_zapix; then
    sed -i "/'zapix.php'/d" /usr/local/src/zabbix/frontends/php/include/menu.inc.php
    rm -rf /usr/local/src/zabbix/frontends/php/zapix/ /usr/local/src/zabbix/frontends/php/zapix.php
  else
    if $XXL_analytics; then
      curl --connect-timeout 20 --max-time 30 -ks -o /dev/null "http://www.google-analytics.com/r/collect?v=1&tid=UA-72810204-2&cid=${cid}&t=event&ec=Stat&ea=XXL_zapix&el=${XXL_zapix}&ev=1&dp=%2F&dl=http%3A%2F%2Fgithub.com%2Fmonitoringartist%2Fzabbix-xxl" &> /dev/null &
    fi
  fi
  if ! $XXL_grapher; then
    sed -i "/'grapher.php'/d" /usr/local/src/zabbix/frontends/php/include/menu.inc.php
    rm -rf /usr/local/src/zabbix/frontends/php/grapher/ /usr/local/src/zabbix/frontends/php/grapher.php
  else
    if $XXL_analytics; then
      curl --connect-timeout 20 --max-time 30 -ks -o /dev/null "http://www.google-analytics.com/r/collect?v=1&tid=UA-72810204-2&cid=${cid}&t=event&ec=Stat&ea=XXL_grapher&el=${XXL_grapher}&ev=1&dp=%2F&dl=http%3A%2F%2Fgithub.com%2Fmonitoringartist%2Fzabbix-xxl" &> /dev/null &
    fi
  fi
  if ! $XXL_updatechecker; then
    rm -rf /usr/local/src/zabbix/frontends/php/updatechecker/
    sed -i "s#echo \"<script.*updatechecker/updatechecker.*>.*</script>\";##g" /usr/local/src/zabbix/frontends/php/include/page_footer.php
  else
    curl --connect-timeout 20 --max-time 30 -ks -o /dev/null "http://www.google-analytics.com/r/collect?v=1&tid=UA-72810204-2&cid=${cid}&t=event&ec=Stat&ea=XXL_updatechecker&el=${XXL_grapher}&ev=1&dp=%2F&dl=http%3A%2F%2Fgithub.com%2Fmonitoringartist%2Fzabbix-xxl" &> /dev/null &
  fi
  if ! $XXL_analytics; then
    # remove analytics
    sed -i "s#<script>.*</script></body></html>#</body></html>#g" /usr/local/src/zabbix/frontends/php/include/page_footer.php
    sed -i "s#<script>.*</script></body></html>#</body></html>#g" /usr/local/src/zabbix/frontends/php/app/views/layout.htmlpage.php
  else
    export ZABBIX_VERSIONP=$(echo $ZABBIX_VERSION | tr -d '/')
    curl --connect-timeout 20 --max-time 30 -ks -o /dev/null "http://www.google-analytics.com/r/collect?v=1&tid=UA-72810204-2&cid=${cid}&t=event&ec=Ping&ea=Version&el=${ZABBIX_VERSIONP}&ev=1&dp=%2F&dl=http%3A%2F%2Fgithub.com%2Fmonitoringartist%2Fzabbix-xxl" &> /dev/null &
    curl --connect-timeout 20 --max-time 30 -ks -o /dev/null "http://www.google-analytics.com/r/collect?v=1&tid=UA-72810204-2&cid=${cid}&t=event&ec=Stat&ea=Version&el=${ZABBIX_VERSIONP}&ev=1&dp=%2F&dl=http%3A%2F%2Fgithub.com%2Fmonitoringartist%2Fzabbix-xxl" &> /dev/null &
    if $ZS_enabled; then
      curl --connect-timeout 20 --max-time 30 -ks -o /dev/null "http://www.google-analytics.com/r/collect?v=1&tid=UA-72810204-2&cid=${cid}&t=event&ec=Stat&ea=ZS_enabled&el=${ZS_enabled}&ev=1&dp=%2F&dl=http%3A%2F%2Fgithub.com%2Fmonitoringartist%2Fzabbix-xxl" &> /dev/null &
    fi
    if $ZA_enabled; then
      curl --connect-timeout 20 --max-time 30 -ks -o /dev/null "http://www.google-analytics.com/r/collect?v=1&tid=UA-72810204-2&cid=${cid}&t=event&ec=Stat&ea=ZA_enabled&el=${ZA_enabled}&ev=1&dp=%2F&dl=http%3A%2F%2Fgithub.com%2Fmonitoringartist%2Fzabbix-xxl" &> /dev/null &
    fi
    if $ZW_enabled; then
      curl --connect-timeout 20 --max-time 30 -ks -o /dev/null "http://www.google-analytics.com/r/collect?v=1&tid=UA-72810204-2&cid=${cid}&t=event&ec=Stat&ea=ZW_enabled&el=${ZW_enabled}&ev=1&dp=%2F&dl=http%3A%2F%2Fgithub.com%2Fmonitoringartist%2Fzabbix-xxl" &> /dev/null &
    fi
    if $ZP_enabled; then
      curl --connect-timeout 20 --max-time 30 -ks -o /dev/null "http://www.google-analytics.com/r/collect?v=1&tid=UA-72810204-2&cid=${cid}&t=event&ec=Stat&ea=ZP_enabled&el=${ZP_enabled}&ev=1&dp=%2F&dl=http%3A%2F%2Fgithub.com%2Fmonitoringartist%2Fzabbix-xxl" &> /dev/null &
    fi
  fi
}

xxl_api() {
  XXL_api=${XXL_api:-true}
  if [ "$XXL_api" = false ] || [ "$ZW_enabled" = false ]; then
    return 0
  fi

  XXL_apiuser=${XXL_apiuser:-Admin}
  XXL_apipass=${XXL_apipass:-zabbix}

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

  AUTH_TOKEN=$(curl -s -X POST -H 'Content-Type: application/json-rpc' -d "{\"jsonrpc\":\"2.0\",\"method\":\"user.login\",\"id\":0,\"auth\":null,\"params\":{\"user\":\"${XXL_apiuser}\",\"password\":\"${XXL_apipass}\"}}" http://0.0.0.0/api_jsonrpc.php | jq -r .result)
  if [ "$AUTH_TOKEN" != "null" ]; then
    log "API access succesfull"
    if [ -d "/etc/zabbix/api" ]; then
      ID=1
      LAST_ID=0
      files=$(find /etc/zabbix/api -regex  '.*\(.xml\|.api\|.sh\)$' -type f|sort)
      for file in $files; do
        if $XXL_analytics; then
          curl -ks -o /dev/null "http://www.google-analytics.com/r/collect?v=1&tid=UA-72810204-2&cid=${cid}&t=event&ec=Stat&ea=API&el=${file}&ev=1&dp=%2F&dl=http%3A%2F%2Fgithub.com%2Fmonitoringartist%2Fzabbix-xxl" &> /dev/null &
        fi      
        if [[ "$file" == *xml ]]; then
          # API XML import
          log "API XML import: $file"
          template=$(cat $file | sed -e 's/\"/\\\"/g' | sed -e 's/^[ \t]*//' | tr --delete '\n')
          apicall="{\"jsonrpc\":\"2.0\",\"method\":\"configuration.import\",\"id\":<ID>,\"auth\":\"<AUTH_TOKEN>\",\"params\":{\"format\":\"xml\",\"rules\":{\"templates\":{\"createMissing\":true,\"updateExisting\":true},\"images\":{\"createMissing\":true,\"updateExisting\":true},\"groups\":{\"createMissing\":true},\"triggers\":{\"createMissing\":true,\"updateExisting\":true},\"valueMaps\":{\"createMissing\":true,\"updateExisting\":true},\"hosts\":{\"createMissing\":true,\"updateExisting\":true},\"items\":{\"createMissing\":true,\"updateExisting\":true},\"maps\":{\"createMissing\":true,\"updateExisting\":true},\"screens\":{\"createMissing\":true,\"updateExisting\":true},\"templateScreens\":{\"createMissing\":true,\"updateExisting\":true},\"templateLinkage\":{\"createMissing\":true},\"applications\":{\"createMissing\":true,\"updateExisting\":true},\"graphs\":{\"createMissing\":true,\"updateExisting\":true},\"discoveryRules\":{\"createMissing\":true,\"updateExisting\":true}},\"source\":\"${template}\"}}"
          command=$(echo $apicall | sed -e "s/<ID>/$ID/g" | sed -e "s/<AUTH_TOKEN>/$AUTH_TOKEN/g")
          output=$(echo $command | curl -s -X POST -H 'Content-Type: application/json-rpc' -d @- http://0.0.0.0/api_jsonrpc.php)
          log "API response: $output"
          ID=$((ID+1))
        elif [[ "$file" == *api ]]; then
          # API command
          log "API command: $file"
          for line in $(cat $file); do
            log "API call: $line"
            command=$(echo $line | sed -e "s/<ID>/$ID/g" | sed -e "s/<AUTH_TOKEN>/$AUTH_TOKEN/g" | sed -e "s/<LAST_ID>/$LAST_ID/g")
            output=$(curl -s -X POST -H 'Content-Type: application/json-rpc' -d "${command}" http://0.0.0.0/api_jsonrpc.php)
            log "API response: $output"
            LAST_ID=$(echo $output | jq -r 'first(.result[]?)|.[]?')
            ID=$((ID+1))
          done
        else
          # bash script - environment variable are available in the script
          log "API script: $file"
          output=$(bash $file)
          log "API script output: $output"
        fi
      done
    fi
  else
    log "API access not succesfull - try to set up env. variables XXL_apiuser/XXL_apipass"
  fi
}

log "Preparing XXL features"
xxl_config
xxl_api &
log "XXL configuration done."
