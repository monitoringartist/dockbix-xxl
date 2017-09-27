from zabbix.api import ZabbixAPI
zapi = ZabbixAPI(url='http://localhost/', user='Admin', password='zabbix')
hosts = zapi.host.getobjects(status=1)
for host in hosts:
    print 'Enabling host: %s' % host['name']
    zapi.host.update(hostid=host['hostid'],status=0)
