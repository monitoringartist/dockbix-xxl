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
$page['file'] = 'zapix.php';
$page['type'] = detect_page_type(PAGE_TYPE_HTML);
require_once dirname(__FILE__).'/include/page_header.php';

$widget = (new CWidget())
        ->setTitle(_('Online API tool'))
        ->setControls((new CList())
                ->addItem(get_icon('fullscreen', ['fullscreen' => getRequest('fullscreen')]))
        );
$widget->show();

?>
<link rel="stylesheet" type="text/css" href="zapix/css/bootstrap/bootstrap.min.css" />
<link rel="stylesheet" type="text/css" href="https://maxcdn.bootstrapcdn.com/font-awesome/3.0.2/css/font-awesome.min.css" />
<link rel="stylesheet" type="text/css" href="zapix/css/style.css" />
<script>var $jq = jQuery.noConflict();</script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/typeahead.js/0.11.1/typeahead.bundle.min.js"></script>
<script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/js/bootstrap.min.js" integrity="sha384-0mSbJDEHialfmuBBQP6A4Qrprq5OVfW37PRR3j5ELqxss1yVqOtnepnHVP9aJ7xS" crossorigin="anonymous"></script>
<script async type="text/javascript" src="zapix/js/jsonrpc.js"></script>
<script async type="text/javascript" src="zapix/js/jsonlint.js"></script>
<script async type="text/javascript" src="zapix/js/js.js"></script>
<div class="bootstrap-iso">
<!-- 
<div class="navbar navbar-top">
	<div class="navbar-inner">
		<div class="container-fluid">
			<span class="brand"><a href="#">ZAPIX</a></span>
			<div class="nav-collapse">
				<ul class="nav">
					<li><a data-toggle="modal" href="#connections">Connect</a></li>
                    <li><a target="_blank" href="https://www.zabbix.com/documentation/3.0/manual/api">Zabbix 3.0 API manual</a></li>
                    <li><a target="_blank" href="https://github.com/monitoringartist/zapix">Star and fork me on GitHub</a>
                    <li><a target="_blank" href="http://www.monitoringartist.com">Monitoring Artist</a>
				</ul>
                
				<p id="connInfo" class="navbar-text pull-right">Not connected</p>
			</div>
		</div>
	</div>
</div>
!-->

<!-- Connection manager modal -->
<div class="modal" id="connections" style="display: none;">
	<div class="modal-header">
		<a class="close" data-dismiss="modal">×</a>
		<h3>Connection manager</h3>
	</div>
	<div class="modal-body">
		<div class="row">
			<div class="span3">
				<form>
					<label for="host">Host</label>
					<input id="host" type="url" name="host" />
					<label for="login">Login</label>
					<input id="login" type="text" name="login" />
					<label for="password">Password</label>
					<input id="password" type="password" name="password" />
					<label for="xdebugssid">X-DEBUG SID</label>
					<input id="xdebugssid" type="text" name="xdebugssid" />
					<div class="control-group">
						<button class="btn" type="button" id="connAdd">Store</button>
						<button class="btn btn-primary" type="button" id="loginButton">
							Connect
							<i class="icon-share-alt icon-white"></i>
						</button>
					</div>
				</form>
			</div>
			<div class="span3" style="border-left: 1px solid #CCCCCC; padding-left: 20px;">
				<form>
					<label for="connList">Stored connections</label>
					<select size="12" id="connList" name="connections"></select>
					<div class="control-group">
						<button class="btn btn-mini" type="button" id="connRemove">Remove</button>
					</div>
				</form>
			</div>
		</div>
	</div>
</div>


<!-- Save request modal -->
<div class="modal" id="saveRequestModal" style="display: none;">
	<div class="modal-header">
		<a class="close" data-dismiss="modal">×</a>
		<h3>Save request</h3>
	</div>
	<div class="modal-body">
		<form class="form-horizontal">
			<div class="control-group">
				<label class="control-label" for="saveRequestName">Name</label>
				<div class="controls">
					<input type="text" id="saveRequestName">
				</div>
			</div>
			<div class="control-group">
				<label class="control-label" for="saveRequestMethod">Method</label>
				<div class="controls">
					<input type="text" id="saveRequestMethod">
				</div>
			</div>
			<div class="control-group">
				<label class="control-label" for="saveRequestParams">Request</label>
				<div class="controls">
					<textarea class="saveRequestParams" id="saveRequestParams"></textarea>
				</div>
			</div>
		</form>
	</div>
	<div class="modal-footer">
		<a href="#" id="saveRequestOk" class="btn btn-success">Save <i class="icon-ok icon-white"></i></a>
		<a href="#" data-dismiss="modal" class="btn">Cancel</a>
	</div>
</div>

<!-- Load request modal -->
<div class="modal" id="loadRequestModal" style="display: none;">
	<div class="modal-header">
		<a class="close" data-dismiss="modal">×</a>
		<h3>Load request</h3>
	</div>
	<div class="modal-body">
		<form>
			<div class="control-group">
				<div class="controls">
					<select id="savedRequests" size="10" class="span5"></select>
				</div>
			</div>
			<div class="control-group">
				<div class="controls">
					<button id="removeSavedRequest" class="btn btn-mini" type="button">Remove</button>
				</div>
			</div>
		</form>
	</div>
	<div class="modal-footer">
		<a href="#" id="loadRequestOk" class="btn btn-success">Load</a>
		<a href="#" data-dismiss="modal" class="btn">Cancel</a>
	</div>
</div>


<div class="container-fluid">
	<div class="row-fluid" style="width: 100%;min-width: 1000px;">
		<div class="span12">
			<div class="row-fluid">
				<div class="span6">
					<form class="form-inline">
						<div class="control-group">
							<input id="apimethod" class="span4" type="text" name="apimethod" autocorrect="off" autocapitalize="off" spellcheck="false" placeholder="class.method" />
                            <!--a id="docLink" target="_blank" disabled="true" href="https://www.zabbix.com/documentation/3.0/manual/api/reference/ event/get" class="btn btn-mini" type="button">Doc</a -->                            
                            <a id="loadMe" class="btn disabled btn-mini" type="button">Doc</a>
                            <iframe id="load" src=""></iframe>
                            <!--                             
							<a id="saveRequest" data-toggle="modal" href="#saveRequestModal" class="btn btn-mini" type="button">Save</a>
							<a id="loadRequest" data-toggle="modal" href="#loadRequestModal" class="btn btn-mini" type="button">Load</a>
                            !-->
						</div>
						<div class="control-group">
							<textarea id="apiparams" name="apiparams" autocorrect="off" autocapitalize="off" spellcheck="false" placeholder="parameters as JSON object: {&quot;param1&quot;: &quot;value1&quot;, &quot;param2&quot;: &quot;value2&quot;, ...}"></textarea>
						</div>
						<div class="control-group">
							<button id="execute" class="btn btn-primary has-spinner" type="button">                                
								Check & execute
								<span class="play"><i class="icon-play icon-white"></i></span>
                                <span class="spinner"><i class="icon-spin icon-refresh icon-white"></i></span>
							</button>
							<span id="formatJSON" class="btn">Check & format JSON</span> 
                            <span id="compressJSON" class="btn">Compress JSON</span>                                                        
                            <div id="testResult" class="alert alert-danger" style="display: none"></div>
						</div>
					</form>
				</div>
				<div class="span6">
					<div id="rsp">Request:</div>
					<pre><code id="request" class="language-js"></code></pre>
				</div>
			</div>
			Response<span id="responsetime"></span>:
			<pre><code id="response" class="language-js"></code></pre>
		</div>
	</div>    
</div>
<br /><br />
</div>
<?php
require_once dirname(__FILE__).'/include/page_footer.php';
?>