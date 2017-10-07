#!/bin/sh

if $XXL_analytics; then
  export ZABBIX_VERSION_FULL=$(zabbix_server -V | grep "(Zabbix)" | awk '{print $3"-"$4}')
  curl --connect-timeout 20 --max-time 30 -ks -o /dev/null "http://www.google-analytics.com/r/collect?v=1&tid=UA-72810204-2&cid=${cid}&t=event&ec=Ping&ea=Version&el=${ZABBIX_VERSION_FULL}&ev=1&dp=%2F&dl=http%3A%2F%2Fgithub.com%2Fmonitoringartist%2Fdockbix-xxl" &> /dev/null &
fi
