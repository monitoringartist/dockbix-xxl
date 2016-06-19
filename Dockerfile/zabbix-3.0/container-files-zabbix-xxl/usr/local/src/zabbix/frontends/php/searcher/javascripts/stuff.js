$jq(document).on('search:ready', function () {
  $jq(".input-search").focus()
  $jq(".loading").remove()
})

function focusOnSearch (e) {
  var searchField = $jq('.input-search')[0]
  if (e.keyCode == 191 && !searchField.length) {
    searchField.focus()
    var t = searchField.get(0)
    if (t.value.length) {
      t.selectionStart = 0
      t.selectionEnd = t.value.length
    }
    return false
  }
}

var counter = 1
$jq.getJSON('https://monitoringartist.github.io/zabbix-searcher/sources/github-community-repos.json', function (projects) {  
  var container = $jq('.container')
  Object.keys(projects).forEach( function (key) {
    var project = projects[key]
    var charHTML
    charHTML = "<div><a target='_blank' onclick=\"ga('send', 'event', 'click', 'Github: " + project['name'] + "'); return true;\" title='#" + counter + " " + project['name'] + "' href='" + 
      project['url'] + "'><i class='fa fa-" + project['icon'] + "'></i> " + project['name'] + "</a></div>"
    container.append("<li class='result emoji-wrapper'>" +
      charHTML + "<span class='keywords'>" + project["keywords"] + "</span></li>")
    counter++
  })
  $jq(document).trigger('source-github:ready')
  $jq(document).trigger('search:ready')
})
/*
$jq(document).on('source-github:ready', function () {  
  $jq.getJSON('//monitoringartist.github.io/zabbix-searcher/sources/share-zabbix.json', function (projects) {
    var container = $jq('.container')
    Object.keys(projects).forEach( function (key) {
      var project = projects[key]
      var charHTML
      charHTML = "<div><a target='_blank' onclick=\"ga('send', 'event', 'click', 'Share: " + project['name'] + "'); return true;\" title='#" + counter + " " + project['name'] + "' href='" + 
        project['url'] + "'><i class='fa fa-" + project['icon'] + "'></i> " + project['name'] + "</a></div>"
      container.append("<li class='result emoji-wrapper'>" +
        charHTML + "<span class='keywords'>" + project["keywords"] + "</span></li>")
      counter++
    })
    $jq(document).trigger('source-share:ready')
  })
})  
$jq(document).on('source-share:ready', function () {
  $jq.getJSON('//monitoringartist.github.io/zabbix-searcher/sources/zabbix-wiki.json', function (projects) {
    var container = $jq('.container')
    Object.keys(projects).forEach( function (key) {
      var project = projects[key]
      var charHTML
      charHTML = "<div><a target='_blank' onclick=\"ga('send', 'event', 'click', 'Wiki: " + project['name'] + "'); return true;\" title='#" + counter + " " + project['name'] + "' href='" + 
        project['url'] + "'><i class='fa fa-" + project['icon'] + "'></i> " + project['name'] + "</a></div>"
      container.append("<li class='result emoji-wrapper'>" +
        charHTML + "<span class='keywords'>" + project["keywords"] + "</span></li>")
      counter++
    })
    $jq(document).trigger('source-zabbix:ready')
  })
})
$jq(document).on('source-zabbix:ready', function () {
  $jq.getJSON('//monitoringartist.github.io/zabbix-searcher/sources/zabbix-com.json', function (projects) {
    var container = $jq('.container')
    Object.keys(projects).forEach( function (key) {
      var project = projects[key]
      var charHTML
      charHTML = "<div><a target='_blank' onclick=\"ga('send', 'event', 'click', 'Wiki: " + project['name'] + "'); return true;\" title='#" + counter + " " + project['name'] + "' href='" +
        project['url'] + "'><i class='fa fa-" + project['icon'] + "'></i> " + project['name'] + "</a></div>"
      container.append("<li class='result emoji-wrapper'>" +
        charHTML + "<span class='keywords'>" + project["keywords"] + "</span></li>")
      counter++
    })
    $jq(document).trigger('search:ready')
  })
})
*/

$jq(document).keydown(function (e) { focusOnSearch(e) })

$jq(document).on('keydown', '.emoji-wrapper input', function (e) {
  $jq(".input-search").blur()
  focusOnSearch(e)
})

$jq(document).on('click', '.js-clear-search, .mojigroup.active', function () {
  location.hash = ""
  return false
})

$jq(document).on('click', '.js-contribute', function () {
  ga('send', 'event', 'contribute', 'click')
})
