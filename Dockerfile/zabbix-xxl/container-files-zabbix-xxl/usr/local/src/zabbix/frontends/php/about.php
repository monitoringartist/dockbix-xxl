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
$page['title'] = _('About Zabbix XXL');
$page['file'] = 'about.php';
$page['type'] = detect_page_type(PAGE_TYPE_HTML);
require_once dirname(__FILE__).'/include/page_header.php';

$widget = (new CWidget())
        ->setTitle(_('Zabbix XXL'))
        ->setControls((new CList())
                ->addItem(get_icon('fullscreen', ['fullscreen' => getRequest('fullscreen')]))
        );
$widget->show();
?>
<p>
Zabbix XXL contains standard Zabbix + additional XXL (community)
extensions and everything is packaged into Docker image for easy deployment.<br />
Source repo: <a target="_blank" href="https://github.com/monitoringartist/zabbix-xxl">https://github.com/monitoringartist/zabbix-xxl</a>
</p>
<p>
  <a href="https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=8LB6J222WRUZ4" target="_blank">
    <img src="searcher/assets/donate-button2.png">
  </a>
  <br /><br />
</p>

<p>
  <h2>Author</h2>
</p>
<div style="background: white; padding: 10px; margin-bottom: 2em;">
  <a title="DevOps / Docker / Kubernetes / AWS ECS / Zabbix / Zenoss / Terraform / Monitoring" href="http://www.monitoringartist.com" target="_blank" style="float: right;">
    <img alt="DevOps / Docker / Kubernetes / AWS ECS / Zabbix / Zenoss / Terraform / Monitoring" src="searcher/assets/Monitoring-Artist-logo.jpg">
  </a>
  <a title="DevOps / Docker / Kubernetes / AWS ECS / Zabbix / Zenoss / Terraform / Monitoring" href="http://www.monitoringartist.com" target="_blank">
  Monitoring Artist</a> is a company, which provides professional devops, automation, cloud and monitoring services.<br />
  Most of the projects are related to open source monitoring tools such as Zabbix, Zenoss, Grafana, ...<br /><br />
  Feel free to contact us (<a href="mailto:info@monitoringartist.com">info@monitoringartist.com</a>) for commercial support of your Dockerized Zabbix or Docker/Kubernete/AWS ECS monitoring.
  <div style="clear:both; width: 100%; height:0;font-size:0;"></div>
</div>
<p>

<div style="float:left; width:48%;">
<h2>XXL extensions:</h2>
<p>
  <ul>
  <li>
    <a target="_blank" href="http://monitoringartist.github.io/zabbix-searcher/">
      Zabbix searcher - source of Zabbix community projects
    </a>
  </li>
  <li>
    <a target="_blank" href="http://monitoringartist.github.io/zapix/">
      Zapix - online Zabbix API tool
    </a>
  </li>
  <li>
    <a target="_blank" href="https://github.com/sepich/zabbixGrapher">
      Grapher - quick grapher selection
    </a>
  </li>
  <li>
    <a target="_blank" href="https://github.com/monitoringartist/zabbix-docker-monitoring">
      Zabbix Docker monitoring - basic templates
    </a>
  </li>        
  </ul>
</p>
</div>

<div style="float:left">
  <h2>Monitoring Artist other projects</h2>
  <ul>
  <li>
    <a target="_blank" href="https://github.com/monitoringartist/kubernetes-zabbix">
      Kubernetes Zabbix cluster
    </a>
  </li>
  <li>
    <a target="_blank" href="https://github.com/monitoringartist/zabbix-docker-monitoring">
      Zabbix Docker monitoring
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
<div style="clear:both; width: 100%; height:0;font-size:0;"></div>
<?php
require_once dirname(__FILE__).'/include/page_footer.php';
