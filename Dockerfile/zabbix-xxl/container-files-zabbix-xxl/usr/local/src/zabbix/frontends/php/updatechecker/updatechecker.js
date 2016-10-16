var xxlCookieNameCheck = "xxl_update_version_check";
var xxlCookieNameShow = "xxl_update_version_show";
var xxlCurrentVersion = "3.2.0 (2016-08-08)";

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

function displayInfo() {
    var cookieChk = getCookie(xxlCookieNameShow);
    if (cookieChk == undefined) {
        var cookieChk2 = getCookie(xxlCookieNameCheck);
        if (cookieChk2 != null && cookieChk2 != "off") {
            cookieChk2 = "xx";
            var message = '<div id="info" style="z-index:1000; position:fixed; width:100%; display:block; opacity:0.9; background-color:#323232; color:#fff; padding:1em 0 0 1.5em; font-size:18px; top:0;">';
            message = message + cookieChk2;
            message = message + "<p>New updated Docker image is available. Please ask your administrator to pull <b><a href='https://hub.docker.com/r/monitoringartist/zabbix-xxl/' target='_blank'>monitoringartist/zabbix-xxl:latest</a></b>.</p>"
            message = message + '<p><a style="cursor:pointer;" onClick=\'JavaScript:closeInfo();\' title="X Close information about available update">Close</a></p>';
            message = message + "</div>";
            jQuery('div[role="navigation"]').append(message);
        }
    }
    return true;
}
function hideInfo() {
    document.getElementById('info').style.display = 'none';
}
// ignore new version for 7 days
function closeInfo() {
    setCookie(xxlCookieNameShow, null, 7);
    hideInfo();
}
function closeInfo() {
    setCookie(xxlCookieNameShow, null, 7);
    hideInfo();
}
function setCookie(c_name, value, exdays) {
    var exdate = new Date();
    exdate.setDate(exdate.getDate() + exdays);
    var c_value = escape(value) + ((exdays == null) ? "" : "; expires=" + exdate.toUTCString() + "; path=/");
    document.cookie = c_name + "=" + c_value;
}
// check version once per day
function checkCookie() {
    var cookieChk = getCookie(xxlCookieNameCheck);
    if (cookieChk == null || cookieChk == "") {
        jQuery.getJSON('https://raw.githubusercontent.com/monitoringartist/zabbix-xxl/master/latest', function(data) {
            if (xxlCurrentVersion != data.version) {
                console.log(data.text);
                //displayInfo(data.text);
                setCookie(xxlCookieNameCheck, data.text, 1);
            }
        });
    } else {
        setCookie(xxlCookieNameCheck, 'off', 1);
    }

}
jQuery(document).ready(function() {
    checkCookie();
    displayInfo();
});
