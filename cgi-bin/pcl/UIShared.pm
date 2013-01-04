#
# $Source: /usr/local/www/gov.ymp.intradev/rcs/pcl/perl/RCS/UIShared.pm,v $
#
# $Revision: 1.14 $ 
#
# $Date: 2009/01/14 22:41:58 $
#
# $Author: atchleyb $
#
# $Locker:  $
#
# $Log: UIShared.pm,v $
# Revision 1.14  2009/01/14 22:41:58  atchleyb
# ACR0901_007 - Updated to create new path to system (login_new.pl) and to redirect login.pl to the new system (PCLWR)
#
# Revision 1.13  2003/02/12 18:52:10  atchleyb
# added session management
#
# Revision 1.12  2003/02/03 18:48:55  atchleyb
# updated to removed PCL from script and variable names
#
# Revision 1.11  2003/01/27 23:24:35  atchleyb
# fixed bad header file ref
#
# Revision 1.10  2003/01/27 22:40:48  atchleyb
# changed all references to SCM to PCL
#
# Revision 1.9  2003/01/27 19:38:02  atchleyb
# updated to force use of https
#
# Revision 1.8  2002/11/29 21:57:31  atchleyb
# removed unneeded call to documents module
#
# Revision 1.7  2002/11/20 02:29:21  mccartym
# minor update to the previous modification
#
# Revision 1.6  2002/11/11 20:11:26  mccartym
# add &writeAlert() function
#
# Revision 1.5  2002/11/07 23:59:45  atchleyb
# added checkLogin fuction
#
# Revision 1.4  2002/11/06 21:55:25  atchleyb
# added writeHTMLHead and writeHTTPHeader
#
# Revision 1.3  2002/10/31 17:19:21  atchleyb
# modified standard header and footer to use more grainular functions
#
# Revision 1.2  2002/10/03 18:02:19  atchleyb
# fixed problem with newlines in javascript libraries
# added display user JS function to doStandardHeader
#
# Revision 1.1  2002/10/03 17:48:01  atchleyb
# Initial revision
#
#
#
#
package UIShared;
use strict;
use SharedHeader qw(:Constants);
use Sessions qw(:Functions);
use UI_Widgets qw(:Functions);
use DBShared qw(:Functions);
use Tables qw(:Functions);
use CGI qw(param);
use Tie::IxHash;
use Carp;

use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS $VERSION $AUTOLOAD);
#use vars qw ();
use integer;

use Exporter;
$VERSION = 1.00;

@ISA = qw(Exporter);

@EXPORT = qw ();
@EXPORT_OK = qw(
      &getValueHash     &getFile       &doStandardHeader      &doStandardFooter
      &JSWidgets        &JSUtilities   &doEndForm             &doEndPage
      &doStartPage      &doStandardJS  &doStartForm           &writeHTTPHeader
      &writeHTMLHead    &checkLogin    &writeAlert            &validateCurrentSession
    );
%EXPORT_TAGS =( 
    Functions => [qw(
      &getValueHash     &getFile       &doStandardHeader      &doStandardFooter
      &JSWidgets        &JSUtilities   &doEndForm             &doEndPage
      &doStartPage      &doStandardJS  &doStartForm           &writeHTTPHeader
      &writeHTMLHead    &checkLogin    &writeAlert            &validateCurrentSession
    )]
);

my $mycgi = new CGI;

###################################################################################################################################
###################################################################################################################################


###################################################################################################################################
sub getValueHash {  # routine to get initial CGI values and return in a hash
###################################################################################################################################
    my %args = (
        valueList => (),
        @_,
    );
    
    my %valueHash = ();

    foreach my $item ($args{valueList}) {
        $valueHash{$item} = $mycgi->param($item);
    }
    
    return (%valueHash);
}


###################################################################################################################################
sub getFile {  # routine to get a file using CGI
###################################################################################################################################
    my %args = (
        fileParam => 'documentfile',
        @_,
    );
    
    my $fileContents = '';
    my $name = $mycgi->param($args{fileParam});
    my $buffer = '';
    my $bytesread = 0;
    while ($bytesread=read($name,$buffer,16384)) {
        $fileContents .= $buffer;
    }
    
    return ($name, $fileContents);
}


###################################################################################################################################
sub checkLogin { # redirect to login if username, userid, or schema not submitted in a POST'ed form (i.e. user has not logged in) #
###################################################################################################################################
   my %args = (
      cgi => $mycgi,
      checkMethod => 1,
      checkUsername => 1,
      checkUserID => 1,
      checkSchema => 1,
      redirectTo => "login_new.pl",
      @_,
   );
   my $redirect = 0;
   if ($args{checkMethod}) {
      $redirect = 1 if (!$args{cgi}->MethPost());
   }
   if (!$redirect && ($args{checkUsername})) {
      my $username = (defined($args{cgi}->param("username"))) ? $args{cgi}->param("username") : "";
      $redirect = 1 if (!$username);
   }
   if (!$redirect && ($args{checkID})) {
      my $userid = (defined($args{cgi}->param("userid"))) ? $args{cgi}->param("userid") : "";
      $redirect = 1 if (!$userid);
   }
   if (!$redirect && ($args{checkSchema})) {
      my $schema = (defined($args{cgi}->param("schema"))) ? $args{cgi}->param("schema") : "";
      $redirect = 1 if (!$schema);
   }
   if (!$redirect && (!defined($ENV{HTTPS}) || lc($ENV{HTTPS}) ne "on")) {
      $redirect = 1;
   }
   if ($redirect) {
      $ENV{SCRIPT_NAME} =~ m%^(.*/)%;
      print "Location: https://$ENV{SERVER_NAME}$1$args{redirectTo}\n\n";
      exit;
   }
}


###################################################################################################################################
sub writeHTTPHeader {                                                                                                             #
###################################################################################################################################
   my %args = (
      mimetype => "text/html",
      @_,
   );
   return ($mycgi->header($args{mimetype}));
}


###################################################################################################################################
sub doStandardHeader {  # routine to generate html page headers
###################################################################################################################################
    my %args = (
        schema => $ENV{SCHEMA},
        title => "$ENV{SCHEMA} Management",
        displayTitle => 'T',
        includeJSUtilities => 'T',
        includeJSWidgets => 'T',
        extraJS => '',
        useFileUpload => 'F',
        formAction => '',
        onSubmit => '',
        @_,
    );
    my $output = "";
    my $hashRef = $args{settings};
    my %settings = %$hashRef;

    $output .= &doStartPage(schema => $args{schema}, title => $args{title}, displayTitle => $args{displayTitle}, 
              username => $settings{username}, userid => $settings{userid});
    
    $output .= &doStandardJS(form => $args{form}, path=>$args{path}, schema => $args{schema}, includeJSUtilities => $args{includeJSUtilities}, 
              includeJSWidgets => $args{includeJSWidgets}, extraJS => $args{extraJS}, username => $settings{username}, userid => $settings{userid});

    $output .= &doStartForm(schema => $args{schema}, form => $args{form}, useFileUpload => $args{useFileUpload}, formAction => $args{formAction}, 
              onSubmit => $args{onSubmit}, username => $settings{username}, userid => $settings{userid}, sessionID => $settings{sessionID});

    
    return($output);
}


###################################################################################################################################
sub writeHTMLHead {                                                                                                                   #
###################################################################################################################################
   my %args = (
       title => "",
      @_,
   );
   my $output = "";
   $output .= "<html>\n";
   $output .= "<head>\n";
   $output .= "<base target=main>\n";
   $output .= "<title>$args{title}</title>\n" if ($args{title} gt "");
   $output .= "<meta http-equiv=expires content=now>\n";
   $output .= "</head>\n\n";
   return ($output);
}


###################################################################################################################################
sub doStartPage {  # routine to generate html page begining
###################################################################################################################################
    my %args = (
        schema => $ENV{SCHEMA},
        title => "$ENV{SCHEMA} Management",
        displayTitle => 'T',
        username => '',
        userid => '',
        @_,
    );
    my $output = "";
    
    $output .= &writeHTTPHeader;
    $output .= &writeHTMLHead(title => $args{title});
    $output .= "<body text=#000099 background=$SYSImagePath/background.gif>\n";
    $output .=  (($args{displayTitle} eq 'T') ? &writeTitleBar(userName => $args{username}, userID => $args{userid}, schema => $args{schema}, title => $args{title}) : "");

    return($output);
}


###################################################################################################################################
sub doStandardJS {  # routine to generate html for standard java script
###################################################################################################################################
    my %args = (
        includeJSUtilities => 'F',
        includeJSWidgets => 'F',
        form => '',
        path => '',
        extraJS => '',
        @_,
    );
    my $output = "";
    
    $output .= "    <script language=javascript><!--\n";
    $output .= ($args{includeJSUtilities} eq 'T') ? &JSUtilities : "";
    $output .= ($args{includeJSWidgets} eq 'T') ? &JSWidgets : "";
    $output .= <<END_OF_BLOCK;
       function submitFormCGIResults(script,command) {
           document.$args{form}.command.value = command;
           document.$args{form}.action = '$args{path}' + script + '.pl';
           document.$args{form}.target = 'cgiresults';
           document.$args{form}.submit();
       }
       function submitForm(script,command) {
           document.$args{form}.command.value = command;
           document.$args{form}.action = '$args{path}' + script + '.pl';
           document.$args{form}.target = 'main';
           document.$args{form}.submit();
       }

       // funtion to change the location of the main frame
       function changeMainLocation(script) {
           //parent.main.location='$args{path}' + script + '.pl?username=$args{username}&userid=$args{userid}&schema=$args{schema}';
           submitForm(script,'');
       }
       function displayUser(id) {
          $args{form}.id.value = id;
          submitForm ('users', 'displayuser');
       }
$args{extraJS}
    //-->
    </script>
END_OF_BLOCK


    return($output);
}


###################################################################################################################################
sub doStartForm {  # routine to generate html form begining
###################################################################################################################################
    my %args = (
        useFileUpload => 'F',
        formAction => '',
        onSubmit => '',
        form => '',
        path => '',
        sessionID => 0,
        @_,
    );
    my $output = "";
    my $formAction = ($args{formAction} gt '') ? $args{formAction} : "$args{path}$args{form}.pl";
    
    $output .= "<form " . (($args{useFileUpload} eq 'T') ? "enctype=\"multipart/form-data\" " : "");
    $output .= (($args{onSubmit} gt '') ? "onsubmit=\"$args{onSubmit}\"" : "");
    $output .= "name=$args{form} method=post target=main action=$args{formAction}>\n";
    $output .= "<input type=hidden name=userid value=$args{userid}>\n";
    $output .= "<input type=hidden name=username value=$args{username}>\n";
    $output .= "<input type=hidden name=schema value=$args{schema}>\n";
    $output .= "<input type=hidden name=command value=''>\n";
    $output .= "<input type=hidden name=id value=''>\n";
    $output .= "<input type=hidden name=sessionid value='$args{sessionID}'>\n";
    
    return($output);
}


###################################################################################################################################
sub doStandardFooter {  # routine to generate html page footers
###################################################################################################################################
    my %args = (
        extraHTML => "",
        @_,
    );
    my $output = "";
    
    $output .= &doEndForm;
    $output .= $args{extraHTML};
    $output .= &doEndPage;
    
    return($output);
}


###################################################################################################################################
sub doEndForm {  # routine to generate html form end
###################################################################################################################################
    my %args = (
        @_,
    );
    my $output = "";
    
    $output .= "</form>\n";
    
    return($output);
}


###################################################################################################################################
sub doEndPage {  # routine to generate html page ending
###################################################################################################################################
    my %args = (
        @_,
    );
    my $output = "";
    
    $output .= "</body>\n</html>\n";
    
    return($output);
}


###################################################################################################################################
sub JSWidgets {  # routine to include javascript ui widgets
###################################################################################################################################
    my %args = (
        @_,
    );
    my $output = "";
    
    $output .= <<END_OF_BLOCK;
// routine to copy the data from one text field to another
function copy_text_field (what1, what2) {
  var copyok = true;
  if ((what2 != null) && (!(isblank(what2.value)))) {
    copyok = confirm('This operation will overwrite data already in the field.\\nDo you wish to continue?');
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

END_OF_BLOCK
    
    return($output);
}


###################################################################################################################################
sub JSUtilities {  # routine to include javascript utilities
###################################################################################################################################
    my %args = (
        @_,
    );
    my $output = "";
    $output .= <<END_OF_BLOCK;
    
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
        if ((c != ' ') && (c != '\\n') && (c != '\\t') && (c !='\\r')) return false;
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
                        result += "          " + obj_name + "." + i + " = " + obj[i] + "\\n<br>";
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

// routine to set the image for the graphic text label
function doSetTextImageLabel(label) {
    //parent.status.SetImageLabel(label);
    parent.frames[1].SetImageLabel(label);
}

function writeTitleBar(javascriptPath, imagePath, title, username, userid, schema) {
   doSetTextImageLabel(title);
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
                if (text.slice(i,(i+1)) == '\\n' || count > cols) {
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

END_OF_BLOCK
    
    return($output);
}

###################################################################################################################################
sub writeAlert {                                                                                                                  #
###################################################################################################################################
   my %args = (
      msg => "alert",
      @_,
   );
   $args{msg} =~ s/\n/\\n/g;
   $args{msg} =~ s/'/%27/g;
   my $out = "<script language=javascript>\n<!--\nvar mytext ='$args{msg}';\nalert(unescape(mytext));\n//-->\n</script>\n";
   return ($out);
}


###################################################################################################################################
sub validateCurrentSession {              #redirect user to login screen if session is timed out or not valid.
###################################################################################################################################
    my %args = (
          userID => '',
          dbh => '',
          schema => '',
          sessionID => 'none',
          @_,
          );
    
    my $status;
    if ($ENV{SYSUseSessions} eq 'T') {
        $status = &sessionValidate(dbh=>$args{dbh}, schema=>$args{schema}, userID=>$args{userID}, sessionID=>$args{sessionID});
        if ($status == 1) {
            return ($status);
        } else {
            print "content-type: text/html\n\n";
            print "<html><header></header><body>\n";
            print "<form name=timeout action=login_new.pl target=_top method=post>\n";
            print "<input type=hidden name=test value=test>\n</form>\n";
            print "<script language=javascript>\n<!--\n";
            print "alert('Session has timed out or is not valid');\n";
            print "document.timeout.submit();\n";
            print "//-->\n</script>\n";
        }
    }
}


###################################################################################################################################
###################################################################################################################################


1; #return true
