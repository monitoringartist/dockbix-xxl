#!/bin/bash

# get the latest backup dump
LATEST_BACKUP_BZ2=$(ls -dt /backups/zabbix_db_dump_* | head -1)
echo -e "Restoring from $LATEST_BACKUP_BZ2"

# Manual import
echo -e "Start importing backup sql ..."
docker exec -ti zabbix-db bash -c "bunzip2 -dc $LATEST_BACKUP_BZ2 | mysql -uzabbix -pmy_password zabbix"

echo -e "Restored."
