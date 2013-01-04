package Javastoo;

use strict;
use CRD_Header;
use Sections;
use vars qw (@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS $AUTOLOAD);
use Exporter;
@ISA = qw (Exporter);

@EXPORT = qw (
	&writeHead
);

@EXPORT_OK = qw (
	&writeHead
);

%EXPORT_TAGS = (Functions => [qw (
	&writeHead
)]);


#################################################################
# Module consists of multiple use javascript functions and perl #
# subroutines for processing them.                              #
#################################################################

sub writeHead{
   
   my %args = (
	@_,
	);

   print <<end;
<html>
<head>
   <meta http-equiv=expires content=now>

<script language=javascript>
<!--

// begin utilities.js

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
	
	// function returns null string "" if a date is valid or an error string if it is invalid describing 
	// the first encountered reason that the date is invalid.
	// pastdateok should be true if dates from the past are valid
	// futuredateok should be true if dates from the future are valid
	// fulldatetime should be true if the hour, minute, second, millisecond are to be considered 
	// when testing for past and future dates
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
	   document['titleimage'].src = imagePath + '/titles/' + newtitle + '.gif';
	}
	
	function writeTitleBar(imagePath, title, username, userid, schema) {
//javascriptPath, imagePath, title, username, userid, schema) {
	   if ((username == o_username) && (userid == o_userid) && (schema == o_schema)) {
	      showImage(imagePath, title);
	   } else {
	      document.open();
	      document.writeln('<html>');
	      document.writeln('<head>');
//	      document.writeln('<script src=', javascriptPath, '/utilities.js></script>');
	      document.writeln('<script language=javascript><!--');
	      document.writeln('var o_username = \'', username, '\';');
	      document.writeln('var o_userid = \'', userid, '\';');
	      document.writeln('var o_schema = \'', schema, '\';');
	      document.writeln('//--></script>');
	      document.writeln('</head>');
	      document.writeln('<body background=', imagePath, '/background.gif text=#000099 link=#0000ff vlink=#0000ff alink=#0000ff topmargin=0 leftmargin=0><center>');
	      document.writeln('<table border=0 cellspacing=0 cellpadding=0 width=750><tr>');
	      document.writeln('<td align=center colspan=3><img src=', imagePath, '/separator.gif width=750 height=14 border=0></td></tr>');
	      document.writeln('<tr><td width=24% align=left><table cellpadding=3 cellspacing=0 border=1><tr><td><b><font size=2 color=#003000>User/ID:&nbsp;&nbsp;</font>');
	      var color = (username == 'None') ? 'ff0000' : '000090';
	      document.writeln('<font size=2 color=#', color, '>', username, '</font>');
	      document.writeln('<font size=2 color=#003000> / </font>');
	      color = (userid == 'None') ? 'ff0000' : '000090';
	      document.writeln('<font size=2 color=#', color, '>', userid, '</font>');
	      document.writeln('</b></td></tr></table></td>');
	      document.writeln('<td align=center><img src=', imagePath, '/titles/', title, '.gif name=titleimage width=390 height=20></td>');
	      document.writeln('<td width=24% align=right><table cellpadding=3 cellspacing=0 border=1><tr><td><b>');
	      document.writeln('<font size=2 color=#003000>Database:&nbsp&nbsp;</font>');
	      color = (schema == 'None') ? 'ff0000' : '000090';
	      document.writeln('<font size=2 color=#', color, '>', schema, '</font>');
	      document.writeln('</b></td></tr></table></td></tr>');
	      document.writeln('<tr><td align=center colspan=3><img src=', imagePath, '/separator.gif width=750 height=14 border=0></td>');
	      document.writeln('</tr></table></center></body></html>');
	      document.close();
	   }
	}

//# end utilities.js #

//# begin widgets.js #


// routine to copy the data from one text field to another
function copy_text_field (what1, what2) {
  var copyok = true;
  if ((what2 != null) && (!(isblank(what2.value)))) {
    copyok = confirm('This operation will overwrite data already in the field.\nDo you wish to continue?');
  }
  if (copyok) {
    what2.value = what1.value;
  }
}

// routine to append passed values to an option list.
// code assumes that the last element in the list is a blank entry
function append_option(what, val, tex) {
  var last = what.length - 1;
  what.length = what.length + 1;
  what[what.length - 1].value = what[last].value;
  what[what.length - 1].text = what[last].text;
  what[last].value = val;
  what[last].text = tex;
}

// routine to insert passed values to a sorted option list.
// code assumes that the last element in the list is a blank entry
function insert_option(what, val, tex) {
  var last = what.length - 1;
  var index;
  what.length = what.length + 1;
  what[what.length - 1].value = what[last].value;
  what[what.length - 1].text = what[last].text;
  index=(last-1); 
  while ((index>=0)&&(what[index].value>val)) {
    what[index + 1].value = what[index].value;
    what[index + 1].text = what[index].text;
    index = index - 1;
  }
  index = index+1;
  what[index].value = val;
  what[index].text = tex;
}

// routine to remove an entry from an option list.
function remove_option(what) {
  if (what.selectedIndex == -1) {
    alert ("You must make a selection first");
  } else {
    what[what.selectedIndex] = null;
  }
}

// routine to remove an entry from an option list.
function remove_option2(what, index) {
    what[index] = null;
}

// routine to process dual select boxes with three options
// 'append' - get selected data from first object and append it to second object
// 'remove' - remove select data from object
// 'move' - do an 'append' then a 'remove'
// code assumes that the last element in the list is a blank entry
//
function process_dual_select_option (what1, what2, option) {
  var index;
  var msg ="";
  var doit = "T";
  if (((what1.selectedIndex == -1) || (what1[what1.selectedIndex].value == "")) && (option != 'moveall')) {
    alert ("You must make a selection first");
  } else {
    for (var i = 3; i < arguments.length; i++) 
      if (arguments[i] == what1[what1.selectedIndex].value) doit = "F";
    if (doit == "T") {
      if ((option == 'append') || (option == 'move')) {
//        append_option (what2, what1[what1.selectedIndex].value, what1[what1.selectedIndex].text);
        insert_option (what2, what1[what1.selectedIndex].value, what1[what1.selectedIndex].text);
      }
      if ((option == 'remove') || (option == 'move')) {
        remove_option (what1);
      }
      if (option == 'moveall') {
        for (index=(what1.length-1); index >= 0; index--) {
          if (what1[index].value != null) {
            append_option (what2, what1[index].value, what1[index].text);
            remove_option2 (what1, index);
          }
        }
      }
    }
  }
}

// Routine to copy a selected element from a piclist to a text field
function select_from_piclist (what1, what2, saveit) {
  var last = what1.length -1;
  var last2;
  var index;
  var inlist = false;
  var testvalue;
  var tempval;
  if ((what1.selectedIndex == -1) || (what1[what1.selectedIndex].value == "")) {
    alert ("You must make a selection first");
  } else {
    if (((saveit == "yes") || (saveit == "true")) && (what2.value != null)) {
      testvalue = what2.value;
// see if already in list
      for (index=0; index<=last; index++) {
        if (what1[index].text == what2.value) inlist = true;
      }
// append if not in list
      if (inlist == false) {
//        insert_option (what1, "test", testvalue);
        what1.length = what1.length + 1;
        last2 = what1.length -1;
        tempval = what1[last].value;
//        what1[last2].value = tempval;
        tempval = what1[last].text;
//        what1[last2].text = tempval;
        what1[last].value = testvalue;
        what1[last].text = testvalue;
      }
    }
    what2.value = what1[what1.selectedIndex].text;
  }
}

// routine to set the selected value in an option list.
function set_selected_option (what, set_val) {
  var last =what.length -1;
  var index;
  for (index=0; index<what.length; index++) {
    if (what[index].value == set_val) {
      what.selectedIndex = index;
    }
  }
}

//# end widgets.js #


// begin original js from writeHead

      function submitForm(script, command) {
         document.$args{form}.command.value = command;
         document.$args{form}.action = '$args{path}' + script + '.pl';
         document.$args{form}.submit();
      }
      function display_user(userid) {
         document.dummy.id.value = userid;
         document.dummy.command.value = 'displayuser';
         document.dummy.action = '$args{path}' + 'user_functions' + '.pl';
         document.dummy.submit();
      }
      function message(command, id) {
         var doit = 1;
         if (command == 'send') {
            if (isblank(document.$args{form}.subjectText.value)) {
               doit = 0;
               alert("No text has been entered in subject field.");
            } else if (isblank(document.$args{form}.messageText.value)) {
               doit = 0;
               alert("No text has been entered in the message field.");
            }
         }
         if (doit) {
            if (message.arguments.length > 1) {
               if (command == 'send') {
                  document.$args{form}.sentTo.value = id;
               } else {
                  document.$args{form}.id.value = id;
               }
            }
            document.$args{form}.process.value = ((command == 'send') || (command == 'sentbydelete') || (command == 'senttodelete')) ? 1 : 0;
            document.$args{form}.target = ((command == 'send') || (command == 'sentbydelete') || (command == 'senttodelete'))  ? 'cgiresults' : 'main';
            submitForm('messages', command);
         }
      }
end
   print "   //-->\n";
   print "   </script>\n";
   print &sectionHeadTags($args{form});
   print "</head>\n\n";
}




#################
# End of module #
#################

1;

