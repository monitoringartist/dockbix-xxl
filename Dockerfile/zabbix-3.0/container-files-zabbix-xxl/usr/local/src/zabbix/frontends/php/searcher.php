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
$page['title'] = _('Searcher');
$page['file'] = 'searcher.php';
$page['type'] = detect_page_type(PAGE_TYPE_HTML);
require_once dirname(__FILE__).'/include/page_header.php';

$widget = (new CWidget())
        ->setTitle(_('Search Zabbix projects'))
        ->setControls((new CList())
                ->addItem(get_icon('fullscreen', ['fullscreen' => getRequest('fullscreen')]))
        );
$widget->show();

?>
<link rel="stylesheet" type="text/css" href="searcher/stylesheets/style.css" />
<link rel="stylesheet" href="//maxcdn.bootstrapcdn.com/font-awesome/4.5.0/css/font-awesome.min.css">
<script>var $jq = jQuery.noConflict();</script>    
<script async src="searcher/javascripts/stuff.js"></script>
<script async src="searcher/javascripts/search.js"></script>
<header>
  <input type="search" class="input-search speedy-filter" placeholder="Search">
  <a href="#" class="button js-clear-search clear-search" title="Clear search">&times;</a>
  
  <div class="fright">
    <div class="tfright">List of Zabbix projects is updated on daily basis by </div><a href="http://www.monitoringartist.com" target="_blank" title="DevOps / Docker / Kubernetes / Monitoring / Zabbix / Zenoss">
    <img src="searcher/assets/Monitoring-Artist-logo.png">
    </a>
  </div>
             
</header>

<section class="list">
  <ul class="container">
  </ul>

  <div class="loading">
    Loading
  </div>

  <div class="no-results">
    <div class="emoji s_cry" title="cry"></div>
    <br><div class="no-results-text">Sorry, no results</div>
    <p class="call">
      Help your future self by creating and adding
      <strong class="keyword"></strong> project to
    </p>
    <p>
      <a class="button js-contribute contribute-button" href="https://github.com/zabbix/zabbix-community-repos" target="_blank">Github Zabbix community repos</a>
    </p>
  </div>
</section>
<?php
require_once dirname(__FILE__).'/include/page_footer.php';
?>