// Widget Utilities for CRD
//
// $Source: /data/dev/eis/javascript/RCS/widgets.js,v $
//
// $Revision: 1.4 $
//
// $Date: 2000/04/11 22:45:48 $
//
// $Author: atchleyb $
//
// $Locker:  $
//
// $Log: widgets.js,v $
// Revision 1.4  2000/04/11 22:45:48  atchleyb
// added RCS variables to script header
//
//

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