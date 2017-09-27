#!/bin/sh
# Save env variables and then source them in alertscripts

# source /etc/zabbix/environment_variables_declare
declare -p > /etc/zabbix/environment_variables_declare

# key=value format
printenv > /etc/zabbix/environment_variables_printenv
