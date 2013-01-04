// Comment/Response Database Utilities
//
// $Source: /data/dev/eis/javascript/RCS/utilities.js,v $
//
// $Revision: 1.13 $
//
// $Date: 2001/05/17 18:39:27 $
//
// $Author: atchleyb $
//
// $Locker:  $
//
// $Log: utilities.js,v $
// Revision 1.13  2001/05/17 18:39:27  atchleyb
// added more pad lines to the textbox resize function
//
// Revision 1.12  2001/04/27 15:47:50  atchleyb
// updated expandTextBox to not shrink smaller than the default 'rows' size
//
// Revision 1.11  2001/04/26 00:17:32  atchleyb
// updated the textbox resizer function to use images instead of text
//
// Revision 1.10  2001/04/02 23:20:34  atchleyb
// added new text box resizer function
//
// Revision 1.9  2001/03/09 17:30:54  atchleyb
// updated to use the new title_bar.pl script for the status frame
//
// Revision 1.8  2000/07/14 17:45:20  atchleyb
// removed function to print comment/response
//
// Revision 1.7  2000/07/13 16:10:01  atchleyb
// added function to print a comment/response
//
// Revision 1.6  2000/04/11 22:52:02  atchleyb
// added RCS variables to header
//
// Revision 1.5  2000/04/11 21:19:44  atchleyb
// Javascript utilities for the CRD
//
//
// 

// set up global hash
var global_hash = new Object;

//function to disable edit on readonly fields
function on_readonly (what) {
  if (navigator.appName == 'Netscape') {
    what.blur();
  }
}

// A utility function that returns true if a string contains only
// whitespace characters.
function isblank(s)
{
    if (s.length == 0) return true;
    for(var i = 0; i < s.length; i++) {
        var c = s.charAt(i);
        if ((c != ' ') && (c != '\n') && (c != '\t') && (c !='\r')) return false;
    }
    return true;
}

// function that returns true if a string contains only numbers
function isnumeric(s)
{
    if (s.length == 0) return false;
    for(var i = 0; i < s.length; i++) {
        var c = s.charAt(i);
        if ((c < '0') || (c > '9')) return false;
    }

    return true;
}

// funtion to show the properties of an object (used mostly for debuging)
function show_props(obj, obj_name) {
          var result = ""
          var col = 1;
          for (var i in obj)
             if (i != 'innerHTML' && i != 'innerText' && i != 'outerHTML' && i != 'outerText') {
                    if (col == 1) {
                        result += obj_name + "." + i + " = " + obj[i];
                        col = col + 1;
                    } else {
                        result += "          " + obj_name + "." + i + " = " + obj[i] + "\n<br>";
                        col = 1;
                    }
             }
          return result
}

// Routine to pop open a new window
function PopIt(location,name){ 
  popup = window.open(location,name,"height=500,width=700,scrollbars=yes");  
}

// function returns true if the given year is a leap year
function isleapyear(year)
  {
  var returnvalue = ((year % 4 == 0) && (year % 100 != 0)) || (year % 400 == 0); 
  return (returnvalue);  
  }

// function returns null string "" if a date is valid or an error string if it is invalid describing the
// first encountered reason that the date is invalid.
// pastdateok should be true if dates from the past are valid
// futuredateok should be true if dates from the future are valid
// fulldatetime should be true if the hour, minute, second, millisecond are to be considered when testing for past and future dates
// the year must be  a 4 digit year (0026 = 26 AD)
function validate_date(year, month, day, hour, minute, second, millisecond, pastdateok, futuredateok, fulldatetime) {
   var returnvalue = "";
   var testdate;
   var months = new Array('', "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December");
   if (year.length < 4) {
      return ("Entered year must have four digits");
   }
   if ((month < 1) || (month > 12)) {
      return ("Entered month is invalid");
   }
   switch (month) {
      case 4: 
      case "4":
      case "04":
      case 6:
      case "6":
      case "06":
      case 9:
      case "9":
      case "09":
      case 11:
      case "11":
         if (day > 30) {
            returnvalue = months[month] + " only has 30 days";
         }
         break;
      case 2:
      case "2":
      case "02":
         if (isleapyear(year)) {
            returnvalue = (day > 29) ? "February " + year + " only has 29 days" : "";
         } else {
            returnvalue = (day > 28) ? "February " + year + " only has 28 days" : "";
         }
         break;
      default:
         if (day > 31) {
            returnvalue = months[month] + " only has 31 days";
         }
   }
   if (returnvalue != "") { // return because the following is invalid if we've determined we have an invalid date.
      return (returnvalue);
   }
   testdate = new Date(year, month-1, day, hour, minute, second, millisecond);
   today = new Date();
   if (!(fulldatetime)) {
      today = new Date(today.getFullYear(), today.getMonth(), today.getDate(), 0,0,0,0);
   }
   if ((!(pastdateok)) && (testdate.getTime() < today.getTime())) {
      returnvalue = "Please enter a date in the future";
   }
   if ((!(futuredateok)) && (testdate.getTime() > today.getTime())) {
      returnvalue = "Please enter a date in the past";
   }
   return (returnvalue);
}

function showImage(imagePath, newtitle) {
   //document['titleimage'].src = imagePath + '/titles/' + newtitle + '.gif';
   document['titleimage'].src = '/cgi-bin/eis/text_labels.pl?width=390&text=', newtitle, '&size=15&parsetitle=T';
}

// routine to set the image for the graphic text label
function doSetTextImageLabel(label) {
    //parent.status.SetImageLabel(label);
    parent.frames[1].SetImageLabel(label);
}

function writeTitleBar(javascriptPath, imagePath, title, username, userid, schema) {
   doSetTextImageLabel(title);
   //if ((username == o_username) && (userid == o_userid) && (schema == o_schema)) {
   //   showImage(imagePath, title);
   //} else {
   //   document.open();
   //   document.writeln('<html>');
   //   document.writeln('<head>');
   //   document.writeln('<script src=', javascriptPath, '/utilities.js></script>');
   //   document.writeln('<script language=javascript><!--');
   //   document.writeln('var o_username = \'', username, '\';');
   //   document.writeln('var o_userid = \'', userid, '\';');
   //   document.writeln('var o_schema = \'', schema, '\';');
   //   document.writeln('//--></script>');
   //   document.writeln('</head>');
   //   document.writeln('<body background=', imagePath, '/background.gif text=#000099 link=#0000ff vlink=#0000ff alink=#0000ff topmargin=0 leftmargin=0><center>');
   //   document.writeln('<table border=0 cellspacing=0 cellpadding=0 width=750><tr>');
   //   document.writeln('<td align=center colspan=3><img src=', imagePath, '/separator.gif width=750 height=14 border=0></td></tr>');
   //   document.writeln('<tr><td width=24% align=left><table cellpadding=3 cellspacing=0 border=1><tr><td><b><font size=2 color=#003000>User/ID:&nbsp;&nbsp;</font>');
   //   var color = (username == 'None') ? 'ff0000' : '000090';
   //   document.writeln('<font size=2 color=#', color, '>', username, '</font>');
   //   document.writeln('<font size=2 color=#003000> / </font>');
   //   color = (userid == 'None') ? 'ff0000' : '000090';
   //   document.writeln('<font size=2 color=#', color, '>', userid, '</font>');
   //   document.writeln('</b></td></tr></table></td>');
   //   //document.writeln('<td align=center><img src=', imagePath, '/titles/', title, '.gif name=titleimage width=390 height=25></td>');
   //   document.writeln('<td align=center><img src="/cgi-bin/eis/text_labels.pl?width=390&text=', title, '&size=15&parsetitle=T" name=titleimage width=390 height=25></td>');
   //   document.writeln('<td width=24% align=right><table cellpadding=3 cellspacing=0 border=1><tr><td><b>');
   //   document.writeln('<font size=2 color=#003000>Database:&nbsp&nbsp;</font>');
   //   color = (schema == 'None') ? 'ff0000' : '000090';
   //   document.writeln('<font size=2 color=#', color, '>', schema, '</font>');   document.writeln('</b></td></tr></table></td></tr>');
   //   document.writeln('<tr><td align=center colspan=3><img src=', imagePath, '/separator.gif width=750 height=14 border=0></td>');
   //   document.writeln('</tr></table></center></body></html>');
   //   document.close();
   //}
}

function expandTextBox(what,what2,type,buffer) {
    var text = what.value;
    var source = what2.src;
    var size = 0;
    var cursize = what.rows;
    var len = text.length;
    var count = 0;
    var cols = what.cols;
    var keypressBuffer = ((arguments.length == 4) ? buffer : 10);

    if (what.expanded == null) {what.expanded = 'F';}
    if (what.oldsize == null) {what.oldsize = 0;}
    if (what.keycount == null) {what.keycount = 0;}
    if (type == 'dynamic' && what.expanded == 'T' && what.keycount < keypressBuffer) {
        what.keycount++;
        size = cursize;
    } else {
        if ((what.expanded == "F" && type == 'force') || (type == 'dynamic' && what.expanded == 'T')) {
            if (type != 'dynamic') {
                what.oldsize = what.rows;
                //what2.innerHTML="Collapse";
                source = source.replace(/expand/g,"collapse");
                what2.src = source;
            }
            what.keycount = 0;
            what.expanded = 'T';
            for (var i=0; i<len; i++) {
                count++;
                if (text.slice(i,(i+1)) == '\n' || count > cols) {
                    size++;
                    count = 0;
                }
            }
            size = size + 4;
            if (size < what.oldsize) {
                size = what.oldsize;
            }
        } else {
            size = ((what.oldsize != 0) ? what.oldsize : what.rows);
            what.oldsize = 0;
            source = source.replace(/collapse/g,"expand");
            what2.src = source;
            what.expanded = 'F';
        }
    }
    if (cursize != size) {
        what.rows=size;
    }
}
