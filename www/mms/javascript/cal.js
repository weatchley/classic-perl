// +------------------------------------------------------------+
// | Popup Calendar                  Last Modified 10/02/2002   |
// | Web Site:                       http://www.yxscripts.com   |
// | EMail:                          m_yangxin@hotmail.com      |
// +------------------------------------------------------------+
// | Copyright 2002  Xin Yang   All Rights Reserved.            |
// +------------------------------------------------------------+
//
//
// $Source: /data/dev/rcs/mms/javascript/RCS/cal.js,v $
//
// $Revision: 1.2 $
//
// $Date: 2005/08/18 18:17:29 $
//
// $Author: atchleyb $
//
// $Locker:  $
//
// $Log: cal.js,v $
// Revision 1.2  2005/08/18 18:17:29  atchleyb
// changed option to make year selectable
//
// Revision 1.1  2003/11/12 21:18:26  atchleyb
// Initial revision
//
//

// default settings
var fontFace="verdana";
var fontSize=9;

var titleWidth=96;
var titleMode=2;
var dayWidth=12;
var dayDigits=1;

var titleColor="#cccccc";
var daysColor="#cccccc";
var bodyColor="#ffffff";
var dayColor="#ffffff";
var currentDayColor="#333333";
var footColor="#cccccc";
var borderColor="#333333";

var titleFontColor = "#333333";
var daysFontColor = "#333333";
var dayFontColor = "#333333";
var currentDayFontColor = "#ffffff";
var footFontColor = "#333333";

var calFormat = "mm/dd/yyyy";
// ------

// codes
var cal="cal";
var cals = new Array();
var currentCal=null;

var months=new Array("January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December");
var days=new Array("Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday");

var isN6=(navigator.userAgent.indexOf("Gecko")!=-1);
var isN4=(document.layers)?true:false;
var isIE=(document.all)?true:false;

var layers=null;
if (isIE) {
  layers=document.all;
}
else if (isN4) {
  layers=document.layers;
  fontSize+=2;
}

var span2="</span>";

function span1(color) {
  return "<span style='font-family:"+fontFace+"; font-size:"+fontSize+"px; color:"+color+";'>";
}

function calOBJ(name, id, field, form) {
  this.name = name;
  this.id = id;
  this.field = field;
  this.formName = form;
  this.form = null
}

function setFont(font, size) {
  if (font != "") {
    fontFace=font;
  }
  if (size > 0) {
    fontSize=size;

    if (isN4) {
      fontSize+=2;
    }
  }
}

function setWidth(tWidth, tMode, dWidth, dDigits) {
  if (tWidth > 0) {
    titleWidth=tWidth;
  }
  if (tMode == 1 || tMode == 2) {
    titleMode=tMode;
  }
  if (dWidth > 0) {
    dayWidth=dWidth;
  }
  if (dDigits ==1 || dDigits == 3) {
    dayDigits=dDigits;
  }
}

function setColor(tColor, dsColor, bColor, dColor, cdColor, fColor, bdColor) {
  if (tColor != "") {
    titleColor=tColor;
  }
  if (dsColor != "") {
    daysColor=dsColor;
  }
  if (bColor != "") {
    bodyColor=bColor;
  }
  if (dColor != "") {
    dayColor=dColor;
  }
  if (cdColor != "") {
    currentDayColor=cdColor;
  }
  if (fColor != "") {
    footColor=fColor;
  }
  if (bdColor != "") {
    borderColor=bdColor;
  }
}

function setFontColor(tColorFont, dsColorFont, dColorFont, cdColorFont, fColorFont) {
  if (tColorFont != "") {
    titleFontColor=tColorFont;
  }
  if (dsColorFont != "") {
    daysFontColor=dsColorFont;
  }
  if (dColorFont != "") {
    dayFontColor=dColorFont;
  }
  if (cdColorFont != "") {
    currentDayFontColor=cdColorFont;
  }
  if (fColorFont != "") {
    footFontColor=fColorFont;
  }
}

function setFormat(format) {
  calFormat = format;
}

function addCalendar(name, id, field, form) {
  cals[cals.length] = new calOBJ(name, id, field, form);
}

function findCalendar(name) {
  for (var i = 0; i < cals.length; i++) {
    if (cals[i].name == name) {
      if (cals[i].form == null) {
        if (cals[i].formName == "") {
          if (document.forms[0]) {
            cals[i].form = document.forms[0];
          }
          else {
            return null;
          }
        }
        else if (document.forms[cals[i].formName]) {
          cals[i].form = document.forms[cals[i].formName];
        }
        else {
          return null;
        }
      }

      return cals[i];
    }
  }

  return null;
}

function getDayName(y,m,d) {
  var wd=new Date(y,m,d);
  return days[wd.getDay()].substring(0,3);
}

function getMonthFromName(m3) {
  for (var i = 0; i < months.length; i++) {
    if (months[i].toLowerCase().substring(0,3) == m3.toLowerCase()) {
      return i;
    }
  }

  return 0;
}

function getFormat() {
  var calF = calFormat;

  calF = calF.replace(/\\/g, '\\\\');
  calF = calF.replace(/\//g, '\\\/');
  calF = calF.replace(/\[/g, '\\\[');
  calF = calF.replace(/\]/g, '\\\]');
  calF = calF.replace(/\(/g, '\\\(');
  calF = calF.replace(/\)/g, '\\\)');
  calF = calF.replace(/\{/g, '\\\{');
  calF = calF.replace(/\}/g, '\\\}');
  calF = calF.replace(/\</g, '\\\<');
  calF = calF.replace(/\>/g, '\\\>');
  calF = calF.replace(/\|/g, '\\\|');
  calF = calF.replace(/\*/g, '\\\*');
  calF = calF.replace(/\?/g, '\\\?');
  calF = calF.replace(/\+/g, '\\\+');
  calF = calF.replace(/\^/g, '\\\^');
  calF = calF.replace(/\$/g, '\\\$');

  calF = calF.replace(/dd/i, '\\d\\d');
  calF = calF.replace(/mm/i, '\\d\\d');
  calF = calF.replace(/yyyy/i, '\\d\\d\\d\\d');
  calF = calF.replace(/day/i, '\\w\\w\\w');
  calF = calF.replace(/mon/i, '\\w\\w\\w');

  return new RegExp(calF);
}

function getDateNumbers(date) {
  var y, m, d;

  var yIdx = calFormat.search(/yyyy/i);
  var mIdx = calFormat.search(/mm/i);
  var m3Idx = calFormat.search(/mon/i);
  var dIdx = calFormat.search(/dd/i);

  y=date.substring(yIdx,yIdx+4)-0;
  if (mIdx != -1) {
    m=date.substring(mIdx,mIdx+2)-1;
  }
  else {
    var m = getMonthFromName(date.substring(m3Idx,m3Idx+3));
  }
  d=date.substring(dIdx,dIdx+2)-0;

  return new Array(y,m,d);
}

function hideCal() {
  if (isIE) {
    layers[cal].innerHTML="";
  }
  else if (isN4) {
    layers[cal].visibility="hide";
    layers[cal].document.open();
    layers[cal].document.close();
  }
  else if (isN6) {
    document.getElementById(cal).innerHTML="";
  }
}

function getLeftIE(x,m) {
  var dx=0;
  if (x.tagName=="TD"){
    dx=x.offsetLeft;
  }
  else if (x.tagName=="TABLE") {
    dx=x.offsetLeft;
    if (m) { dx+=(x.cellPadding!=""?parseInt(x.cellPadding):2); m=false; }
  }
  return dx+(x.parentElement.tagName=="BODY"?0:getLeftIE(x.parentElement,m));
}
function getTopIE(x,m) {
  var dy=0;
  if (x.tagName=="TR"){
    dy=x.offsetTop;
  }
  else if (x.tagName=="TABLE") {
    dy=x.offsetTop;
    if (m) { dy+=(x.cellPadding!=""?parseInt(x.cellPadding):2); m=false; }
  }
  return dy+(x.parentElement.tagName=="BODY"?0:getTopIE(x.parentElement,m));
}

function getLeftN4(l) { return l.pageX; }
function getTopN4(l) { return l.pageY; }

function getLeftN6(l) { return l.offsetLeft; }
function getTopN6(l) { return l.offsetTop; }

function lastDay(d) {
  var yy=d.getFullYear(), mm=d.getMonth();
  for (var i=31; i>=28; i--) {
    var nd=new Date(yy,mm,i);
    if (mm == nd.getMonth()) {
      return i;
    }
  }
}

function firstDay(d) {
  var yy=d.getFullYear(), mm=d.getMonth();
  var fd=new Date(yy,mm,1);
  return fd.getDay();
}

function dayDisplay(i) {
  if (dayDigits == 0) {
    return days[i];
  }
  else {
    return days[i].substring(0,dayDigits);
  }
}

function calTitle(d) {
  var yy=d.getFullYear(), mm=months[d.getMonth()];
  var s;

  if (titleMode == 2) {
    s="<tr align='center' bgcolor='"+titleColor+"'><td colspan='7'><table cellpadding='0' cellspacing='0' border='0'><tr align='center' valign='middle'><td>"+span1(titleFontColor)+"<b><a href='javascript:prepYear("+yy+")' style='text-decoration:none; color:"+titleFontColor+";'>&nbsp;&#171;&nbsp;</a></b>"+span2+"</td><td width='"+titleWidth+"'><b>"+span1(titleFontColor)+yy+span2+"</b></td><td>"+span1(titleFontColor)+"<b><a href='javascript:nextYear("+yy+")' style='text-decoration:none; color:"+titleFontColor+";'>&nbsp;&#187;&nbsp;</a></b>"+span2+"</td></tr><tr align='center' valign='middle'><td>"+span1(titleFontColor)+"<b><a href='javascript:prepMonth("+d.getMonth()+")' style='text-decoration:none; color:"+titleFontColor+";'>&nbsp;&#171;&nbsp;</a></b>"+span2+"</td><td width='"+titleWidth+"'><b>"+span1(titleFontColor)+mm+span2+"</b></td><td>"+span1(titleFontColor)+"<b><a href='javascript:nextMonth("+d.getMonth()+")' style='text-decoration:none; color:"+titleFontColor+";'>&nbsp;&#187;&nbsp;</a></b>"+span2+"</td></tr></table></td></tr><tr align='center' bgcolor='"+daysColor+"'>";
  }
  else {
    s="<tr align='center' bgcolor='"+titleColor+"'><td colspan='7'><table cellpadding='0' cellspacing='0' border='0'><tr align='center' valign='middle'><td>"+span1(titleFontColor)+"<b><a href='javascript:prepMonth("+d.getMonth()+")' style='text-decoration:none; color:"+titleFontColor+";'>&nbsp;&#171;&nbsp;</a></b>"+span2+"</td><td width='"+titleWidth+"'><nobr><b>"+span1(titleFontColor)+mm+" "+yy+span2+"</b></nobr></td><td>"+span1(titleFontColor)+"<b><a href='javascript:nextMonth("+d.getMonth()+")' style='text-decoration:none; color:"+titleFontColor+";'>&nbsp;&#187;&nbsp;</a></b>"+span2+"</td></tr></table></td></tr><tr align='center' bgcolor='"+daysColor+"'>";
  }

  for (var i=0; i<days.length; i++) {
    s+="<td width='"+dayWidth+"'>"+span1(daysFontColor)+dayDisplay(i)+span2+"</td>";
  }

  s+="</tr>";

  return s;
}

function calHeader() {
  return "<table bgcolor='"+borderColor+"' cellspacing='0' cellpadding='1'><tr><td><table cellspacing='1' cellpadding='3' border='0'>";
}

function calFooter() {
  return "<tr bgcolor='"+footColor+"'><td colspan='7' align='center'>"+span1(footColor)+"<b><a href='javascript:hideCal()' style='text-decoration:none; color:"+footFontColor+";'>[close]</a>&nbsp;&nbsp;<a href='javascript:clearDate()' style='text-decoration:none; color:"+footFontColor+";'>[clear]</a></b>"+span2+"</td></tr></table></td></tr></table>";
}

function calBody(d,day) {
  var s="", dayCount=1, fd=firstDay(d), ld=lastDay(d);
  for (var i=0; i<6; i++) {
    s+="<tr align='center' bgcolor='"+bodyColor+"'>";
    for (var j=0; j<7; j++) {
      if (i*7+j<fd || dayCount>ld) {
        s+="<td>"+span1(dayFontColor)+"&nbsp;"+span2+"</td>";
      }
      else {
        var bgColor=dayColor;
        var fgColor=dayFontColor;
        if (dayCount==day) { 
          bgColor=currentDayColor; 
          fgColor=currentDayFontColor; 
        }
        
        s+="<td bgcolor='"+bgColor+"'>"+span1(fgColor)+"<a href='javascript:pickDate("+dayCount+")' style='text-decoration:none; color:"+fgColor+";'>"+(dayCount++)+"</a>"+span2+"</td>";
      }
    }
    s+="</tr>";
  }

  return s;
}

function prepYear(y) {
  cY=y-1;
  var nd=new Date(cY,cM,1);
  changeCal(nd);
}

function nextYear(y) {
  cY=y+1;
  var nd=new Date(cY,cM,1);
  changeCal(nd);
}

function prepMonth(m) {
  cM=m-1;
  if (cM<0) { cM=11; cY--; }
  var nd=new Date(cY,cM,1);
  changeCal(nd);
}

function nextMonth(m) {
  cM=m+1;
  if (cM>11) { cM=0; cY++;}
  var nd=new Date(cY,cM,1);
  changeCal(nd);
}

function changeCal(d) {
  var dd = 0;

  if (currentCal != null) {
    var calRE = getFormat();

    if (currentCal.form[currentCal.field].value!="" && calRE.test(currentCal.form[currentCal.field].value)) {
      var cd = getDateNumbers(currentCal.form[currentCal.field].value);
      if (cd[0] == d.getFullYear() && cd[1] == d.getMonth()) {
        dd=cd[2];
      }
    }
    else {
      var cd = new Date();
      if (cd.getFullYear() == d.getFullYear() && cd.getMonth() == d.getMonth()) {
        dd=cd.getDate();
      }
    }
  }

  var calendar=calHeader()+calTitle(d)+calBody(d,dd)+calFooter();

  if (isIE) {
    layers[cal].innerHTML=calendar;
  }
  else if (isN4) {
    layers[cal].document.open();
    layers[cal].document.writeln(calendar);
    layers[cal].document.close();
  }
  else if (isN6) {
    document.getElementById(cal).innerHTML=calendar;
  }
}

function showCal(name) {
  var d=new Date();

  currentCal = findCalendar(name);

  if (currentCal != null) {
    var calRE = getFormat();

    if (currentCal.form[currentCal.field].value!="" && calRE.test(currentCal.form[currentCal.field].value)) {
      var cd = getDateNumbers(currentCal.form[currentCal.field].value);
      d=new Date(cd[0],cd[1],cd[2]);

      cY=cd[0];
      cM=cd[1];
      dd=cd[2];
    }
    else {
      cY=d.getFullYear();
      cM=d.getMonth();
      dd=d.getDate();
    }

    var calendar=calHeader()+calTitle(d)+calBody(d,dd)+calFooter();

    if (isIE) {
      layers[cal].style.pixelTop=getTopIE(layers[currentCal.id],true);
      layers[cal].style.pixelLeft=getLeftIE(layers[currentCal.id],true);
      layers[cal].innerHTML=calendar;

      layers[cal].style.clip = "rect(0px; " + layers[cal].children[0].offsetWidth + "px; " + layers[cal].children[0].offsetHeight + "px; 0px)";
    }
    else if (isN4) {
      layers[cal].top=getTopN4(layers[currentCal.id]);
      layers[cal].left=getLeftN4(layers[currentCal.id]);
      layers[cal].document.open();
      layers[cal].document.writeln(calendar);
      layers[cal].document.close();
      layers[cal].visibility="show";
    }
    else if (isN6) {
      var l=document.getElementById(currentCal.id);
      layer=document.getElementById(cal);
      layer.style.top=getTopN6(l)+"px";
      layer.style.left=getLeftN6(l)+"px";
      layer.innerHTML=calendar;
    }
  }
  else {
    alert("Calendar ["+name+"] not found");
  }
}

function get2Digits(n) {
  return ((n<10)?"0":"")+n;
}

function clearDate() {
  currentCal.form[currentCal.field].value="";
  hideCal();
}

function pickDate(d) {
  var date=calFormat;
  date = date.replace(/yyyy/i, cY);
  date = date.replace(/mm/i, get2Digits(cM+1));
  date = date.replace(/MON/, months[cM].substring(0,3).toUpperCase());
  date = date.replace(/Mon/i, months[cM].substring(0,3));
  date = date.replace(/dd/i, get2Digits(d));
  date = date.replace(/DAY/, getDayName(cY,cM,d).toUpperCase());
  date = date.replace(/day/i, getDayName(cY,cM,d));

  currentCal.form[currentCal.field].value=date;

  hideCal();
}
// ------

// the cal layer
if (isN4) {
  document.writeln("<layer id='"+cal+"'>&nbsp;</layer>");
}
else {
  document.writeln("<div id='"+cal+"' style='position:absolute;'>&nbsp;</div>");
}
// ----

// user functions
function checkDate(name) {
  var thisCal = findCalendar(name);

  if (thisCal != null) {
    var calRE = getFormat();

    if (calRE.test(thisCal.form[thisCal.field].value)) {
      return 0;
    }
    else {
      return 1;
    }
  }
  else {
    return 2;
  }
}

function getCurrentDate() {
  var date=calFormat, d = new Date();
  date = date.replace(/yyyy/i, d.getFullYear());
  date = date.replace(/mm/i, get2Digits(d.getMonth()+1));
  date = date.replace(/dd/i, get2Digits(d.getDate()));

  return date;
}

function compareDates(date1, date2) {
  var calRE = getFormat();
  var d1, d2;

  if (calRE.test(date1)) {
    d1 = getDateNumbers(date1);
  }
  else {
    d1 = getDateNumbers(getCurrentDate());
  }

  if (calRE.test(date2)) {
    d2 = getDateNumbers(date2);
  }
  else {
    d2 = getDateNumbers(getCurrentDate());
  }

  var dStr1 = d1[0] + "" + d1[1] + "" + d1[2];
  var dStr2 = d2[0] + "" + d2[1] + "" + d2[2];

  if (dStr1 == dStr2) {
    return 0;
  }
  else if (dStr1 > dStr2) {
    return 1;
  }
  else {
    return -1;
  }
}

function getNumbers(date) {
  var calRE = getFormat();
  var y, m, d;

  if (calRE.test(date)) {
    var yIdx = calFormat.search(/yyyy/i);
    var mIdx = calFormat.search(/mm/i);
    var m3Idx = calFormat.search(/mon/i);
    var dIdx = calFormat.search(/dd/i);

    y=date.substring(yIdx,yIdx+4);
    if (mIdx != -1) {
      m=date.substring(mIdx,mIdx+2);
    }
    else {
      m = getMonthFromName(date.substring(m3Idx,m3Idx+3))+1;
    }
    d=date.substring(dIdx,dIdx+2);

    return new Array(y,m,d);
  }
  else {
    return new Array("", "", "");
  }
}
// ------

