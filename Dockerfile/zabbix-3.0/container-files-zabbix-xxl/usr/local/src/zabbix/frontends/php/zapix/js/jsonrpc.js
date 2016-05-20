"use strict";

var jsonRpc = (function($) {
	var JSONRPCVersion = '2.0';

	var sessionid = null,
		hostname,
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
				$('#connections').modal('hide');
				$("#connInfo").text('Connected to ' + config.host.replace('https://', '').replace('http://',''));
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

			$('#response, #request').empty();
			$('#request').html(request);
            $('#execute').addClass('active', {duration:0});
            $('#responsetime').text("");
            ajaxTime= new Date().getTime();

			$.ajax({
				url: hostname,
				headers: {
					"Content-type": "application/json-rpc"
				},
				type: "POST",
				data: request,
				dataType: "text",
				success: function(result) {
                    totalTime = new Date().getTime() - ajaxTime;
                    $('#execute').removeClass('active', {duration:0});
                    $('#responsetime').text(" (" + totalTime/1000 + "s)");                    
					try {
						result = JSON.parse(result);
						$('#response').text(JSON.stringify(result, null, 4));
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
						$('#response').html(result);
						alert('Api response not in JSON format.');
					}
				},
				error: function(xhr) {
                    totalTime = new Date().getTime() - ajaxTime;
                    $('#execute').removeClass('active', {duration:0});
                    $('#responsetime').text(" (" + totalTime/1000 + "s)");
					alert(xhr.statusText);
				}
			});
		}
	};
}(jQuery));
