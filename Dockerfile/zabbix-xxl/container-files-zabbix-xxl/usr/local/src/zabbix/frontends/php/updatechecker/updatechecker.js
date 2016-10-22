var xxlUpdateCheck = "xxl_updatechecker";
var xxlCurrentVersion = "";
var xxlUpdateUrl = 'https://raw.githubusercontent.com/monitoringartist/zabbix-xxl/master/latest';

// check version once per day
function updateCheck() {
    var cookieChk = getCookie(xxlUpdateCheck);
    if (cookieChk == undefined) {
        var jqxhr = jQuery.getJSON(xxlUpdateUrl, function(data) {
            if (xxlCurrentVersion != data.version && data.display == 1) {
                setCookie(xxlUpdateCheck, data.text, 1);
                console.log(data.text);
                displayInfo();
            } else {
              // version match - off for a day
              setCookie(xxlUpdateCheck, "off", 1);
            }
        })
          .fail(function() {
              // unsucesfull json request - off for a day
              setCookie(xxlUpdateCheck, "off", 1);
          });
    }
    if (cookieChk != undefined && cookieChk != "off") {
       displayInfo();
    }
}
// display info about new available update
function displayInfo() {
    var cookieChk = getCookie(xxlUpdateCheck);
    if (cookieChk != undefined && cookieChk != "off") {
            var message = '<div id="info" style="z-index:1000; position:fixed; width:100%; display:block; opacity:0.9; background-color:#323232; color:#fff; padding:1em 0 0 1.5em; font-size:18px; top:0;">';
            message = message + cookieChk;
            message = message + '<p><a style="cursor:pointer;font-size:80%;font-style: italic;" onClick=\'JavaScript:closeInfo();\' title="X Close information about available update">Close</a></p>';
            message = message + "</div>";
            jQuery('div[role="navigation"]').append(message);
    }
    return true;
}
// disable update checker for 7 days
function closeInfo() {
    jQuery("#info").hide('slow');
    setCookie(xxlUpdateCheck, "off", 7);
}

function setCookie(c_name, value, exdays) {
    var exdate = new Date();
    exdate.setDate(exdate.getDate() + exdays);
    var c_value = escape(value) + ((exdays == null) ? "" : "; expires=" + exdate.toUTCString() + "; path=/");
    document.cookie = c_name + "=" + c_value;
}

function getCookie(c_name) {
    var i, x, y, ARRcookies = document.cookie.split(";");
    for (i = 0; i < ARRcookies.length; i++) {
        x = ARRcookies[i].substr(0, ARRcookies[i].indexOf("="));
        y = ARRcookies[i].substr(ARRcookies[i].indexOf("=") + 1);
        x = x.replace(/^\s+|\s+$/g, "");
        if (x == c_name) {
            return unescape(y);
        }
    }
}

jQuery(document).ready(function() {
    updateCheck();
});
