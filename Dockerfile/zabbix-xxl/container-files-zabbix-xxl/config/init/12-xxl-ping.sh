#!/bin/sh

export ZABBIX_VERSIONP=$(echo $ZABBIX_VERSION | tr -d '/')
if $XXL_analytics; then
  curl --connect-timeout 20 --max-time 30 -ks -o /dev/null "http://www.google-analytics.com/r/collect?v=1&tid=UA-72810204-2&cid=${cid}&t=event&ec=Ping&ea=Version&el=${ZABBIX_VERSIONP}&ev=1&dp=%2F&dl=http%3A%2F%2Fgithub.com%2Fmonitoringartist%2Fzabbix-xxl" &> /dev/null &
fi
