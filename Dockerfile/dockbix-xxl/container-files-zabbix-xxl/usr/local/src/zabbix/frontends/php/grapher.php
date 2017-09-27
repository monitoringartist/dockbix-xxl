<?php
require_once dirname(__FILE__).'/include/config.inc.php';
require_once dirname(__FILE__).'/include/hosts.inc.php';
require_once dirname(__FILE__).'/include/graphs.inc.php';

$page['title'] = _('Grapher');
$page['hist_arg'] = array('hostid', 'groupid', 'graphid');
$page['scripts'] = array('class.calendar.js', 'gtlc.js', 'flickerfreescreen.js');
$page['type'] = detect_page_type(PAGE_TYPE_HTML);

define('ZBX_PAGE_DO_JS_REFRESH', 1);

ob_start();

require_once dirname(__FILE__).'/include/page_header.php';

ob_end_flush();

?>

<script src="grapher/chosen.jquery.js" type="text/javascript"></script>
<script src="grapher/grapher.js" type="text/javascript"></script>
<link rel="stylesheet" href="grapher/chosen.css">
<link rel="stylesheet" href="grapher/grapher.css">

<div class="header-title">
  <h1>Grapher</h1>
  <ul>
    <li>Host <select data-placeholder="Select Host(s)..." style="width:200px;" multiple id="hosts"></select></li>
    <li>Graph
      <select data-placeholder="Select Graph(s)..." style="width:200px;" multiple id="graphs"></select>
      <span class="link-action" id="graphs-all">Select All</span>
    </li>
    <li>Item
      <select data-placeholder="Select Item(s)..." style="width:2o0px;" multiple id="items"></select>
      <span class="link-action itemgraph" data-type="0">+Normal</span> |
      <span class="link-action itemgraph" data-type="1">+Stacked</span>
    </li>
  </ul>
</div>

<div class="filter-container" id="filter-space">
  <div id="scrollbar_cntr"></div>
</div>

<br>
<div id="pics"></div>

<?
require_once dirname(__FILE__).'/include/page_footer.php';
