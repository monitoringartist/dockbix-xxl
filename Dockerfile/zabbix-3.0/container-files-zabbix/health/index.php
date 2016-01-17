<?php
// (Micro)service healthcheck
// Used for loadabalancer healthcheck
// You can implement more advance version, eg. test DB connectivity, ...
 
print '{
  "Name": "zabbix-frontend",
  "Description": "Zabbix PHP web UI.",
  "ServiceOK": true,
  "Endpoints": [
    {
      "Name": "UI",
      "Path": "/",
      "Description": "UI",
      "OK": true
    },
    {
      "Name": "UI /zabbix/",
      "Path": "/zabbix/",
      "Description": "UI alias /zabbix/",
      "OK": true
    }
  ]
}';

?>
