var NROW = 8;
var NCOL = 8;

var divs = [];
var demo = false;
var timezone = 9; // Japan

window.onload = function() {
    var params = getGETParams();
    demo = (params["demo"] == 1);
    if(params["timezone"] != null)
	timezone = parseInt(params["timezone"]);

    for(var i = 0; i < NROW * NCOL; i++) {
	var d = document.createElement("div");
	d.classList.add("div"+i);
	d.style.cssText = "background-color: white";
	document.body.appendChild(d);
	divs.push(d);
    }
    update();
}

function getGETParams() {
    var gets = window.location.search.substring(1).split("&");
    var ret = {};
    for(var i = 0; i < gets.length; i++) {
	var kv = gets[i].split("=");
	if(kv.length == 2)
	    ret[kv[0]] = kv[1];
	else
	    ret[kv[0]] = true;
    }
    return ret;
}

function updateDivs(val, divIds) {
    for(var i = 0; i < divIds.length; i++) {
	var c = ((val&(1<<(i*3+0)) ? 0xFF : 0) << 16)
	    | ((val&(1<<(i*3+1)) ? 0xFF : 0) << 8)
	    | ((val&(1<<(i*3+2)) ? 0xFF : 0) << 0);
	var cs = c.toString(16);
	while(cs.length < 6)
	    cs = "0"+cs;
	divs[divIds[i]].style.cssText = "background-color: #"+cs;
    }
}

var lastDate = null;
function update() {
    requestAnimationFrame(update);

    var d = (!demo || lastDate == null ? new Date(new Date().getTime()+1000*60*60*timezone) : lastDate);
    updateDivs(d.getUTCHours(),   [0, 1]);
    updateDivs(d.getUTCMinutes(), [2, 3]);
    updateDivs(d.getUTCSeconds(), [4, 5]);
    updateDivs(Math.floor(d.getUTCMilliseconds()/1000*64), [6, 7]);

    updateDivs(d.getUTCFullYear()-1900, [8, 9, 10]);
    updateDivs(d.getUTCMonth(), [11, 12]);
    updateDivs(d.getUTCDate(), [13, 14]);
    updateDivs(d.getUTCDay(), [15]);

    // Reference: http://koyomi8.com/reki_doc/doc_0250.htm
    var moonAge = (((d.getUTCFullYear()-2009)%19)*11+(d.getUTCMonth()+1)+(d.getUTCDate()+1)) % 30;
    updateDivs(moonAge, [16, 17]);

    lastDate = d;
    if(demo) {
	lastDate = new Date(lastDate.getTime()+123456);
    }
}
