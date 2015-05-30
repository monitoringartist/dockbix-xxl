<?php
// Zabbix GUI configuration file
global $DB;
$DB["TYPE"]           = 'MYSQL';
$DB["SERVER"]         = 'DB_ADDRESS';
$DB["PORT"]           = '3306';
$DB["DATABASE"]       = 'zabbix';
$DB["USER"]           = 'DB_USER';
$DB["PASSWORD"]       = 'DB_PASS';
// SCHEMA is relevant only for IBM_DB2 database
$DB["SCHEMA"]         = '';
$ZBX_SERVER           = 'localhost';
$ZBX_SERVER_PORT      = '10051';
$ZBX_SERVER_NAME      = '';
$IMAGE_FORMAT_DEFAULT = IMAGE_FORMAT_PNG;
?>