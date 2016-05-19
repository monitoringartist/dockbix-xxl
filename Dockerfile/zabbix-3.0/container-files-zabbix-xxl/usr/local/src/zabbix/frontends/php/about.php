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
        ->setTitle(_('Thank you for using Zabbix 3.0 XXL'))
        ->setControls((new CList())
                ->addItem(get_icon('fullscreen', ['fullscreen' => getRequest('fullscreen')]))
        );
$widget->show();
?>

<p>
  <b>We are happy that you are using our <a href="https://github.com/monitoringartist/zabbix-3.0-xxl" target="_blank">
  Zabbix 3.0 XXL Docker image</a>. If you like it, please consider to support our development with a donation.</b>
</p>
<p>
  Zabbix 3.0 XXL is free for you, but not for us. Maintaining and improving not only
  costs a lot of time, but money as well. So if Zabbix 3.0 XXL proves to be useful to you,
  we would be glad to receive some appreciation in return. You can eventually sponsor some
  feature, which can be useful for you.
</p>
<p>
  <a href="https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=8LB6J222WRUZ4" target="_blank">
    <img src="searcher/assets/donate-button.png">
  </a>
</p>

<p>
  <h2>Author</h2>
</p>
<p>
  <a title="DevOps / Docker / Kubernetes / Zabbix / Zenoss / Monitoring" href="http://www.monitoringartist.com" target="_blank" style="float: right;">
    <img alt="DevOps / Docker / Kubernetes / Zabbix / Zenoss / Monitoring" src="searcher/assets/Monitoring-Artist-logo.jpg">
  </a>
  <a title="DevOps / Docker / Kubernetes / Zabbix / Zenoss / Monitoring" href="http://www.monitoringartist.com" target="_blank">
  Monitoring Artist</a> is a company, which provides professional devops, automation, cloud and monitoring services.<br />
  Most of the projects are related to open source monitoring tools such as Zabbix, Zenoss, Grafana, ....
  <div style="clear:both; width: 100%; height:0;font-size:0;"></div>
</p>
<p>
  <b>Our Zabbix related projects</b>
  <ul>
  <li>
    <a target="_blank" href="https://github.com/monitoringartist/kubernetes-zabbix">
      Kubernetes Zabbix cluster
    </a>
  </li>
  <li>
    <a target="_blank" href="https://github.com/monitoringartist/Zabbix-Docker-Monitoring">
      Zabbix C module for Docker monitoring
    </a>
  </li>
  <li>
    <a target="_blank" href="https://github.com/zabbix/zabbix-community-repos">
      Zabbix community projects
    </a>
  </li>
  <li>
    <a target="_blank" href="https://github.com/zabbix/zabbix-community-docker">
      Basic Zabbix community Docker images
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

<h2>Zabbix 3.0 XXL integrated projects</h2>

<p>
  <ul>
  <li>
    <a target="_blank" href="http://monitoringartist.github.io/zabbix-searcher/">
      Our Zabbix searcher
    </a>
  </li>
  <li>
    <a target="_blank" href="https://github.com/zabbix/zabbix-bash-completion">
      Zabbix bash completion
    </a>
  </li>
  <li>
    <a target="_blank" href="https://github.com/howardjones/network-weathermap">
      Network weathermap
    </a> with <a target="_blank" href="https://github.com/amousset/php-weathermap-zabbix-plugin">
      Zabbix network weathermap plugin
    </a>
  </li>
  <li> ... more projects are in our TODO list</li>
  </ul>
</p>

<?php
require_once dirname(__FILE__).'/include/page_footer.php';