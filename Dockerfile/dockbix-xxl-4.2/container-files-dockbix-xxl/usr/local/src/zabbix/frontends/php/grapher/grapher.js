// zabbixGrapher
// https://github.com/sepich/zabbixGrapher

jQuery(function() {
  var options = {
    url: '/api_jsonrpc.php',            // zabbix API url
    timeout: 5000,                      // to API in msec
    ssid: getCookie('zbx_sessionid'),   // key to API, get from current logged in user
    pagelen: 24,                        // graphs per page
    width: 600,                         // of graph
    height: 200                         // of graph
  },
  itemgraphs=[], //array of items obj to draw
  skipHistory=false, //do not save this draw to history (from navigation)
  timeoutID,
  $=jQuery;
  console.log('starting');

  //timeline init
  window.flickerfreeScreenShadow.timeout = 30000 ;
  window.flickerfreeScreenShadow.responsiveness = 10000;
  var d=new Date();
  d.setFullYear(d.getFullYear() - 1);
  timeControl.addObject("scrollbar", {
      "period": 10800,
      "starttime": cdumpts(d),
      "isNow": 1
    },
    {
      "id":'scrollbar',
      "loadScroll":1,
      "mainObject":1,
      "periodFixed":'1',
      "sliderMaximumTimePeriod":63072000
  });
  timeControl.processObjects();
  cookie.init();

  //ZabbixApi wrapper
  function ZabbixApi(method, params, success) {
    $.ajax({
      contentType: 'application/json-rpc',
      type: 'POST',
      timeout: options.timeout,
      url: options.url,
      data: JSON.stringify({
        jsonrpc: '2.0',
        method: method,
        id: 0,
        auth: options.ssid,
        params: params,
      }),
      success: function(response, status) {
        success(response, status);
      }
    });
  }

  //Hosts list
  $("#hosts").chosen({search_contains: true}).change(function(e){
    console.log('hosts changed');
    updateHint(this);
    //delay update while user is clicking (shift-click race)
    window.clearTimeout(timeoutID);
    timeoutID = window.setTimeout(function(){
      updateGraphs();
      updateItems();
    }, 1500);
  });
  //fill in hosts list on start
  ZabbixApi('hostgroup.get', {
      monitored_hosts: 1,
      sortfield: 'name',
      selectHosts: ['name'],
      output: ['name']
    },
    function(r){
      $.each(r.result, function(){
        var og = $('<optgroup label="'+this.name+'" data-groupid="'+this.groupid+'"/>');
        $.each(this.hosts, function(){
            $('<option value="'+this.hostid+'" />').html(this.name).appendTo(og);
        });
        og.appendTo( $('#hosts') );
      });
      $('#hosts').trigger("chosen:updated");
      resoreState(readUrl()); // on page load try to read state from URL
    }
  );

  //Graphs list
  $("#graphs").chosen({search_contains: true}).change(function(e){
    console.log('graphs changed');
    updateHint(this);
    drawGraphs();
  });
  //Update graphs lists
  function updateGraphs(toselect){
    if($('#hosts').val() == null){
      $('#graphs').empty();
      $('#graphs').trigger("chosen:updated");
      $('#graphs').trigger('change');
    }
    else {
      ZabbixApi('graph.get', {
        hostids: $('#hosts').val(),
        expandName: 1,
        output: ['name','graphtype'],
        sortfield: 'name',
      },
      function(r){
        //parse graphs to draw as name=[ids,]
        var graphs={}
        $.each(r.result, function(){
          if(graphs[this.name]==undefined) graphs[this.name]=[this.graphid];
          else graphs[this.name].push(this.graphid);
        });
        //update options vals to store already selected
        $.each($('#graphs option'), function(){
          var k=$(this).text();
          if(k in graphs){
            $(this).val(graphs[k]);
            delete graphs[k];
          }
          else $(this).remove();
        });
        //add new options
        $.each(graphs, function(k,v){
          $('<option value="'+v+'"/>').html(k).appendTo($('#graphs'));
        });
        //select deferred or all if only one Host selected
        if(toselect!=null) selectGraphs(toselect);
        else if($('#hosts').val().length==1 && $('#graphs').val()==null) $('#graphs option').prop('selected', true);
        $('#graphs').trigger("chosen:updated");
        $('#graphs').trigger('change');
      });
    }
  }
  //Select All Graphs
  $('#graphs-all').click(function(){
    $('#graphs option').prop('selected', true);
    $('#graphs').trigger("chosen:updated");
    $('#graphs').trigger('change');
  });

  //Items list
  $("#items").chosen({search_contains: true}).change(function(e){
    console.log('items changed');
    updateHint(this);
  });
  //Update items lists
  function updateItems(){
    $('#items').empty();
    if($('#hosts').val() == null){
      if(itemgraphs.length){
       itemgraphs=[];
       drawGraphs();
      }
      $('#items').trigger("chosen:updated");
      $('#items').trigger('change');
      return;
    }
    ZabbixApi('item.get', {
        hostids: $('#hosts').val(),
        selectApplications: ['name'],
        filter: {
          state: 0, //supported
          status: 0, //enabled
          value_type: [0,3] //numeric
        },
        output: ['name','description','error','key_','units'],
        sortfield: 'name',
      },
      function(r){
        apps={}
        $.each(r.result, function(){
          var app=(this.applications.length)? this.applications[0].name : '-';
          //expand $1 in name from .key_
          if(~this.name.indexOf('$')){
            var keys=/\[([^\]]+)\]/.exec(this.key_);
            if(keys[1]!=undefined){
              keys=keys[1].split(',');
              for (var i=1; i<=keys.length; i++) {
                this.name=this.name.replace('$'+i, keys[i-1].trim());
              }
            }
          }
          if(apps[app]==undefined) apps[app]={}
          if(apps[app][this.name]==undefined) apps[app][this.name]=[this.itemid];
          else apps[app][this.name].push(this.itemid);
        });
        $.each(apps, function(app,items){
          var og = $('<optgroup label="'+app+'" />');
          $.each(items, function(i,v){
              $('<option value="'+v+'" />').html(i).appendTo(og);
          });
          og.appendTo( $('#items') );
        });
        $('#items').trigger("chosen:updated");
        $('#items').trigger('change');
      }
    );
  }
  //Add item graph
  $('span.itemgraph').click(function(){
    if($('#items').val()!=null){
      var items=[]
      $.each( $('#items').val(), function(){
        items=items.concat(this.split(','));
      });
      itemgraphs.push( {items: items, type: $(this).data('type'), id: Math.random().toString(16).slice(2)} );
      $('#items option:selected').removeAttr('selected');
      $('#items').trigger('chosen:updated');
      $('#items').trigger('change');
      drawGraphs();
    }
  });

  //Number hint and clear button
  ['hosts','graphs','items'].each(function(i){
    $('#'+i+'_chosen li.search-field').append('<div class="chsn-clean" title="clean"/><div class="chsn-hint"/>');
  });
  $('li.search-field').click(function(){
    $(this).find('input').focus();
  });
  $('.chsn-clean').click(function(){
    var s=$(this).closest('.chosen-container').prev('select');
    s.find('option:selected').removeAttr('selected');
    s.trigger('chosen:updated');
    s.trigger('change');
    $(this).prev('input').val('');
  });
  function updateHint(o){
    if($(o).val() == null){
      $(o).next().find('.chsn-hint').html('');
      $(o).next().find('.chsn-clean').html('');
    }
    else {
      $(o).next().find('.chsn-hint').html( $(o).val().length + ' selected' );
      $(o).next().find('.chsn-clean').html('&times;');
    }
  }
  //Click optgroup to toggle all subitems
  $(document).on('click', '.group-result', function() {
    var unselected = $(this).nextUntil('.group-result').not('.result-selected');
    if(unselected.length) unselected.trigger('mouseup');
    else $(this).nextUntil('.group-result').each(function() {
      $('a.search-choice-close[data-option-array-index="' + $(this).data('option-array-index') + '"]').trigger('click');
    });
  });

  //Draw selected graphs (page)
  function drawGraphs(page){
    //cleanup
    $('#pics').empty();
    timeControl.objectList={};
    $.each(flickerfreeScreen.screens, function(){
      if(this.timeoutHandler!=null) clearTimeout(this.timeoutHandler);
    });
    flickerfreeScreen.screens=[];
    ZBX_SBOX={};

    //prepare graphs ids
    graphs=[]
    if($('#graphs').val()!=null) $.each( $('#graphs').val(), function(){
      graphs=graphs.concat(this.split(','));
    });
    var stime = cdumpts((timeControl.timeline._usertime-timeControl.timeline._period)*1000);
    //prepage pager
    if(graphs.length > options.pagelen){
      if(page==undefined) page=0;
      pages=Math.floor(graphs.length/options.pagelen);
      start = page * options.pagelen;
      end = Math.min(start + options.pagelen, graphs.length);
      var s='';
      for(var i=0; i<=pages; i++){
        s+=(i==page)? '<a href="#" class="paging-selected" data-num="'+i+'">'+(i+1)+'</a>' : '<a href="#" data-num="'+i+'">'+(i+1)+'</a>';
      }
      if(page>0) s='<a href="#" data-num="'+(page-1)+'">&lt; Previous</a>'+s;
      if(page!=pages) s+='<a href="#" data-num="'+(page+1)+'">Next &gt;</a>';
      pager=$('<div class="paging-btn-container"/>').append(s);
      pager=$('<div class="table-paging"/>').append(pager);
      pager.appendTo( $('#pics') );
    }
    else {
      start=0;
      end=graphs.length;
    }
    //add itemgraphs
    for (var i=0; i<itemgraphs.length; i++) {
      id=itemgraphs[i].id;
      uri=''
      itemgraphs[i].items.forEach(function(v,k){
        if(v!=undefined) uri+='itemids['+k+']='+v+'&';
      })
      $('#pics').append(
        $('<div class="flickerfreescreen" id="flickerfreescreen_'+id+'" />')
        .append('<div class="center" id="itemgraph_'+id+'" />')
        .append('<div class="close-graph" data-id="'+id+'" />')
      );
      timeControl.addObject(id, {
         "period": timeControl.timeline._period,
         "starttime": cdumpts(timeControl.timeline._starttime),
         "usertime": cdumpts(timeControl.timeline._usertime),
         "isNow": timeControl.timeline._isNow
        },
        {
          "containerid":"itemgraph_"+id,
          "objDims":{
            "shiftYtop":35,
            "yaxis":"0",
            "graphtype":"0",
            "graphHeight": options.height,
            "shiftXleft": 65,
            "shiftXright": 65,
            "width": options.width
          },
          "loadSBox":1,
          "loadImage":1,
          "periodFixed":"1",
          "sliderMaximumTimePeriod": timeControl.timeline.maxperiod,
          "src": 'chart.php?'+uri+'type='+itemgraphs[i].type+'&batch=1&width='+options.width+'&height='+options.height+'&period='+timeControl.timeline._period+'&stime='+stime
      });
      window.flickerfreeScreen.add({
        "id": id,
        "isFlickerfree":true,
        "pageFile":'history.php',
        "resourcetype":'17',
        "mode":2,
        "interval":'60',
        "timeline":{
          "period": timeControl.timeline._period,
          "stime": stime,
          "isNow": timeControl.timeline._isNow
        },
        "data":{"itemids":[itemgraphs[i].items],"action":'showgraph',"filter":'',"filterTask":null,"markColor":1}
      });
    }
    //add graphs
    for (var i=start; i<end; i++) {
      id=graphs[i];
      $('#pics').append(
        $('<div class="flickerfreescreen" id="flickerfreescreen_'+id+'" />')
        .append('<a href="charts.php?graphid='+id+'" id="graph_container_'+id+'" />')
        .append('<div class="close-graph" data-id="'+id+'" />')
      );
      timeControl.addObject(id,
      {
       "period": timeControl.timeline._period,
       "starttime": cdumpts(timeControl.timeline._starttime),
       "usertime": cdumpts(timeControl.timeline._usertime),
       "isNow": timeControl.timeline._isNow
      },
      {
        "containerid":"graph_container_"+id,
        "objDims":{
          "shiftYtop":35,
          "yaxis":"0",
          "graphtype":"0",
          "graphHeight": options.height,
          "shiftXleft": 65,
          "shiftXright": 65,
          "width": options.width
        },
        "loadSBox":1,
        "loadImage":1,
        "periodFixed":"1",
        "sliderMaximumTimePeriod": timeControl.timeline.maxperiod,
        "src": "chart2.php?graphid="+id+'&width='+options.width+'&height='+options.height+'&period='+timeControl.timeline._period+'&stime='+stime
      });
      window.flickerfreeScreen.add({
        "id": id,
        "isFlickerfree":true,
        "pageFile":'screens.php',
        "resourcetype":'0',
        "mode":0,
        // "timestamp":1450022637,
        "interval":'60',
        // "screenitemid":'336',
        // "screenid":'34',
        // "groupid":null,
        // "hostid":0,
        "timeline":{
          "period": timeControl.timeline._period,
          "stime": stime,
          // "stimeNow":'20161212070357',
          // "starttime":'20131213080357',
          // "usertime":'20151213080357',
          "isNow": timeControl.timeline._isNow
        },
      //  "profileIdx":'web.screens',
      //  "profileIdx2":'34',
      //  "updateProfile":true,
        "data":null
      });
    };
    //pager at bottom
    if(graphs.length > options.pagelen) {
      pager.clone().appendTo( $('#pics') );
      $('div.paging-btn-container a').click(function(){
        drawGraphs( $(this).data('num') );
      });
    }
    //attach close button event
    $('.close-graph').click(function(e){
      removeGraph(this);
    });
    //live update/select time period
    timeControl.useTimeRefresh(60);
    timeControl.processObjects();
    chkbxRange.init();
    //update url/history
    if(skipHistory) skipHistory=false;
    else{
      var state={hosts: $('#hosts').val(), itemgraphs: itemgraphs, graphs: graphs, page: page};
      history.pushState(state, '', makeUrl(state));
    }
  }

  // Remove graph (id)
  function removeGraph(o){
    var id=$(o).data('id');
    if($(o).prev('a[id^=graph_container_]').length){
      //deselect graph
      if($('#hosts').val().length==1){
        $('#graphs option[value='+id+']').removeAttr('selected');
        $('#graphs').trigger('chosen:updated');
        $('#graphs').trigger('change');
      }
      else{
        $('div#flickerfreescreen_'+id).remove();
      }
    }
    else{
      //remove itemgraph
      for(var i=0; i<itemgraphs.length; i++) {
        if(itemgraphs[i].id == id) {
          itemgraphs.splice(i, 1);
          break;
        }
      }
      $('div#flickerfreescreen_'+id).remove();
    }
  }

  // Restore history state
  window.onpopstate = function(event) {
    if(event.state) resoreState(event.state);
  }
  // page to state
  function resoreState(state){
    if(!state['hosts']) return;
    console.log('restoring state');
    skipHistory=true;
    itemgraphs=state.itemgraphs;
    //hosts already selected, select graphs
    if( compare($('#hosts').val(), state.hosts) ){
      selectGraphs(state.graphs);
      $('#graphs').trigger("chosen:updated");
      updateHint( $('#graphs') );
      drawGraphs(state.page);
    }
    //hosts changed, load graphs and items
    else{
      $('#hosts option:selected').removeAttr('selected');
      $.each(state.hosts, function(){
        $('#hosts option[value="'+this+'"]').prop('selected', true);
      });
      updateHint( $('#hosts') );
      $('#hosts').trigger("chosen:updated");
      updateGraphs(state.graphs);
      updateItems();
    }
  };
  // select graphs from array
  function selectGraphs(graphs){
    $('#graphs option:selected').removeAttr('selected');
    $.each(graphs, function(){
      var o=$('#graphs option[value="'+this+'"]');
      if(!o.length) o=$('#graphs option[value^="'+this+',"]');
      if(!o.length) o=$('#graphs option[value*=",'+this+',"]');
      $(o).prop('selected', true);
    });
  }
  // make URL from state
  function makeUrl(state){
    var items='', page='';
    $.each(state.itemgraphs, function(){
      items+='&items[]='+this.type+','+this.items;
    })
    if(state.page) page='&page='+state.page;
    return location.pathname+'?hosts='+state.hosts+'&graphs='+state.graphs+items+page;
  }
  // read state from URL
  function readUrl(){
    var match,
      search = /([^&=]+)=?([^&]*)/g,
      decode = function(s) { return decodeURIComponent(s); },
      query  = window.location.search.substring(1),
      state = {itemgraphs:[]};

    while (match = search.exec(query)){
      if(match[1]=='items[]'){
        var item={items: decode(match[2]).split(','), id: Math.random().toString(16).slice(2)};
        item['type']=item['items'][0];
        item['items'].splice(0,1);
        state['itemgraphs'].push(item);
      }
      else if(match[1]=='page') state['page']=match[2];
      else state[decode(match[1])] = decode(match[2]).split(',');
    }
    return state;
  }
});

// helpers ------------------------------------------------------------------
// fix for JSON.stringify arrays
if(window.Prototype) {delete Array.prototype.toJSON;}
// parse cookie names
function getCookie(key) {
  var keyValue = document.cookie.match('(^|;) ?' + key + '=([^;]*)(;|$)');
  return keyValue ? keyValue[2] : null;
}
function compare(arrayA, arrayB) {
  if(!arrayA || !arrayB) return false;
  if(arrayA.length != arrayB.length) return false;
  var a = jQuery.extend(true, [], arrayA);
  var b = jQuery.extend(true, [], arrayB);
  a.sort();
  b.sort();
  for (var i = 0, l = a.length; i < l; i++) {
      if (a[i] !== b[i]) {
          return false;
      }
  }
  return true;
}