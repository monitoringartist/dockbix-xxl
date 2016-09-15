function CConfig(){
	this.init();
}
var methods = ["action.create",
			"action.delete",
			"action.get",
			"action.update",
			"alert.get",
			"apiinfo.version",
			"application.create",
			"application.delete",
			"application.get",
			"application.massadd",
			"application.update",
			"configuration.export",
			"configuration.import",
			"dhost.get",
			"dservice.get",
			"dcheck.get",
			"drule.create",
			"drule.delete",
			"drule.get",
			"drule.isreadable",
			"drule.iswritable",
			"drule.update",
			"event.acknowledge",
			"event.get",
			"graph.create",
			"graph.delete",
			"graph.get",
			"graph.update",
			"graphitem.get",
			"graphprototype.create",
			"graphprototype.delete",
			"graphprototype.get",
			"graphprototype.update",
			"history.get",
			"host.create",
			"host.delete",
			"host.get",
			"host.isreadable",
			"host.iswritable",
			"host.massadd",
			"host.massremove",
			"host.massupdate",
			"host.update",
			"hostgroup.create",
			"hostgroup.delete",
			"hostgroup.get",
			"hostgroup.isreadable",
			"hostgroup.iswritable",
			"hostgroup.massadd",
			"hostgroup.massremove",
			"hostgroup.massupdate",
			"hostgroup.update",
			"hostinterface.create",
			"hostinterface.delete",
			"hostinterface.get",
			"hostinterface.massadd",
			"hostinterface.massremove",
			"hostinterface.replacehostinterfaces",
			"hostinterface.update",
			"hostprototype.create",
			"hostprototype.delete",
			"hostprototype.get",
			"hostprototype.isreadable",
			"hostprototype.iswritable",
			"hostprototype.update",
			"iconmap.create",
			"iconmap.delete",
			"iconmap.get",
			"iconmap.isreadable ",
			"iconmap.iswritable",
			"iconmap.update",
			"image.create",
			"image.delete",
			"image.get",
			"image.update",
			"item.create",
			"item.delete",
			"item.get",
			"item.isreadable",
			"item.iswritable",
			"item.update",
			"itemprototype.create",
			"itemprototype.delete",
			"itemprototype.get",
			"itemprototype.isreadable",
			"itemprototype.iswritable",
			"itemprototype.update",
			"service.adddependencies",
			"service.addtimes",
			"service.create",
			"service.delete",
			"service.deletedependencies",
			"service.deletetimes",
			"service.get",
			"service.getsla",
			"service.isreadable",
			"service.iswritable",
			"service.update",
			"discoveryrule.copy",
			"discoveryrule.create",
			"discoveryrule.delete",
			"discoveryrule.get",
			"discoveryrule.isreadable",
			"discoveryrule.iswritable",
			"discoveryrule.update",
			"maintenance.create",
			"maintenance.delete",
			"maintenance.get",
			"maintenance.update",
			"map.create",
			"map.delete",
			"map.get",
			"map.isreadable",
			"map.iswritable",
			"map.update",
			"usermedia.get",
			"mediatype.create",
			"mediatype.delete",
			"mediatype.get",
			"mediatype.update",
			"proxy.create",
			"proxy.delete",
			"proxy.get",
			"proxy.isreadable",
			"proxy.iswritable",
			"proxy.update",
			"screen.create",
			"screen.delete",
			"screen.get",
			"screen.update",
			"screenitem.create",
			"screenitem.delete",
			"screenitem.get",
			"screenitem.isreadable",
			"screenitem.iswritable",
			"screenitem.update",
			"screenitem.updatebyposition",
			"script.create",
			"script.delete",
			"script.execute",
			"script.get",
			"script.getscriptsbyhosts",
			"script.update",
			"template.create",
			"template.delete",
			"template.get",
			"template.isreadable",
			"template.iswritable",
			"template.massadd",
			"template.massremove",
			"template.massupdate",
			"template.update",
			"templatescreen.copy",
			"templatescreen.create",
			"templatescreen.delete",
			"templatescreen.get",
			"templatescreen.isreadable",
			"templatescreen.iswritable",
			"templatescreen.update",
			"templatescreenitem.get",
			"trend.get",
			"trigger.adddependencies",
			"trigger.deletedependencies",
			"trigger.create",
			"trigger.delete",
			"trigger.get",
			"trigger.isreadable",
			"trigger.iswritable",
			"trigger.update",
			"triggerprototype.create",
			"triggerprototype.delete",
			"triggerprototype.get",
			"triggerprototype.update",
			"user.addmedia",
			"user.create",
			"user.delete",
			"user.deletemedia",
			"user.get",
			"user.isreadable",
			"user.iswritable",
			"user.login",
            "user.logout",
            "user.update",
            "user.updatemedia",
            "user.updateprofile",
			"usergroup.create",
			"usergroup.delete",
			"usergroup.get",
			"usergroup.isreadable",
            "usergroup.iswritable",
            "usergroup.massadd",
            "usergroup.massupdate",
			"usergroup.update",
            "usermacro.create",
			"usermacro.createglobal",
            "usermacro.delete",
			"usermacro.deleteglobal",
			"usermacro.get",
			"usermacro.update",
			"usermacro.updateglobal",
            "valuemap.create",
            "valuemap.delete",
            "valuemap.get",
            "valuemap.update",
			"httptest.create",
			"httptest.delete",
			"httptest.get",
			"httptest.isreadable",
			"httptest.iswritable",
			"httptest.update"
];

CConfig.prototype = {
	connections: {},
	host: '',
	login: '',
	password: '',
	auth: '',

	init: function(){
		this.connections = JSON.parse(localStorage.getItem('connections')) || {};

		var that = this;
		$jq('#host').change(function(){
			that.host = this.value;
		});
		$jq('#login').change(function(){
			that.login = this.value;
		});
		$jq('#password').change(function(){
			that.password = this.value;
		});
		$jq('#connAdd').click(function(){
			that.addConnection();
		});
		$jq('#connList').change(function(){
			that.loadConnection($jq('#connList').val());
		});
		$jq('#connRemove').click(function(){
			that.removeConnection();
		});
		this.syncConnectionsList();
	},

	addConnection: function(){
		this.connections[this.host] = {
			host: this.host,
			login: this.login,
			password: this.password
		};
		localStorage.setItem('connections', JSON.stringify(this.connections));

		this.syncConnectionsList();
	},
	removeConnection: function(){
		delete this.connections[$jq('#connList').val()];

		localStorage.setItem('connections', JSON.stringify(this.connections));

		this.syncConnectionsList();
	},
	loadConnection: function(host){
		this.host = this.connections[host].host;
		this.login = this.connections[host].login;
		this.password = this.connections[host].password;

		this.syncConnectionsConfig();
	},

	syncConnectionsList: function(){
		$jq('#connList').empty();
		for(var key in this.connections){
			$jq('#connList').append(new Option(this.connections[key].host, this.connections[key].host));
		}
	},
	syncConnectionsConfig: function(){
		$jq('#host').val(this.host);
		$jq('#login').val(this.login);
		$jq('#password').val(this.password);
	}
};

$jq(document).ready(function() {
    $jq('#loadMe').click(function (e) {
    if ($jq('#load').css('display') == 'none') {
        var docUrl = "https://www.zabbix.com/documentation/3.0/manual/api/reference/" + $jq('#apimethod').val().replace('.','/')
        if ($jq("#load").attr("src") != docUrl) {
            $jq("#load").attr("src", docUrl);
        }
        $jq('#load').show();
    } else {
       $jq('#load').hide();
    }
    });

	config = new CConfig();

	$jq('#saveRequest').click(function() {
		$jq('#saveRequestMethod').val($jq('#apimethod').val());
		$jq('#saveRequestParams').val($jq('#apiparams').val());
	});

	$jq('#saveRequestOk').click(function() {
		var request = {
				name: $jq('#saveRequestName').val(),
				method: $jq('#saveRequestMethod').val(),
				params: $jq('#saveRequestParams').val()
			},
			requests = JSON.parse(localStorage.getItem('requests')) || {};

		requests[request.name] = request;

		localStorage.setItem('requests', JSON.stringify(requests));

		$jq('#saveRequestModal').modal('hide');
	});


	$jq('#loadRequest').click(function() {
		var requests = JSON.parse(localStorage.getItem('requests')) || {};
		$jq('#savedRequests').empty();
		for (var name in requests) {
			$jq('#savedRequests').append(new Option(name, name));
		}
	});

	$jq('#loadRequestOk').click(function() {
		var request,
			requests = JSON.parse(localStorage.getItem('requests')) || {};

		if ($jq('#savedRequests').val()) {
			request = requests[$jq('#savedRequests').val()];
			$jq('#apimethod').val(request.method);
			$jq('#apiparams').val(request.params);
		}

		$jq('#loadRequestModal').modal('hide');
	});

	$jq('#removeSavedRequest').click(function() {
		var requests = JSON.parse(localStorage.getItem('requests')) || {};

		delete requests[$jq('#savedRequests').val()];
		localStorage.setItem('requests', JSON.stringify(requests));

		$jq('#savedRequests').empty();
		for(var name in requests){
			$jq('#savedRequests').append(new Option(name, name));
		}
	});


	$jq('#loginButton').click(function() {
		jsonRpc.connect(config.host, config.login, config.password);
	});

	$jq('#execute').click(function() {
        testOnly();
        paramsUpdate();
		var params;
		try {
			params = $jq('#apiparams').val();
			if (params !== '') {
				params = JSON.parse($jq('#apiparams').val());
			}
			jsonRpc.call($jq('#apimethod').val(), params);
		}
		catch(e) {
			//alert(e);
		}
	});

    function testOnly(){
        if ($jq('#apiparams').val() == '') {
            $jq('#apiparams').parent().removeClass('error');
            $jq('#testResult').hide();
            return true;
        }
        lint = window.JSONLint( $jq('#apiparams').val(), { comments: false } );

        if ( ! lint.error ) {
			$jq('#apiparams').parent().removeClass('error');
            $jq('#testResult').hide();
		}
		else {
			$jq('#apiparams').parent().addClass('error');
            $jq('#response, #request').empty();
            $jq('#responsetime').text("");
            $jq('#testResult').show();
            $jq('#testResult').html([
				lint.error + "<br>" +
				"<b>Evidence:</b> " + lint.evidence + "<br>" +
				"<b>Line:</b> " + lint.line + "<br>" +
				"<b>Character:</b> " + lint.character
			].join(''));
		}
    }

    function paramsUpdate() {
        location.hash = 'apimethod=' + encodeURIComponent($jq('#apimethod').val()) + '&apiparams=' + encodeURIComponent($jq('#apiparams').val());
    }

    $jq('#compressJSON').click(function(){
        var params;
        params = JSON.parse($jq('#apiparams').val());
        $jq('#apiparams').val(JSON.stringify(params, null, null));
        paramsUpdate();
    });

	$jq('#formatJSON').click(function(){
		var params;
        if ($jq('#apiparams').val() == '') {
            $jq('#apiparams').parent().removeClass('error');
            $jq('#testResult').hide();
            return true;
        }
        lint = window.JSONLint( $jq('#apiparams').val(), { comments: false } );

        if ( ! lint.error ) {
			$jq('#apiparams').parent().removeClass('error');
            $jq('#response, #request').empty();
            $jq('#responsetime').text("");
            $jq('#testResult').hide();
    	    try {
    			params = JSON.parse($jq('#apiparams').val());
    			$jq('#apiparams').val(JSON.stringify(params, null, 4));
                paramsUpdate();
    		}
    		catch(e) {
    			alert(e);
    		}
		}
		else {
			$jq('#apiparams').parent().addClass('error');
            $jq('#testResult').show();
            $jq('#testResult').html([
				lint.error + "<br>" +
				"<b>Evidence:</b> " + lint.evidence + "<br>" +
				"<b>Line:</b> " + lint.line + "<br>" +
				"<b>Character:</b> " + lint.character
			].join(''));
		}
	});

    var substringMatcher = function(strs) {
      return function findMatches(q, cb) {
        var matches, substringRegex;

        // an array that will be populated with substring matches
        matches = [];

        // regex used to determine if a string contains the substring `q`
        substrRegex = new RegExp(q, 'i');

        // iterate through the pool of strings and for any string that
        // contains the substring `q`, add it to the `matches` array
        $jq.each(strs, function(i, str) {
          if (substrRegex.test(str)) {
            matches.push(str);
          }
        });

        cb(matches);
      };
    };

	$jq('#apimethod').typeahead({
		hint: true,
		highlight: true,
		minLength: 1
	},
	{
		name: 'apimethods',
        limit: 14,
		source: substringMatcher(methods),        
	});

    if (location.hash.length) {
        var prms = getHashParams();
        if ('apimethod' in prms) {
            $jq('#apimethod').val(prms['apimethod']);
        }
        if ('apiparams' in prms) {
            $jq('#apiparams').val(prms['apiparams']);
        }
    }
    
    if (methods.indexOf($jq('#apimethod').val()) > -1 ) {
        $jq('#loadMe').removeClass('disabled');
    } else {
        $jq('#loadMe').addClass('disabled');
    }    
});

$jq(document).on('search keyup change typeahead:selected typeahead:autocompleted', '#apimethod', function () {
    var prms = getHashParams();
    var hash = '';
    delete prms['apimethod'];
    $jq.each( prms, function( key, value ) {
        hash = key + "=" + encodeURIComponent(value) + '&';
    });
    location.hash = 'apimethod=' + encodeURIComponent($jq(this).val()) + '&' + hash;
    if (methods.indexOf($jq(this).val()) > -1 ) {
        $jq('#loadMe').removeClass('disabled');
    } else {
        $jq('#loadMe').addClass('disabled');
    }
})

$jq(document).on('search keyup change', '#apiparams', function () {
    var prms = getHashParams();
    var hash = '';
    delete prms['apiparams'];
    $jq.each( prms, function( key, value ) {
        hash = key + "=" + encodeURIComponent(value) + '&';
    });
    location.hash = hash + 'apiparams=' + encodeURIComponent($jq(this).val());
})

function getHashParams() {
    var hashParams = {};
    var e,
        a = /\+/g,  //Regex for replacing addition symbol with a space
        r = /([^&;=]+)=?([^&;]*)/g,
        d = function (s) { return decodeURIComponent(s.replace(a, " ")); },
        q = window.location.hash.substring(1);
    while (e = r.exec(q))
       hashParams[d(e[1])] = d(e[2]);
    return hashParams;
}