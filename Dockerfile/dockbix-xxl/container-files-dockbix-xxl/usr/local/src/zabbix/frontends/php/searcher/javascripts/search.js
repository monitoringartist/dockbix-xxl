$jq(document).on('search:ready', function () {
  if (location.hash.length) {
    search($jq('.speedy-filter').val(location.hash.substr(1)).val().replace('_',' '))
  } else {
    search()
  }
})

function search (keyword) {
  var keyword = typeof keyword === 'undefined' ? '' : keyword
  $jq('.keyword').text(keyword)
  keyword = keyword.trim()

  if (window.speedy_keyword !== keyword) {
    window.speedy_keyword = keyword
    if (keyword.length) {
      $jq('.result').hide()
      $jq('.result').each(function () {
        if($jq(this).text().toLowerCase().indexOf(keyword.toLowerCase()) > -1) {
        $jq(this).show()
        }
      })
    } else {
      $jq('.result').show()
    }
  }
  setRelatedDOMVisibility(keyword)
}

function setRelatedDOMVisibility (keyword) {
  var foundSomething = Boolean($jq('.result:visible').length)
  $jq('.no-results').toggle( !foundSomething )

  if (keyword.length >= 3) {
    if (!foundSomething) {
      ga('send', 'event', 'search', 'no results for ' + keyword)
    } else {
      ga('send', 'event', 'search', keyword)
    }
  }
}

$jq(document).on('search keyup', '.speedy-filter', function () {
  location.hash = $jq(this).val().replace(' ', '_')
})

$jq(document).on('click', '.speedy-remover', function () {
  $jq('.speedy-filter').val('')
  $jq('.result').show()
  location.hash = ''
})

window.onhashchange = function () {
  search($jq('.speedy-filter').val(location.hash.substr(1)).val().replace('_',' '))
  $jq('[href^="#"]').removeClass('active')
  $jq("[href='#{location.hash}']").addClass('active')
}
