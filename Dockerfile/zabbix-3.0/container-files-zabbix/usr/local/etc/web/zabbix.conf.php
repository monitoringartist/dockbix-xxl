<?php
// Zabbix GUI configuration file
global $DB;

$DB['TYPE']     = 'MYSQL';
$DB['SERVER']   = 'ZS_DBHost';
$DB['PORT']     = 'ZS_DBPort';
$DB['DATABASE'] = 'ZS_DBName';
$DB['USER']     = 'ZS_DBUser';
$DB['PASSWORD'] = 'ZS_DBPassword';

// SCHEMA is relevant only for IBM_DB2 database
$DB['SCHEMA'] = '';

$ZBX_SERVER      = 'ZW_ZBX_SERVER';
$ZBX_SERVER_PORT = 'ZW_ZBX_SERVER_PORT';
$ZBX_SERVER_NAME = 'ZW_ZBX_SERVER_NAME';

$IMAGE_FORMAT_DEFAULT = IMAGE_FORMAT_PNG;
?>
