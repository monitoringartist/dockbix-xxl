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
$page['title'] = _('Support');
$page['file'] = 'support.php';
$page['type'] = detect_page_type(PAGE_TYPE_HTML);
require_once dirname(__FILE__).'/include/page_header.php';

$widget = (new CWidget())
        ->setTitle(_('Support'))
        ->setControls((new CList())
        ->addItem(get_icon('fullscreen', ['fullscreen' => getRequest('fullscreen')]))
        );
$widget->show();
?>
<p>

<h2>Free community support</h2>
All options to receive <a href="http://zabbix.org/wiki/Getting_help" targer="_blank">support from Zabbix community</a>.

<h2>Paid commercial support</h2>
<a href="http://www.zabbix.com/services" target="_blank">Zabbix company</a> supports all Zabbix related issues:
- configuration, troubleshooting
- tunning, deployment, consulting
- custom development, integrations and training

<a href="https://www.monitoringartist.com" target="_blank">Monitoring Artist company</a> supports all Docker related issues
- Docker deployment, scaling, monitoring
- Docker orchestration: Kubernetes, AWS ECS, ...

Monitoring Artist Dockerized monitoring stack:

</p>

Debug informations:
hostname
print all env variables (mask passwords)


<p>
Request commercial support.

TODO FORM Google forms
Contact details
</p>
<div style="clear:both; width: 100%; height:0;font-size:0;"></div>
<?php
require_once dirname(__FILE__).'/include/page_footer.php';
