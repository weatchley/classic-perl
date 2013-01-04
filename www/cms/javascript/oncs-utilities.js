//
// Javascript utilities for CIRS web pages
//
// $Source: /data/dev/rcs/cms/javascript/RCS/oncs-utilities.js,v $
// $Revision: 1.4 $
// $Date: 2003/01/16 19:47:18 $
// $Author: naydenoa $
// $Locker:  $
// $Log: oncs-utilities.js,v $
// Revision 1.4  2003/01/16 19:47:18  naydenoa
// Added check of date day in validate_date to accommodate blank date
// CREQ00024
//
// Revision 1.3  2000/10/10 16:39:24  atchleyb
// removed verify_login function
// Check Point
//
// Revision 1.2  2000/06/14 17:49:14  zepedaj
// Added blankok variable to the parameter list of the validate_accession_number function.
// if blankok is true, a blank accession number is valid.  If blankok is false, blank numbers are not valid.
//
// Revision 1.1  2000/04/12 16:51:08  zepedaj
// Initial revision
//
//

// set up global hash
var global_hash = new Object;

//function to place the value from an input field into a select list
function addvalue_to_selectlist(value1, selectlist, method) {
    if (value1.value == "") {
        alert ("You must enter a value first");
    }
    else {     // add the data
        insert_option(selectlist, value1.value, value1.value)
        if (method == "move") {
            value1.value = "";
        }
    }
}

//function to disable edit on readonly fields
function on_readonly (what) {
    if (navigator.appName == 'Netscape') {
        what.blur();
    }
}

// A utility function that returns true if a string contains only
// whitespace characters.
function isblank(s) {
    if (s == null) return true;
    for(var i = 0; i < s.length; i++) {
        var c = s.charAt(i);
        if ((c != ' ') && (c != '\n') && (c != '\t') && (c !='\r')) return false;
    }
    return true;
}

// function that returns true if a string contains only numbers
function isnumeric(s) {
    for(var i = 0; i < s.length; i++) {
        var c = s.charAt(i);
        if ((c < '0') || (c > '9')) return false;
    }
    return true;
}

// funtion to show the proporties of an object (used mostly for debuging)
function show_props(obj, obj_name) {
    var result = "";
    for (var i in obj)
        result += obj_name + "." + i + " = " + obj[i] + "\n<br>";
    return result;
}

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
// if sortbytext is true, the insert is done into the sorted text
// rather than the sorted values (default).
function insert_option(what, val, tex, sortbytext) {
    var last = what.length - 1;
    var index;
    sortbytext = (sortbytext==null) ? false : sortbytext;
    what.length = what.length + 1;
    what[what.length - 1].value = what[last].value;
    what[what.length - 1].text = what[last].text;
    index=(last-1);
    if (sortbytext) {
        while ((index>=0)&&(what[index].text>tex)) {
            what[index + 1].value = what[index].value;
            what[index + 1].text = what[index].text;
            index = index - 1;
        }
    }
    else {
        while ((index>=0)&&(what[index].value>val)) {
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
function remove_option(selectlist) {
    var optionindex = 0;
    var foundone = false;
    var maxindex = selectlist.length;
    for(var i = (maxindex - 2); i >= 0; i--) {
        if (selectlist.options[i].selected) {
            foundone = true;
            selectlist[i] = null;
        } 
    }
    if (!foundone) {
        alert ("You must make a selection first");
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
function process_dual_select_option (source, target, option) {
    var index;
    var msg ="";
    if (((source.selectedIndex == -1) || (source[source.selectedIndex].value == "")) && (option != 'moveall')) {
        alert ("You must make a selection first");
    }
    else {
        if ((option == 'append') || (option == 'move')) {
//      append_option (what2, what1[what1.selectedIndex].value, what1[what1.selectedIndex].text);
            insert_option (target, source[source.selectedIndex].value, source[source.selectedIndex].text);
        }
        if ((option == 'remove') || (option == 'move')) {
            remove_option (source);
        }
        if (option == 'moveall') {
            for (index=(source.length-1); index >= 0; index--) {
                if (source[index].value != null) {
                    append_option (target, source[index].value, source[index].text);
                    remove_option2 (source, index);
                }
            }
        }
    }
}

// Routine is similar to above except that the source select can have multiple selections.
// History is an optional text field, only to be used with option = 'movehist'
function process_multiple_dual_select_option (source, target, option, history){
    var optionindex = 0;
    var foundone = false;
    var maxindex = source.length;
    for(var i = (maxindex - 2); i >= 0; i--) {
        if (source.options[i].selected) {
            foundone = true;
            if ((option == 'append') || (option == 'move') || (option == 'movehist')) {
                insert_option (target, source[i].value, source[i].text, true);
            }
            if (option == 'movehist') {  // add to the history select.
                history.value += source[i].value + '-->' + target.name + ';';
            }
            if ((option == 'remove') || (option == 'move') || (option == 'movehist')) {
                remove_option2 (source, i);
            }
       }
    }
    if (!foundone) {
         alert ("You must make a selection first");
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
    }
    else {
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

// Routine to pop open a new window
function PopIt(location,name) {
    popup = window.open(location,name,"height=500,width=700,scrollbars=yes");
}

//function determines if the accession number is in the correct format.
//it returns an empty string if the number is valid and an error message if not
function validate_accession_number(accnum, blankok) {
    var returnvalue = "";
    if (accnum == "") {
        if (! (blankok)) {
            returnvalue = "You must enter an accession number.";
        }
    }
    else if (accnum.length != 17) {
        returnvalue = "Accession number has an invalid length.";
    }
    else {
        var prefix = accnum.substr(0,3);
        var dot1 = accnum.substr(3,1)
        var datepart = accnum.substr(4,8);
        var dateyear = accnum.substr(4,4);
        var datemonth = accnum.substr(8,2);
        var dateday = accnum.substr(10,2);
        var dot2 = accnum.substr(12,1)
        var sequencenum = accnum.substr(13,4)
        if (! ((dot1 == ".") && (dot2 == "."))) {
            // Dots are not in the right places, this is an invalid
            returnvalue = "The Accession Number must be in the format: 'ORG.YYYYMMDD.####'.";
        }
        else if ((validate_date(dateyear, datemonth, dateday, 0, 0, 0, 0, true, false, false)) != "") {
            // Date value is not valid.
            returnvalue = "Date portion of the accession number is invalid.  Must be 'YYYYMMDD' representing a past date.";
        }
        else if (! isnumeric(sequencenum)) {
            //Sequence number is not in the correct format
            returnvalue = "Sequence portion of the accession number must be a positive 4 digit number '####'.";
        }
        else if (sequencenum < 1) {
            // Sequence number must be a positive number
            returnvalue = "Sequence portion of the accession number must be a positive 4 digit number '####'.";
        }
    }
    return (returnvalue);
}

// function returns true if the given year is a leap year
function isleapyear(year) {
    var returnvalue = ((year % 4 == 0) && (year % 100 != 0)) || (year % 400 == 0);
    return (returnvalue);
}

//function returns null string "" if a date is valid or an error string if it is invalid describing the
//first encountered reason that the date is invalid.
//pastdateok should be true if dates from the past are valid
//futuredateok should be true if dates from the future are valid
//fulldatetime should be true if the hour, minute, second, millisecond are to be considered when testing for
//  past and future dates
//the year must be  a 4 digit year (0026 = 26 AD)
function validate_date(year, month, day, hour, minute, second, millisecond, pastdateok, futuredateok, fulldatetime) {
    var returnvalue = "";
    var testdate;
    var months = new Array('', "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December");
    if (year.length < 4) {
        return ("You must enter a 4 digit year.");
    }
    if ((day < 1) || (day > 31)) {
        return ("You have entered an invalid day.");
    }
    if ((month < 1) || (month > 12)) {
        return ("You have entered an invalid month.");
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
            returnvalue = "Invalid day (31st) for the month of " + months[month] + ".";
        }
        break;
        case 2:
        case "2":
        case "02":
        if (isleapyear(year)) {
            returnvalue = (day > 29) ? "Cannot have more than 29 days in February of " + year + "." : "";
        }
        else {
            returnvalue = (day > 28) ? "Cannot have more than 28 days in February of " + year + "." : "";
        }
        break;
        default:
        if (day > 31) {
            returnvalue = "Cannot have more than 31 days in the month of " + months[month] + ".";
        }
    }
    if (returnvalue != "") {
        // we do a return here because the following is invalid if we've determined we have an invalid date.
        return (returnvalue);
    }
    testdate = new Date(year, month-1, day, hour, minute, second, millisecond);
    today = new Date();
    if (!(fulldatetime)) {
        today = new Date(today.getFullYear(), today.getMonth(), today.getDate(), 0,0,0,0);
    }
    if ( (!(pastdateok)) && (testdate.getTime() < today.getTime() ) ) {
        returnvalue = "You have selected a date from the past and the system will not accept past dates.";
    }
    if ( (!(futuredateok)) && (testdate.getTime() > today.getTime() ) ) {
        returnvalue = "You have selected a date from the future and the system will not accept future dates.";
    }
    return (returnvalue);
}

//This function combines a month, day, year value from three fields (from the perl widget which
//produces date entry screens) into a single date value in the format (MM/DD/YYYY)
function Melt_Date_Parts_Together(monthvalue, dayvalue, yearvalue) {
    var zerostring = "0000";
    var newmonth = zerostring + monthvalue;
    var newday = zerostring + dayvalue;
    var newyear = zerostring + yearvalue;
    newmonth = newmonth.substr(newmonth.length - 2);
    newday = newday.substr(newday.length - 2);
    newyear = newyear.substr(newyear.length - 4);
    return (newmonth + "/" + newday + "/" + newyear);
}

// routine to set the selected value in an option list.
function set_selected_option (what, set_val) {
    var last = what.length - 1;
    var index;
    for (index=0; index<what.length; index++) {
        if (what[index].value == set_val) {
            what.selectedIndex = index;
        }
    }
}

// routine to select all of the items that have a value other than "" in a 
// multiple-select field assumes last item in the select is blank.
function selectemall(selectobj) {
    for(var i = 0; ((selectobj.options[i].value != "") ? (selectobj.options[i].selected = true) : true) && (i < (selectobj.length - 2)) ; i++);
}

// routine to set the image for the graphic text label
function doSetTextImageLabel(label) {
    parent.titlebar.SetImageLabel(label);
}

// routinte to force the browser into a frame set
function forceFrameSet(execDir) {
    location = execDir + '/login.pl'
}

// routinte to force the browser back to login
function forceLogin(execDir) {
    parent.location = execDir + '/login.pl'
}
