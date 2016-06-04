<?php
/*
** Monitoring Artist
** Copyright (C) 2015-2016 Monitoring Artist Ltd
**
** This program is free software; you can redistribute it and/or modify
** it under the terms of the GNU General Public License as published by
** the Free Software Foundation; either version 2 of the License, or
** (at your option) any later version.
**
** This program is distributed in the hope that it will be useful,
** but WITHOUT ANY WARRANTY; without even the implied warranty of
** MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
** GNU General Public License for more details.
**
** You should have received a copy of the GNU General Public License
** along with this program; if not, write to the Free Software
** Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
**/

require_once dirname(__FILE__).'/include/config.inc.php';
$page['title'] = _('About Zabbix 3.0 XXL');
$page['file'] = 'about.php';
$page['type'] = detect_page_type(PAGE_TYPE_HTML);
require_once dirname(__FILE__).'/include/page_header.php';

$widget = (new CWidget())
        ->setTitle(_('Zabbix 3.0 XXL'))
        ->setControls((new CList())
                ->addItem(get_icon('fullscreen', ['fullscreen' => getRequest('fullscreen')]))
        );
$widget->show();
?>
<p>
Zabbix 3.0 XXL contains standard Zabbix binaries + some additional XXL (community) 
features and everything is packaged into Docker image for easy deployement.<br />
Source repo: <a target="_blank" href="https://github.com/monitoringartist/zabbix-xxl">https://github.com/monitoringartist/zabbix-xxl</a>
</p>
<p>
  <a href="https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=8LB6J222WRUZ4" target="_blank">
    <img src="searcher/assets/donate-button2.png">
  </a>
</p>

<p>
  <h2>Author</h2>
</p>
<div style="background: white; padding: 10px;">
  <a title="DevOps / Docker / Kubernetes / AWS ECS / Zabbix / Zenoss / Terraform / Monitoring" href="http://www.monitoringartist.com" target="_blank" style="float: right;">
    <img alt="DevOps / Docker / Kubernetes / AWS ECS / Zabbix / Zenoss / Terraform / Monitoring" src="searcher/assets/Monitoring-Artist-logo.jpg">
  </a>
  <a title="DevOps / Docker / Kubernetes / AWS ECS / Zabbix / Zenoss / Terraform / Monitoring" href="http://www.monitoringartist.com" target="_blank">
  Monitoring Artist</a> is a company, which provides professional devops, automation, cloud and monitoring services.<br />
  Most of the projects are related to open source monitoring tools such as Zabbix, Zenoss, Grafana, ....
  <div style="clear:both; width: 100%; height:0;font-size:0;"></div>
</div>
<p>

<div style="float:left">
<h2>Available XXL community features:</h2>
<p>
  <ul>
  <li>
    <a target="_blank" href="http://monitoringartist.github.io/zabbix-searcher/">
      Zabbix searcher
    </a>
  </li>
  <li>
    <a target="_blank" href="http://monitoringartist.github.io/zapix/">
      Zapix (beta integration)
    </a>
  </li>
  <li>
    <a target="_blank" href="https://github.com/sepich/zabbixGrapher">
      Grapher (beta integration)
    </a>
  </li>      
  </ul>
</p>
</div>

<div style="float:left">
  <h2>Monitoring Artist Zabbix related projects</h2>
  <ul>
  <li>
    <a target="_blank" href="https://github.com/monitoringartist/kubernetes-zabbix">
      Kubernetes Zabbix cluster
    </a>
  </li>
  <li>
    <a target="_blank" href="https://github.com/monitoringartist/zabbix-docker-monitoring">
      Zabbix module/template for Docker monitoring
    </a>
  </li>
  <li>
    <a target="_blank" href="https://github.com/monitoringartist/zabbix-community-repos">
      Zabbix community projects
    </a>
  </li>
  <li>
    <a target="_blank" href="https://github.com/monitoringartist/control-center-zabbix">
      Control Center Zabbix template
    </a>
  </li>
  <li>
    <a target="_blank" href="https://github.com/monitoringartist/zabbix-server-stress-test">
      Zabbix server stress test
    </a>
  </li>
  <li>
    <a target="_blank" href="https://github.com/monitoringartist/zabbix-agent-stress-test">
      Zabbix agent stress test
    </a>
  </li>
  <li> ... others </li>
  </ul>
</p>
</div>

<?php
require_once dirname(__FILE__).'/include/page_footer.php';