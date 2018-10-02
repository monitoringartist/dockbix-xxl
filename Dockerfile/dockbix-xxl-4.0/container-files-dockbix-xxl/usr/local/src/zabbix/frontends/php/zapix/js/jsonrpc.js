"use strict";

function getCookie(cname) {
    var name = cname + "=";
    var ca = document.cookie.split(';');
    for(var i = 0; i <ca.length; i++) {
        var c = ca[i];
        while (c.charAt(0)==' ') {
            c = c.substring(1);
        }
        if (c.indexOf(name) == 0) {
            return c.substring(name.length,c.length);
        }
    }
    return "";
}

var jsonRpc = (function($) {
	var JSONRPCVersion = '2.0';

	var sessionid = getCookie('zbx_sessionid'),
		hostname = window.location.protocol + "//" + window.location.hostname + (window.location.port ? ':' + window.location.port: '') + "/api_jsonrpc.php",
		id = 0,
        ajaxTime = 0,
        totalTime = 0;

	return {
		connect: function(host, user, pass, params) {
			hostname = host + "/api_jsonrpc.php";

			params = params || {};
			if (typeof params.xdebugsid !== 'undefined') {
				hostname += '?XDEBUG_SESSION_START=' + params.xdebugsid;
			}

			this.call('user.login', {user: user, password: pass}, function(result) {
				sessionid = result;
				$jq('#connections').modal('hide');
				$jq("#connInfo").text('Connected to ' + config.host.replace('https://', '').replace('http://',''));
			});
		},

		call: function(method, params, onSuccess) {
			if (!sessionid && method != 'user.login') {
				alert('Connect to Zabbix first.');
				return false;
			}
			var request = {
				jsonrpc: JSONRPCVersion,
				method: method,
				id: id++,
				auth: sessionid
			};
			if (params !== '') {
				request['params'] = params;
			}
			request = JSON.stringify(request);

			$jq('#response, #request').empty();
			$jq('#request').html(request);
            $jq('#execute').addClass('active', {duration:0});
            $jq('#responsetime').text("");
            ajaxTime= new Date().getTime();

			$jq.ajax({
				url: hostname,
				headers: {
					"Content-type": "application/json-rpc"
				},
				type: "POST",
				data: request,
				dataType: "text",
				success: function(result) {
                    totalTime = new Date().getTime() - ajaxTime;
                    $jq('#execute').removeClass('active', {duration:0});
                    $jq('#responsetime').text(" (" + totalTime/1000 + "s)");                    
					try {
						result = JSON.parse(result);
						$jq('#response').text(JSON.stringify(result, null, 4));
						if (typeof result.result !== 'undefined') {
							if (typeof onSuccess !== 'undefined') {
								onSuccess(result.result);
							}
						}
						else {
							alert(result.error.data);
						}
					}
					catch (e) {
						$jq('#response').html(result);
						alert('Api response not in JSON format.');
					}
				},
				error: function(xhr) {
                    totalTime = new Date().getTime() - ajaxTime;
                    $jq('#execute').removeClass('active', {duration:0});
                    $jq('#responsetime').text(" (" + totalTime/1000 + "s)");
					alert(xhr.statusText);
				}
			});
		}
	};
}(jQuery));
