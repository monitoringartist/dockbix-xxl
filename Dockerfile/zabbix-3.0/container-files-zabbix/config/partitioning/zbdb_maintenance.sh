#!/bin/sh

echo "$( date ): Starting Zabbix Database maintenance:"
SQLCMD="CALL partition_maintenance_all(\"${ZS_DBName}\",${ZS_DBPartKeepData},${ZS_DBPartKeepTrends});"
/usr/bin/echo "$SQLCMD" \
| /usr/bin/mysql --user=${ZS_DBUser} --password=${ZS_DBPassword} -h ${ZS_DBHost} -P ${ZS_DBPort} -D ${ZS_DBName}
echo "$( date ): Zabbix Database maintenance completed"
