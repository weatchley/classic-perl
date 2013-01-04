// Trend Analysis Database Utilities
//
// $Source: /data/dev/rcs/nqs/javascript/RCS/utilities.js,v $
//
// $Revision: 1.7 $
//
// $Date: 2002/06/10 23:41:43 $
//
// $Author: starkeyj $
//
// $Locker:  $
//
// $Log: utilities.js,v $
// Revision 1.7  2002/06/10 23:41:43  starkeyj
// bug fix - modified getSemester function so June is in first semester and not the second
//
// Revision 1.6  2001/11/20 20:03:29  johnsonc
// Added function process_multiple_dual_select_option.
//
// Revision 1.5  2001/11/20 00:07:24  johnsonc
// Added javascript function process_dual_select_box and all dependent functions
//
// Revision 1.4  2001/11/19 22:10:54  starkeyj
// modified validate date function to add a hidden semester and quarter value when date is entered or modified
//
// Revision 1.3  2001/11/05 13:48:50  starkeyj
// added a new validate date functions for audit and surveillance forms
//
// Revision 1.2  2001/07/26 21:57:06  starkeyj
// modified getSemester and getQuarter for specific form name
//
// Revision 1.1  2001/07/25 20:04:46  starkeyj
// Initial revision
//



function toUpper(element,s) {     	
   	s = s.toUpperCase();
   	element.value = s;
}
   
function isBlank(s) {
    for (var i=0; i<s.length; i++) {
       var c = s.charAt(i);
       if ((c != ' ') && (c != '\\n') && (c != '\\t') ) {
	  return false;
       }
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

function validateDate(date) {
	
	var valid = 1;
	var errormsg = "";
	
	if (date.length == 10) {

		var month = date.substr(0,2);
		var slash1 = date.substr(2,1);
		var day = date.substr(3,2);
		var slash2 = date.substr(5,1);
		var year = date.substr(6);
		
		var digits = "1234567890";
		for (i=0;i<2;i++) {
			if ((digits.indexOf(month.charAt(i))<0) || (digits.indexOf(day.charAt(i))<0)) {
				valid = 0;
			}

		}

		for (i=0;i<4;i++) {
			if (digits.indexOf(year.charAt(i))<0) {
				valid = 0;
			}

		}

		if ((slash1 != "/") || (slash2 != "/")) 
			valid = 0;			
	}
	else if (!(isBlank(date))) {
		valid = 0;
	}
		
	if (valid == 0) {
		alert ("Date should be of the format mm/dd/yyyy");	
		document.trend_documents.date.focus();
	}
	
	if (!(isBlank(date))) {
		if ((month < 1) || (month > 12)) {
			valid = 0;
			errormsg += month + " is not a valid month\n";
			alert (errormsg);	
			document.trend_documents.date.focus();
	
		}
	
		if ((day < 1) || ((month == "01") && (day > 31)) || ((month == "02") && (day > 29))
	   	|| ((month == "03") && (day > 31)) || ((month == "04") && (day > 30))
	   	|| ((month == "05") && (day > 31)) || ((month == "06") && (day > 30))
	   	|| ((month == "07") && (day > 31)) || ((month == "08") && (day > 31))
	   	|| ((month == "09") && (day > 30)) || ((month == "10") && (day > 31))
	   	|| ((month == "11") && (day > 30)) || ((month == "12") && (day > 31))) {
			valid = 0;
			alert ("There are not " + day + " days in that month");
			document.trend_documents.date.focus();
		}
	}
	
	if (valid && !(isBlank(date))) {
		var semester = getSemester(month,year);
		var quarter = getQuarter(month,year);
		document.trend_documents.semester.value = semester;
		document.trend_documents.quarter.value = quarter;
		document.trend_documents.hiddensemester.value = semester;
		document.trend_documents.hiddenquarter.value = quarter;
	}
	
	
		
}
// routine to set the image for the graphic text label
function doSetTextImageLabel(label) {
    //parent.status.SetImageLabel(label);
    parent.frames[1].SetImageLabel(label);
}
function validateDate2(date) {
	
	var valid = 1;
	var errormsg = "";
	
	if (date.length == 10) {

		var month = date.substr(0,2);
		var slash1 = date.substr(2,1);
		var day = date.substr(3,2);
		var slash2 = date.substr(5,1);
		var year = date.substr(6);
		
		var digits = "1234567890";
		for (i=0;i<2;i++) {
			if ((digits.indexOf(month.charAt(i))<0) || (digits.indexOf(day.charAt(i))<0)) {
				valid = 0;
			}

		}

		for (i=0;i<4;i++) {
			if (digits.indexOf(year.charAt(i))<0) {
				valid = 0;
			}

		}

		if ((slash1 != "/") || (slash2 != "/")) 
			valid = 0;			
	}
	else 
		valid = 0;
	if (valid == 0) {
		alert ("Date should be of the format MM/DD/YYYY");	
		valid = 0;
	}
	
	if ((month < 1) || (month > 12)) {
		errormsg += month + " is not a valid month\n";
		alert (errormsg);	
		valid = 0;
	
	
	}
	
	if ((day < 1) || ((month == "01") && (day > 31)) || ((month == "02") && (day > 29))
	   || ((month == "03") && (day > 31)) || ((month == "04") && (day > 30))
	   || ((month == "05") && (day > 31)) || ((month == "06") && (day > 30))
	   || ((month == "07") && (day > 31)) || ((month == "08") && (day > 31))
	   || ((month == "09") && (day > 30)) || ((month == "10") && (day > 31))
	   || ((month == "11") && (day > 30)) || ((month == "12") && (day > 31))) {
	
		alert ("There are not " + day + " days in that month");
		valid = 0;
		
	}
	
	return (valid);
	
		
}
function getSemester(month,year) {
	var semester;
	if ((month > 0) && (month < 7)) 
		semester = year + "-1";
	else
		semester = year + "-2";
	return semester;

}

function getQuarter(month,year) {
	var semester;
	if ((month > 0) && (month < 4)) 
		quarter = year + "-1";
		
	else if ((month > 3) && (month < 7))
		quarter = year + "-2";
		
	else if ((month > 6) && (month < 10))
		quarter = year + "-3";
		
	else
		quarter = year + "-4";
	return quarter;
}


// routine to append passed values to an option list.
// code assumes that the last element in the list is a blank entry
function append_option(what, val, tex)
  {
  var last = what.length - 1;
  what.length = what.length + 1;
  what[what.length - 1].value = what[last].value;
  what[what.length - 1].text = what[last].text;
  what[last].value = val;
  what[last].text = tex;
  }

// routine to insert passed values to a sorted option list.
// code assumes that the last element in the list is a blank entry
// if sortbytext is true, the insert is done into the sorted text
// rather than the sorted values (default).
function insert_option(what, val, tex, sortbytext)
  {
  var last = what.length - 1;
  var index;
  sortbytext = (sortbytext==null) ? false : sortbytext;
  what.length = what.length + 1;
  what[what.length - 1].value = what[last].value;
  what[what.length - 1].text = what[last].text;
  index=(last-1);
  if (sortbytext)
    {
    while ((index>=0)&&(what[index].text>tex))
      {
      what[index + 1].value = what[index].value;
      what[index + 1].text = what[index].text;
      index = index - 1;
      }
    }
  else
    {
    while ((index>=0)&&(what[index].value>val))
      {
      what[index + 1].value = what[index].value;
      what[index + 1].text = what[index].text;
      index = index - 1;
      }
    }
  index = index+1;
  what[index].value = val;
  what[index].text = tex;
  }

// routine to remove an entry from an option list.
// the list will always retain a single blank item
function remove_option(selectlist)
  {
  var optionindex = 0;
  var foundone = false;
  var maxindex = selectlist.length;
  for(var i = (maxindex - 2); i >= 0; i--)
    {
    if (selectlist.options[i].selected)
      {
      foundone = true;
      selectlist[i] = null;
      }
    }
  if (!foundone)
    {
    alert ("You must make a selection first");
    }
  }

// routine to remove an entry from an option list.
function remove_option2(what, index)
  {
  what[index] = null;
  }

// routine to process dual select boxes with three options
// 'append' - get selected data from first object and append it to second object
// 'remove' - remove select data from object
// 'move' - do an 'append' then a 'remove'
// code assumes that the last element in the list is a blank entry
//
function process_dual_select_option (source, target, option)
  {
  var index;
  var msg ="";
  if (((source.selectedIndex == -1) || (source[source.selectedIndex].value == "")) && (option != 'moveall'))
    {
    alert ("You must make a selection first");
    }
  else
    {
    if ((option == 'append') || (option == 'move'))
      {
//      append_option (what2, what1[what1.selectedIndex].value, what1[what1.selectedIndex].text);
      insert_option (target, source[source.selectedIndex].value, source[source.selectedIndex].text);
      }
    if ((option == 'remove') || (option == 'move'))
      {
      remove_option (source);
      }
    if (option == 'moveall')
      {
      for (index=(source.length-1); index >= 0; index--)
        {
        if (source[index].value != null)
          {
          append_option (target, source[index].value, source[index].text);
          remove_option2 (source, index);
          }
        }
      }
    }
  }

// Routine is similar to above except that the source select can have multiple selections.
// History is an optional text field, only to be used with option = 'movehist'
function process_multiple_dual_select_option (source, target, option, history)
  {
  var optionindex = 0;
  var foundone = false;
  var maxindex = source.length;
  for(var i = (maxindex - 2); i >= 0; i--)
    {
    if (source.options[i].selected)
      {
      foundone = true;
      if ((option == 'append') || (option == 'move') || (option == 'movehist'))
        {
        insert_option (target, source[i].value, source[i].text, true);
        }
      if (option == 'movehist')
        {  // add to the history select.
        history.value += source[i].value + '-->' + target.name + ';';
        }
      if ((option == 'remove') || (option == 'move') || (option == 'movehist'))
        {
        remove_option2 (source, i);
        }
      }
    }
  if (!foundone)
    {
    alert ("You must make a selection first");
    }
  }
