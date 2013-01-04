#!/usr/local/bin/newperl -w

# User functions for the CRD
#
# $Source: /data/dev/rcs/crd/perl/RCS/user_functions.pl,v $
#
# $Revision: 1.39 $
#
# $Date: 2004/05/26 22:06:17 $
#
# $Author: atchleyb $
#
# $Locker:  $
#
# $Log: user_functions.pl,v $
# Revision 1.39  2004/05/26 22:06:17  atchleyb
# updated to use newer password security
#
# Revision 1.38  2001/12/27 23:58:45  mccartym
# fix bookmarks on Browse Users screen
#
# Revision 1.37  2001/11/06 22:31:03  atchleyb
# changed javascript submit functions to not reset values after submition
# changed alert box code to handle single quotes
#
# Revision 1.36  2001/06/18 19:21:48  atchleyb
# fixed bug in 'reset password', 'disable user', and 'enable user' that used the current username from the select box rathar than the user that was being updated.
# changed user select box on update user to default to the currently edited user.
#
# Revision 1.35  2001/06/14 15:44:24  atchleyb
# fixed too many users select bug
#
# Revision 1.34  2001/05/17 16:16:25  atchleyb
# modified to use &FirstReviewName and &SecondReviewName from DocumentSpecific.pm
#
# Revision 1.33  2001/03/09 18:48:02  atchleyb
# updated become another user function to use 'title_bar.pl' when changing the status bar
#
# Revision 1.32  2001/02/27 17:42:46  atchleyb
# modified insert/update so that a string of blanks in the extension will not cause an error
#
# Revision 1.31  2000/12/08 00:31:27  atchleyb
# added code to handle multiple oracle servers
#
# Revision 1.30  2000/05/19 16:30:20  mccartym
# add more titles to getTitle function
#
# Revision 1.29  2000/05/19 15:52:13  mccartym
# add getTitle subroutine, call writeTitleBar at beginning of script
#
# Revision 1.28  2000/04/06 21:24:53  atchleyb
# modified to get rid of some use of uninitialized values warnings
#
# Revision 1.27  2000/02/20 23:35:39  mccartym
# exclude nouser and developers from the Become Another User dropdown list of users
#
# Revision 1.26  2000/02/10 17:41:29  atchleyb
# removed form-verify.js
#
# Revision 1.25  2000/02/07 16:30:15  mccartym
# change 'Jason' to 'Supplemental'
#
# Revision 1.24  1999/11/04 17:50:50  mccartym
# modify 'become another user' to work with new page header
#
# Revision 1.23  1999/11/04 15:46:55  mccartym
# title changes
#
# Revision 1.22  1999/10/27 18:43:58  atchleyb
# changes in titles for new title bar
#
# Revision 1.21  1999/10/27 18:10:00  atchleyb
# updated to use new title bar
#
# Revision 1.20  1999/10/19 23:22:32  mccartym
# change user privilege terminology
#
# Revision 1.19  1999/10/15 21:35:06  atchleyb
# made the system administrator priv unremovable in the update screen
#
# Revision 1.18  1999/10/14 23:42:05  mccartym
# add new function to construct user browse tables
#
# Revision 1.17  1999/09/03 20:13:09  atchleyb
# added evals arround db function calls
# commented out all raise error lines
#
# Revision 1.16  1999/09/02 23:32:11  atchleyb
# commented out all raiseerror lines
#
# Revision 1.15  1999/08/25 18:21:24  atchleyb
# removed a hard coded path
#
# Revision 1.14  1999/08/17 23:21:04  atchleyb
# added a line to display username on update user
#
# Revision 1.13  1999/08/17 22:23:36  atchleyb
# fixed error introduced when update user had a drop down added to replace a text box
#
# Revision 1.12  1999/08/12 18:47:31  atchleyb
# changed update user to use full name instead of username
#
# Revision 1.11  1999/08/12 15:48:33  atchleyb
# took care of quotes in input fields
#
# Revision 1.10  1999/08/10 17:34:16  atchleyb
# changed where check_login was called
#
# Revision 1.9  1999/08/04 16:30:23  atchleyb
# added raise error to all eval blocks
# updated become_user code to use tie module and to display full name
#
# Revision 1.8  1999/08/02 22:51:17  atchleyb
# fixed prob with newline in error message
#
# Revision 1.7  1999/08/02 20:28:07  atchleyb
# updated error handling, now using errorMessage routine.
#
# Revision 1.6  1999/08/02 02:38:11  mccartym
#  Reversed order of parameters on call to headerBar()
#
# Revision 1.5  1999/07/30 19:33:31  atchleyb
# Removed force to upper case
# removed hardcoded paths
# changed most links to form submits
#
# Revision 1.4  1999/07/22 17:13:18  atchleyb
# Minor modifications
#
# Revision 1.3  1999/07/20 00:00:34  atchleyb
# fixed bug where wrong userid was passed to display_user
#
# Revision 1.2  1999/07/17 00:07:14  atchleyb
# Added Browse
#
# Revision 1.1  1999/07/06 20:40:44  atchleyb
# Initial revision
#
#
#
# get all required libraries and modules
use strict;
use CRD_Header qw(:Constants);
use CGI;
use UI_Widgets qw(:Functions);
use DB_Utilities_Lib qw(:Functions);
use DocumentSpecific qw(:Functions);
use DBI;
use DBD::Oracle qw(:ora_types);
use Tie::IxHash;

my $crdcgi = new CGI;

# declare variables
my $message;
my $dbh;
my $sqlquery;
my $csr;
my @values;
my @uservalues;
my @userprivs;
my $status;
my $currprivs;
my $u_id;
my $u_location;
my $u_username;
my $u_firstname;
my $u_lastname;
my $u_organization;
my $u_areacode;
my $u_phonenumber;
my $u_extension;
my $u_email;
my $u_isactive;
my $u_accesstype;
my @u_privlist;
my $a_id;
my $a_location;
my $a_username;
my $a_firstname;
my $a_lastname;
my $a_organization;
my $a_areacode;
my $a_phonenumber;
my $a_extension;
my $a_password;
my $a_email;
my $a_accesstype;
my @a_privlist;
my $urllocation;
my $def_password = $ENV{'DefPassword'};

$ENV{SCRIPT_NAME} =~ m%(.*/)(.*)\..*$%;
my $path = $1;
my $form = $2;

my $username = $crdcgi->param("username");
my $userid = $crdcgi->param("userid");
my $schema = $crdcgi->param("schema");
# Set server parameter
my $Server = $crdcgi->param("server");
if (!(defined($Server))) {$Server=$CRDServer;}
&checkLogin($username, $userid, $schema);

my $command = $crdcgi->param("command");

$dbh = db_connect();
#$dbh = db_connect(server => 'ydoracle');
my $userQuery = $dbh->prepare("select u.id, u.username, u.lastname, u.firstname, u.location, u.organization from $schema.users u, $schema.user_privilege p where p.privilege = ? and u.id >= ? and u.id <= ? and u.id = p.userid and u.isactive = 'T' order by u.lastname, u.firstname");


###################################################################################################################################
sub doAlertBox {
###################################################################################################################################
   my %args = (
      text => "",
      includeScriptTags => 'T',
      @_,
   );

   my $outputstring = '';
   $args{text} =~ s/\n/\\n/g;
   $args{text} =~ s/'/%27/g;
   if ($args{includeScriptTags} eq 'T') {$outputstring .= "<script language=javascript>\n<!--\n";}
   $outputstring .= "var mytext ='$args{text}';\nalert(unescape(mytext));\n";
   if ($args{includeScriptTags} eq 'T') {$outputstring .= "//-->\n</script>\n";}

   return ($outputstring);

}


###################################################################################################################################
sub getTitle {
###################################################################################################################################
   my %args = (
      @_,
   );
   my $title = "";
   if (($args{command} eq "adduser") || ($args{command} eq "adduserform")) {
      $title = "Add User";
   } elsif (($args{command} eq "updateuser") || ($args{command} eq "updateuser1") || ($args{command} eq "updateuser2") || ($args{command} eq "updateuserform") || ($args{command} eq "updateuser2form")) {
      $title = "Update User";
   } elsif (($args{command} eq "browse") || (($args{command} eq "displayuser")) || ($args{command} eq "displayuserform")) {
      $title = "Browse User";
   } elsif (($args{command} eq "becomeusername") || ($args{command} eq "becomeusernameform")) {
      $title = "Become Another User";
   } elsif (($args{command} eq "changepassword") || (($args{command} eq "changepasswordform"))) {
      $title = "Change Password";
   }
   return ($title);
}

###################################################################################################################################
sub writeUserTable {
###################################################################################################################################
   my %args = (
      privilege => 1,
      startID => 1,
      endID => 1000,
      titleBackground => '#cdecff',
      titleForeground => '#000099',
      align => 'center',
      @_,
   );
   &start_table(4, $args{align}, 140, 100, 120, 240);  # output discarded
   my $output = "<a name='$args{title}'></a>\n";
   $output .= "<table width=600 cellpadding=4 cellspacing=0 border=1 align=$args{align}>\n";
   $output .= &title_row($args{titleBackground}, $args{titleForeground}, $args{title});
   $output .= &add_header_row();
   $output .= &add_col() . "Name" . &add_col() . "Username" . &add_col() . "Location" . &add_col() . "Organization";
   $userQuery->bind_param(1, $args{privilege});
   $userQuery->bind_param(2, $args{startID});
   $userQuery->bind_param(3, $args{endID});
   $userQuery->execute;
   while (my @values = $userQuery->fetchrow_array) {
      my ($id, $username, $lastname, $firstname, $location, $organization) = @values;
      $output .= &add_row();
      $output .= &add_col_link("javascript:DisplayUser($id)") . &get_fullname($dbh, $schema, $id);
      $output .= &add_col() . $username . &add_col() . $location . &add_col() . $organization;
   }
   $userQuery->finish;
   $output .= &end_table() . "<br><b><a href=#top>Back to Top</a></b><br><br>\n";
   return ($output);
}


###################################################################################################################################
sub doTestPassword {  # routine to test if a password follows the rules
###################################################################################################################################
    my %args = (
        password => '',
        username => "dummytestusernamenotlikelytoeverbeused",
        minLength => 8,
        @_,
    );
    my $acceptable = "T";
    my @commonStrings = ("1234","abcd","qwert","asdfg","zxcvb","poiuy","lkjh","password");
    my $tempPassword;
    if (length($args{password}) < $args{minLength}) {$acceptable = 'F';} # must be minLength or longer
    if (index(uc($args{password}), uc($args{username})) >=0) {$acceptable = 'F';} # cannot include username
    if (index(uc($args{password}), uc(reverse($args{username}))) >=0) {$acceptable = 'F';} # cannot include reverse of username
    foreach my $val (@commonStrings) {
        if (index(uc($args{password}), uc($val)) >=0) {$acceptable = 'F';} # cannot include a common string
        if (index(uc($args{password}), uc(reverse($val))) >=0) {$acceptable = 'F';} # cannot include reverse of common string
    }
    if ($args{password} =~ /^\d|\d$/) {$acceptable = 'F';} # cannot start or end with a digit
    my $passCount = 0;
    # simple password rules
    if ($args{password} =~ /\d/) {$passCount++;} # does the password contain a digit
    if ($args{password} =~ /[A-Z]/) {$passCount++;} # does the password contain an upper case letter
    if ($args{password} =~ /[a-z]/) {$passCount++;} # does the password contain a lower case letter
    if ($args{password} =~ /\W/) {$passCount++;} # does the password contain a non alphanumeric character
    if ($passCount < 3) {$acceptable = 'F';} # must pass at least 3 of the simple password rules
    
    return($acceptable);
}


###################################################################################################################################
sub isReusedPassword {  # routine to test if user reused an old password
###################################################################################################################################
    my %args = (
        userID => 0,
        password => "password",
        @_,
    );
    my $status = 0;

    eval {
        my $testPassword = &db_encrypt_password($args{password});
        my (@passwords) = $args{dbh}->selectrow_array("SELECT oldpassword1, oldpassword2, oldpassword3, oldpassword4, oldpassword5, " .
              "oldpassword6 FROM $args{schema}.users WHERE id=$args{userID}");
        for (my $i=0; $i<=$#passwords; $i++) {
            if ($passwords[$i] eq $testPassword) {
                $status = 1;
            }
        }
    };
    if ($@) {
        my $errMessage = $@;
        $args{dbh}->rollback;
        die $errMessage;
    }

    return ($status);
}


###################################################################################################################################
###################################################################################################################################

# tell the browser that this is an html page using the header method
print $crdcgi->header('text/html');

# output page header
print "<html>\n";
print "<head>\n";
print "<title>CRD User Functions</title>\n";
print "<!-- include external javascript code -->\n";
print "   <script src=$CRDJavaScriptPath/utilities.js></script>\n";
print "   <script src=$CRDJavaScriptPath/widgets.js></script>\n";
print " \n";
print "<!-- declare javascript functions unique to this form -->\n";
print <<ENDOFJAVASCRIPTFUNCTIONS;
<script language=javascript><!--

function verify_$form (f){
// javascript form verification routine
  var msg = "";
  if (f.command.value == 'changepassword') {
    if (isblank(f.oldpassword.value) || isblank(f.newpassword.value) || isblank(f.newpassword2.value)) {
      msg += "All form fields must be entered.\\n";
    }
    if (f.newpassword.value != f.newpassword2.value) {
      msg += "New password entries do not match.\\n";
    }
    if (f.oldpassword.value == f.newpassword.value) {
      msg += "Old password and New password can not be the same.\\n";
    }
  } else if (f.command.value == 'adduser') {
    if (isblank(f.lastname.value) || isblank(f.firstname.value) || isblank(f.organization.value) || isblank (f.location.value) ||
        isblank(f.email.value) || isblank(f.areacode.value) || isblank(f.phonenumber.value)) {
      msg += "All form fields must be entered.\\n";
    }
    if (!(isblank(f.email.value)) && f.email.value.indexOf('\@') <= 1) {
        msg += "A Valid e-mail address must be entered \\n";
    }
    if (!(isnumeric(f.areacode.value))) {
        msg += "Area Code must be a number \\n";
    }
    f.phonenumber.value = f.phonenumber.value.replace(/-/g,"");
    if (!(isnumeric(f.phonenumber.value))) {
        msg += "Phone Number must be a number of the form 794-1234 or 7941234\\n";
    }
    if (!((isblank(f.phoneextension.value)) || (isnumeric(f.phoneextension.value)))) {
        msg += "Phone Extension must be a number \\n";
    }
    for (index=0; index < f.privlist.length-1;index++) {
        f.privlist.options[index].selected = true;
    }
  } else if (f.command.value == 'updateuser2') {
    if (isblank(f.lastname.value) || isblank(f.firstname.value) || isblank(f.organization.value) || isblank (f.location.value) ||
        isblank(f.email.value) || isblank(f.areacode.value) || isblank(f.phonenumber.value)) {
      msg += "All form fields must be entered.\\n";
    }
    if (!(isblank(f.email.value)) && f.email.value.indexOf('\@') <= 1) {
        msg += "A Valid e-mail address must be entered \\n";
    }
    if (!(isnumeric(f.areacode.value))) {
        msg += "Area Code must be a number \\n";
    }
    f.phonenumber.value = f.phonenumber.value.replace(/-/g,"");
    if (!(isnumeric(f.phonenumber.value))) {
        alert (f.phonenumber.value);
        msg += "Phone Number must be a number of the form 794-1234 or 7941234\\n";
    }
    if (!((isblank(f.phoneextension.value)) || (isnumeric(f.phoneextension.value)))) {
        msg += "Phone Extension must be a number \\n";
    }
    for (index=0; index < f.privlist.length-1;index++) {
        f.privlist.options[index].selected = true;
    }
  }
  if (msg != "") {
    alert (msg);
    return false;
  }
  return true;
}

function submitForm(script, command) {
    document.$form.command.value = command;
    document.$form.action = '$path' + script + '.pl';
    document.$form.target = 'main';
    document.$form.submit();
}


function submitFormDummy(script, command) {
    document.dummy$form.command.value = command;
    document.dummy$form.action = '$path' + script + '.pl';
    document.dummy$form.target = 'main';
    document.dummy$form.submit();
}


function submitFormHeader() {
    document.$form.command.value = 'header';
    document.$form.action = '$path' + script + '.pl';
    document.$form.target = 'header';
    document.$form.submit();
}

function submitFormStatus(script,username,userid) {
    document.$form.username.value = username;
    document.$form.userid.value = userid;
    document.$form.target = 'status';
    document.$form.action = '$path' + script + '.pl';
    document.$form.submit();
}

function DisplayUser(id) {
    document.dummy$form.id.value = id;
    submitFormDummy('user_functions', 'displayuser');
}

//-->
</script>

ENDOFJAVASCRIPTFUNCTIONS
print " \n";
print "</head>\n";
print "<body background=$CRDImagePath/background.gif text=#000099 link=#0000ff vlink=#0000ff alink=#0000ff topmargin=0 leftmargin=0><center>\n";
print "<font face=\"$CRDFontFace\" color=$CRDFontColor>\n";
my $title = &getTitle(command => $command);
print  &writeTitleBar(userName => $username, userID => $userid, schema => $schema, title => $title);
print "<br>";

# set up form for whole page
    # setup form for the page
    print "<form name=\"$form\" target=cgiresults onSubmit=\"return verify_$form(this)\" action=\"" . $path . "user_functions.pl\" method=post>\n";
    # use hidden fields to keep track of the user.  Populate them with the username and the userid
    print "<input type=hidden name=username value=\"$username\">\n";
    print "<input type=hidden name=userid value=\"$userid\">\n";
    print "<input type=hidden name=schema value=\"$schema\">\n";
    print "<input type=hidden name=server value=$Server>\n";
    print "<input type=hidden name=id value=0>\n";
print "<table border=0 width=750><tr><td>\n";

if ((index($command,"form") == -1) && ($command ne "browse")) {
    # process passed data =======================================================================================

    if ($command eq "adduser") {
        # process add user form ---------------------------------------------------------------------------------------------
        $a_location = ((defined($crdcgi->param("location"))) ? $crdcgi->param("location") : "");
        $a_location =~ s/'/''/g;
        $a_firstname = ((defined($crdcgi->param("firstname"))) ? $crdcgi->param("firstname") : "");
        $a_firstname =~ s/'/''/g;
        $a_lastname = ((defined($crdcgi->param("lastname"))) ? $crdcgi->param("lastname") : "");
        $a_lastname =~ s/'/''/g;
        $a_organization = ((defined($crdcgi->param("organization"))) ? $crdcgi->param("organization") : "");
        $a_organization =~ s/'/''/g;
        $a_areacode = ((defined($crdcgi->param("areacode"))) ? $crdcgi->param("areacode") : "");
        $a_phonenumber = ((defined($crdcgi->param("phonenumber"))) ? $crdcgi->param("phonenumber") : "");
        $a_extension = ((defined($crdcgi->param("phoneextension"))) ? $crdcgi->param("phoneextension") : "");
        $a_email = ((defined($crdcgi->param("email"))) ? $crdcgi->param("email") : "");
        $a_email =~ s/'/''/g;
        $a_accesstype = $crdcgi->param("accesstype");
        @a_privlist = $crdcgi->param("privlist");

        # generate username
        if (length($a_lastname) >7) {
            $a_username = substr (uc($a_lastname), 0, 7) . substr(uc($a_firstname), 0, 1);
        } else {
            $a_username = uc($a_lastname) . substr(uc($a_firstname), 0, 1);
        }

        # remove dash from phone number
        $a_phonenumber =~ s/-//;

        # test to see if username already exists
        $sqlquery = "select id, firstname, lastname from $schema.users where username = '$a_username'";
        eval {
            $csr = $dbh->prepare($sqlquery);
            $csr->execute;
            @values = $csr->fetchrow_array;
            $csr->finish;
        };
        if ($#values >= 0 || $@) {
            $message = "Error, username $a_username already in use by \\n   $values[1] $values[2].";

        # process new user
        } else {
            eval {
                $a_id = &get_next_users_id($dbh, $schema);
            };
            if ($@) {
                $message = errorMessage($dbh,$username,$userid,$schema,"get next users id.",$@);
                #$message =~ s/\n/\\n/g;
            }
            $a_password = db_encrypt_password(uc($def_password));
            if ((defined($a_extension))) { $a_extension =~ s/ //g; }
            if ((!(defined($a_extension))) || ($a_extension le ' ')) { $a_extension = 'NULL'; }
            $sqlquery = "INSERT INTO $schema.users (id, location, username, firstname, lastname, organization, areacode, phonenumber, extension, password, email, isactive, accesstype) VALUES ($a_id, '$a_location', '$a_username', '$a_firstname', '$a_lastname', '$a_organization', $a_areacode, $a_phonenumber, $a_extension, '$a_password', '$a_email', 'T', $a_accesstype)";
            eval {
                $csr = $dbh->prepare($sqlquery);
                $status = $csr->execute;
                $csr->finish;
                $dbh->commit;
            };

            # if successful inserting user, process privs
            if ($status && !($@)) {
                $message = "User $a_username was created with password \"$def_password\"";
                $status = log_activity ($dbh, $schema, $userid, "$a_username was created");
                $urllocation = "$ENV{SCRIPT_NAME}?username=$username&userid=$userid&command=adduserform&schema=$schema";
                eval {
                    for (my $i=0; $i <= $#a_privlist; $i++) {
                        $sqlquery = "INSERT INTO $schema.user_privilege (userid, privilege) VALUES ($a_id, $a_privlist[$i])";
                        $csr = $dbh->prepare($sqlquery);
                        $status = $csr->execute;
                        $csr->finish;
                        $dbh->commit;
                    }
                };
                if (!($status) || $@) {
                    $message = errorMessage($dbh,$username,$userid,$schema,"Error setting up privleges for $a_username.",$@);
                    #$message =~ s/\n/\\n/g;
                    $urllocation = "$ENV{SCRIPT_NAME}?username=$username&userid=$userid&command=updateuser1&a_username=$a_username&schema=$schema";
                }
            } else {
                $message = errorMessage($dbh,$username,$userid,$schema,"Error creating user, save this information for user support.",$@);
                #$message =~ s/\n/\\n/g;
            }

        }

    } elsif ($command eq "updateuser") {
        # process update user form ---------------------------------------------------------------------------------------------

        $u_username = uc($crdcgi->param("u_username"));

        $sqlquery = "select id,location,username,firstname,lastname,organization,areacode,phonenumber,extension,email,isactive,accesstype from $schema.users where username = '$u_username'";
        eval {
            $csr = $dbh->prepare($sqlquery);
            $csr->execute;
            @values = $csr->fetchrow_array;
            $csr->finish;
        };
        if ($#values < 0 || $@) {
            $message = "User " . $u_username . " does not exist";
        } else {
            $urllocation = "$ENV{SCRIPT_NAME}?username=$username&userid=$userid&command=updateuser1&u_username=$u_username&schema=$schema";
        }

    } elsif ($command eq "updateuser1") {
        # process update user form ---------------------------------------------------------------------------------------------

        $u_username = uc($crdcgi->param("u_username"));

        $sqlquery = "select id,location,username,firstname,lastname,organization,areacode,phonenumber,extension,email,isactive,accesstype  from $schema.users where username = '$u_username'";
        eval {
            $csr = $dbh->prepare($sqlquery);
            $csr->execute;
            @values = $csr->fetchrow_array;
            $csr->finish;
        };
        if ($#values < 0 || $@) {
            $message = errorMessage($dbh,$username,$userid,$schema,"do a user lookup.",$@);
            #$message =~ s/\n/\\n/g;
        } else {
            $u_id = $values[0];
            $u_location = ((defined($values[1])) ? $values[1] : "");
            $u_username = $values[2];
            $u_firstname = $values[3];
            $u_lastname = $values[4];
            $u_organization = ((defined($values[5])) ? $values[5] : "");
            $u_areacode = ((defined($values[6])) ? $values[6] : "");
            $u_phonenumber = ((defined($values[7])) ? $values[7] : "");
            $u_extension = ((defined($values[8])) ? $values[8] : "");
            $u_email = ((defined($values[9])) ? $values[9] : "");
            $u_isactive = $values[10];
            $u_accesstype = $values[11];

            if ($u_phonenumber gt ' ' || $u_phonenumber > 0) {
                $u_phonenumber = substr($u_phonenumber, 0, 3) . '-' . substr($u_phonenumber, 3,4);
            }

            $command = "updateuser2form";
        }

    } elsif ($command eq "updateuser2") {
        # process update user form ---------------------------------------------------------------------------------------------

        $u_id = $crdcgi->param("u_id");
        $u_location = $crdcgi->param("location");
        $u_location =~ s/'/''/g;
        $u_username = $crdcgi->param("u_username");
        $u_username =~ s/'/''/g;
        eval {
            $u_username = get_username($dbh,$schema,$u_id);
        };
        if ($@) {
            $message = errorMessage($dbh,$username,$userid,$schema,"get username.",$@);
            #$message =~ s/\n/\\n/g;
        }
        $u_firstname = ((defined($crdcgi->param("firstname"))) ? $crdcgi->param("firstname") : "");
        $u_firstname =~ s/'/''/g;
        $u_lastname = ((defined($crdcgi->param("lastname"))) ? $crdcgi->param("lastname") : "");
        $u_lastname =~ s/'/''/g;
        $u_organization = ((defined($crdcgi->param("organization"))) ? $crdcgi->param("organization") : "");
        $u_organization =~ s/'/''/g;
        $u_areacode = ((defined($crdcgi->param("areacode"))) ? $crdcgi->param("areacode") : "");
        $u_phonenumber = ((defined($crdcgi->param("phonenumber"))) ? $crdcgi->param("phonenumber") : "");
        $u_extension = ((defined($crdcgi->param("phoneextension"))) ? $crdcgi->param("phoneextension") : "");
        $u_email = ((defined($crdcgi->param("email"))) ? $crdcgi->param("email") : "");
        $u_email =~ s/'/''/g;
        $u_accesstype = $crdcgi->param("accesstype");
        @u_privlist = $crdcgi->param("privlist");

        # remove dash from phone number
        $u_phonenumber =~ s/\-//;

        # if extension is blank set it to NULL
        if ((defined($u_extension))) { $u_extension =~ s/ //g; }
        if (!(defined($u_extension)) || $u_extension le ' ') { $u_extension = 'NULL'; }
            # update user info
            $sqlquery = "UPDATE $schema.users SET location = '$u_location', firstname = '$u_firstname', lastname = '$u_lastname', organization = '$u_organization', areacode = $u_areacode, phonenumber = $u_phonenumber, extension = $u_extension, email = '$u_email', accesstype = $u_accesstype WHERE id = $u_id";
            eval {
                $csr = $dbh->prepare($sqlquery);
                $status = $csr->execute;
                $csr->finish;
                $dbh->commit;
            };

            # if successful, update priv info
            if ($status && !($@)) {
                $message = "User $u_username Updated";
                $status = log_activity ($dbh, $schema, $userid, "$message");
                $urllocation = "$ENV{SCRIPT_NAME}?username=$username&userid=$userid&command=updateuser1&u_username=$u_username&schema=$schema";

                # update privs
                $sqlquery = "DELETE FROM $schema.user_privilege WHERE (userid = $u_id) AND (privilege > 0)";
                eval {
                    $csr = $dbh->prepare($sqlquery);
                    $status = $csr->execute;
                    $csr->finish;
                    $dbh->commit;
                };
                if ($status && !($@)) {
                    for (my $i=0; $i<=$#u_privlist; $i++) {
                        $sqlquery = "INSERT INTO $schema.user_privilege (userid, privilege) VALUES ($u_id, $u_privlist[$i])";
                        eval {
                            $csr = $dbh->prepare($sqlquery);
                            $status = $csr->execute;
                            $csr->finish;
                            $dbh->commit;
                        };
                    }
                    if (!($status) || $@) {
                        $message = errorMessage($dbh,$username,$userid,$schema,"update user privs for $u_username. (insert)",$@);
                        #$message =~ s/\n/\\n/g;
                    }

                } else {
                    $message = errorMessage($dbh,$username,$userid,$schema,"update user privs for $u_username. (remove)",$@);
                    #$message =~ s/\n/\\n/g;
                }

            } else {
                $message = errorMessage($dbh,$username,$userid,$schema,"update user $u_username.",$@);
                #$message =~ s/\n/\\n/g;
            }

    } elsif ($command eq "disableuser") {
        # process update user form (disable user) ---------------------------------------------------------------------------------------------

        $u_id = uc($crdcgi->param("u_id"));
        $sqlquery = "update $schema.users set isactive = 'F' where id = $u_id";
        eval {
            $u_username = uc(get_username($dbh,$schema,$u_id));
            $csr = $dbh->prepare($sqlquery);
            $csr->execute;
            $csr->finish;
            $dbh->commit;
        };
        if ($@) {
            $message = errorMessage($dbh,$username,$userid,$schema,"disable user $u_username.",$@);
            #$message =~ s/\n/\\n/g;
        } else {
            $message = "User $u_username Disabled";
            $status = log_activity ($dbh, $schema, $userid, "$message");
            $urllocation = "$ENV{SCRIPT_NAME}?username=$username&userid=$userid&command=updateuser1&u_username=$u_username&schema=$schema";
        }

    } elsif ($command eq "enableuser") {
        # process update user form (enable user) ---------------------------------------------------------------------------------------------

        $u_id = uc($crdcgi->param("u_id"));
        $sqlquery = "update $schema.users set isactive = 'T' where id = $u_id";
        eval {
            $u_username = uc(get_username($dbh,$schema,$u_id));
            $csr = $dbh->prepare($sqlquery);
            $csr->execute;
            $csr->finish;
            $dbh->commit;
        };
        if ($@) {
            $message = errorMessage($dbh,$username,$userid,$schema,"enable user $u_username.",$@);
            #$message =~ s/\n/\\n/g;
        } else {
            $message = "User $u_username Enabled";
            $status = log_activity ($dbh, $schema, $userid, "$message");
            $urllocation = "$ENV{SCRIPT_NAME}?username=$username&userid=$userid&command=updateuser1&u_username=$u_username&schema=$schema";
        }

    } elsif ($command eq "resetpassword") {
        # process update user form (reset password) ---------------------------------------------------------------------------------------------

        $u_id = uc($crdcgi->param("u_id"));
        my $new_password = db_encrypt_password(uc($def_password));
        $sqlquery = "update $schema.users set password = '$new_password' where id = $u_id";
        eval {
            $u_username = uc(get_username($dbh,$schema,$u_id));
            $csr = $dbh->prepare($sqlquery);
            $csr->execute;
            $csr->finish;
            $dbh->commit;
        };

        if ($@) {
            $message = errorMessage($dbh,$username,$userid,$schema,"reset password for $u_username.",$@);
            #$message =~ s/\n/\\n/g;
        } else {
            $message = "Password for $u_username has been reset to \"$def_password\"";
            $status = log_activity ($dbh, $schema, $userid, "$message");
            $urllocation = "$ENV{SCRIPT_NAME}?username=$username&userid=$userid&command=updateuser1&u_username=$u_username&schema=$schema";
        }


    } elsif ($command eq "becomeusername") {
        # process become username ---------------------------------------------------------------------------------------------

        my $newuserid = uc($crdcgi->param("newuserid"));
        my $newusername;
        eval {
            $newusername = get_username($dbh, $schema, $newuserid);
        };
        if ($@) {
            $message = errorMessage($dbh,$username,$userid,$schema,"get new username.",$@);
            #$message =~ s/\n/\\n/g;
        }
        $username = $newusername;
        $userid = $newuserid;
        $message = "Changing current username/userid to $newusername/$newuserid";
        $urllocation = $path . "home.pl?username=$username&userid=$userid&schema=$schema";

        print "<script language=javascript><!--\n";
        print "   parent.header.location='" . $path . "header.pl?username=$username&userid=$userid&schema=$schema&command=header';\n";
        #print "   parent.status.location='" . $path . "header.pl?username=$username&userid=$userid&schema=$schema&command=title';\n";
        print "//--></script>\n";
         print "<input type=hidden name=title value=home>\n";
         print "<script language=javascript><!--\n";
         print "   submitFormStatus('title_bar','$username','$userid');\n";
         print "//--></script>\n";
    } elsif ($command eq "displayuser") {
        # process display user ---------------------------------------------------------------------------------------------

        my $displayid = $crdcgi->param("id");
        $sqlquery = "SELECT id,location,username,firstname,lastname,organization,areacode,phonenumber,extension,email,accesstype,failedattempts,lockout FROM $schema.users WHERE id = $displayid ORDER BY id";
        eval {
            $csr = $dbh->prepare($sqlquery);
            $csr->execute;
            @values = $csr->fetchrow_array;
            $csr->finish;
        };
        if ($@) {
            $message = errorMessage($dbh,$username,$userid,$schema,"display user info.",$@);
            #$message =~ s/\n/\\n/g;
        }
        if (defined(@values) && $#values >=0) {
            $command = 'displayuserform';
            $uservalues[0][0] = 'User Information';
            $uservalues[1][0] ='<b>User ID:</b>' . &nbspaces(2);
            $uservalues[1][1] ='<b>' . $values[0] . '</b>';
            $uservalues[2][0] ='<b>Username:</b>' . &nbspaces(2);
            $uservalues[2][1] ='<b>' . $values[2] . '</b>';
            $uservalues[3][0] ='<b>Name:</b>' . &nbspaces(2);
            $uservalues[3][1] ="<b>$values[3] $values[4]</b>";
            $uservalues[4][0] ='<b>Location:</b>' . &nbspaces(2);
            $uservalues[4][1] ='<b>' . $values[1] . '</b>';
            $uservalues[5][0] ='<b>Organization:</b>' . &nbspaces(2);
            $uservalues[5][1] ='<b>' . $values[5] . '</b>';
            $uservalues[6][0] ='<b>Phone Number:</b>' . &nbspaces(2);
            my $ext = (!(defined($values[8])) || $values[8] eq "") ? "" : " ext. $values[8]";
            $uservalues[6][1] ="<b>($values[6]) " . substr($values[7],0,3) . "-" . substr($values[7],3,4) . "$ext</b>";
            $uservalues[7][0] ='<b>Email Address:</b>' . &nbspaces(2);
            $uservalues[7][1] ='<b>' . $values[9] . '</b>';
            $uservalues[8][0] ='<b>Access Type:</b>' . &nbspaces(2);
            $sqlquery = "SELECT name FROM $schema.system_access_type WHERE id = $values[10]";
            eval {
                $csr = $dbh->prepare($sqlquery);
                $csr->execute;
                @values = $csr->fetchrow_array;
                $csr->finish;
            };
            if ($@) {
                $message = errorMessage($dbh,$username,$userid,$schema,"display user access type.",$@);
                #$message =~ s/\n/\\n/g;
            }
            $uservalues[8][1] ='<b>' . $values[0] . '</b>';
            $uservalues[9][0] ='<b>Privileges:</b>';
            $uservalues[9][1] ='<b>';
            $sqlquery = "SELECT spriv.id,spriv.name FROM $schema.user_privilege upriv, $schema.system_privilege spriv WHERE (upriv.privilege=spriv.id) AND (upriv.userid = $displayid)";
            eval {
                $csr = $dbh->prepare($sqlquery);
                $csr->execute;
                while (@values = $csr->fetchrow_array) {
                    if ($values[0] > 1) {
                        $uservalues[9][1] .= '<br>';
                    }
                    $uservalues[9][1] .= $values[1];
                    if ($values[0] < 0) {
                        $uservalues[9][1] .= '<br>';
                    }
                }
                $uservalues[9][1] .='</b>';

                $csr->finish;
            };
            if ($@) {
                $message = errorMessage($dbh,$username,$userid,$schema,"display user privilege info.",$@);
                #$message =~ s/\n/\\n/g;
            }
            $uservalues[10][0] = '<b>Failed Logins:</b>';
            $uservalues[10][1] = "<b>" . ((defined($values[11])) ? $values[11] : "0") . "</b>";
            $uservalues[11][0] = '<b>Lockout Time:</b>';
            $uservalues[11][1] = '<b>' . ((defined($values[12])) ? $values[12] : "&nbsp;") . '</b>';
        } else {
            $message = "No user matches specified number of $displayid";
        }


    } elsif ($command eq "changepassword") {
        # process change password form ---------------------------------------------------------------------------------------------

        my $oldpassword = $crdcgi->param("oldpassword");
        $oldpassword =~ s/'/''/g;
        my $newpassword = $crdcgi->param("newpassword");
        $newpassword =~ s/'/''/g;
        my $newpasswordsave = $newpassword;

        my $test_password;

        my $oldpasswordUC = &db_encrypt_password(uc($oldpassword));
        $oldpassword = &db_encrypt_password($oldpassword);
        $newpassword = &db_encrypt_password($newpassword);

        # get old password
        $sqlquery = "select password  from $schema.users where username = '$username'";
        eval {
            $csr = $dbh->prepare($sqlquery);
            $csr->execute;
            @values = $csr->fetchrow_array;
            $csr->finish;
        };

        # check for error, should never occur
        if ($#values < 0 || $@) {
            $message = errorMessage($dbh,$username,$userid,$schema,"get old password from DB.",$@);
            #$message =~ s/\n/\\n/g;
        } else {
            ($test_password) = @values;
            my $reusedPassword = &isReusedPassword(dbh => $dbh, schema => $schema, userID => $userid, password=>$newpasswordsave);
            if ($test_password ne $oldpassword && $test_password ne $oldpasswordUC) {
                $message = "Incorrect old password, try again";

            } elsif (uc($newpassword) eq uc($DefPassword)) {
                $message = "Can not use the Default Password, try again";

            } elsif (&doTestPassword(password => $newpasswordsave, username => $username) ne 'T' || $reusedPassword) {
                $message = "Does not meet password security requirements";

            # process the change
            } else {
                # set old passwords
                for (my $i=5; $i>=1; $i--) {
                    my $j = $i + 1;
                    $status = $dbh->do("UPDATE $schema.users SET oldpassword$j=oldpassword$i WHERE id=$userid");
                }
                # change the password
                $sqlquery = "update $schema.users set password = '$newpassword', " .
                    "datepasswordexpires = ADD_MONTHS(SYSDATE, $SYSPasswordExpireMonths), oldpassword1='$oldpassword' where username = '$username'";
                eval {
                    $csr = $dbh->prepare($sqlquery);
                    $csr->execute;
                    $csr->finish;
                    $dbh->commit;
                };
                if ($@) {
                    $message = errorMessage($dbh,$username,$userid,$schema,"change password.",$@);
                    #$message =~ s/\n/\\n/g;
                }
                # verify that the password changed
                $sqlquery = "select password  from $schema.users where username = '$username'";
                eval {
                    $csr = $dbh->prepare($sqlquery);
                    $csr->execute;
                    @values = $csr->fetchrow_array;
                    $csr->finish;
                };
                if (($#values < 0) || ($newpassword ne $values[0]) || $@) {
                    $message = errorMessage($dbh,$username,$userid,$schema,"verify password change.",$@);
                    #$message =~ s/\n/\\n/g;
                } else {
                    $message = "user $username password changed";
                    $status = log_activity ($dbh, $schema, $userid, "$message");
                    $urllocation = $path . "utilities.pl?username=$username&userid=$userid&schema=$schema";
                    print "<script language=javascript><!--\n";
                    print "   newurl = '" . $path . "header.pl?username=$username&userid=$userid&schema=$schema&command=header';";
                    print "   parent.header.location=newurl;\n";
                    print "//--></script>\n";

                }
            }
        }
    }
}

#=============================================================================================================

# display any messages generated by the script
print "<script language=javascript><!--\n";
if (defined($message) && $message gt " ") {
    #print "   alert('$message');\n";
    print doAlertBox( text => $message,includeScriptTags => 'F');
}

# send the main frame to the requested url
if (defined($urllocation) && $urllocation gt ' ') {
    # close connection to the oracle database
    db_disconnect($dbh);

    print "   var newurl ='$urllocation';\n";
    print "   parent.main.location=newurl;\n";

    # reset the cgiresults frame to a blank page to help avoid reprocessing of scripts
    print "   location='" . $path . "blank.pl';\n";
}
print "//--></script>\n";

if ((index($command,"form") != -1) || ($command eq "browse")) {
    # generate forms ============================================================================================

    # use a hidden field to tell the next cgi what to do
    print "<input type=hidden name=command value=\"" . substr($command,0,index($command,"form")) . "\">\n";

    if ($command eq "adduserform") {
        # generate add user form ---------------------------------------------------------------------------------------------
        print <<ENDOFBLOCK;

<center>
<table border=0 width=680>

<tr><td colspan=4 align=center><table border=0 width=650>
<tr><td><b>Last Name: </b>&nbsp;&nbsp;</td><td><input type=text name="lastname" maxlength=15 size=10></td><td><b>First Name: </b>&nbsp;&nbsp;</td><td><input type=text name="firstname" maxlength=15 size=10>&nbsp;&nbsp;</td></tr>
<tr><td colspan=4><br></td></tr>
<tr><td><b>Organization: </b>&nbsp</td><td><input type=text name="organization" maxlength=25 size=20></td>
<td><b>Location: </b>&nbsp</td><td><input type=text name="location" maxlength=25 size=20></td></tr>
<tr><td colspan=4><br></td></tr>
<tr><td><b>E-mail: </b>&nbsp</td><td><input type=text name="email" maxlength=50 size=25></td>
<td><b>Phone Number: </b>&nbsp</td><td><input type=text size=3 maxlength=3 name=areacode> - <input type=text size=7 maxlength=8 name=phonenumber><b>&nbsp;ext. </b><input type=text size=4 maxlength=5 name=phoneextension></td><td>&nbsp;</td></tr>
<tr><td colspan=4><br></td></tr>

ENDOFBLOCK
        my %accesstypes;
        eval {
            %accesstypes = &get_lookup_values ($dbh, $schema, 'system_access_type', 'id', 'name');
        };
        if ($@) {
            $message = errorMessage($dbh,$username,$userid,$schema,"get access types.",$@);
            #$message =~ s/\n/\\n/g;
        }
        print "<tr><td><b>Accesstype: </b>&nbsp</td><td>" . &build_drop_box('accesstype', \%accesstypes, '2') . "</td></tr>\n";
        print <<ENDOFBLOCK;

<tr><td></td><td colspan=3><br></td></tr>

<tr><td colspan=4 align=center>
ENDOFBLOCK

        my %userprivs;
        eval {
            %userprivs = &get_lookup_values ($dbh, $schema, 'system_privilege', 'id', 'name', 'id > 0');
        };
        if ($@) {
            $message = errorMessage($dbh,$username,$userid,$schema,"get user privileges.",$@);
            #$message =~ s/\n/\\n/g;
        }
        my %currprivs;
        $currprivs{'1'} = 'READ ONLY';
        print build_dual_select ('privlist', "$form", \%userprivs, \%currprivs, "Available Privileges", "Selected Privileges", "1");

        print <<ENDOFBLOCK
</td></tr>
</table></td></tr>
<tr><td colspan=4>&nbsp;<hr></td></tr>
<tr><td colspan=4 align=center><input type="submit" name="submit" value="Submit User Information"></td></tr>
</table>
</center>

ENDOFBLOCK

    } elsif ($command eq "updateuserform") {
        print <<ENDOFBLOCK;
<center>
<table border=0 width=680>
<tr><td colspan=4 align=center>
<table border=0>
ENDOFBLOCK
        tie my %availusers, "Tie::IxHash";
        eval {
        #    %availusers = &get_lookup_values ($dbh, $schema, 'users', 'username', "firstname || ' ' || lastname", 'id = id ORDER BY username');
            print "<tr><td><b>Select User: </b>&nbsp;</td><td><select name=u_username size=1>\n";
            my $csr = $dbh->prepare("SELECT username, firstname || ' ' || lastname FROM $schema.users ORDER BY username");
            my $status = $csr->execute;
            while (my ($username, $fullname) = $csr->fetchrow_array) {
                print "<option value='$username'>$fullname</option>\n";
            }
            $csr->finish;
            print "</select></td>\n";
        };
        if ($@) {
            $message = errorMessage($dbh,$username,$userid,$schema,"get available users.",$@);
            #$message =~ s/\n/\\n/g;
        }
        #print "<tr><td><b>Select Username: </b>&nbsp;</td><td>" . &build_drop_box('u_username', \%availusers, '$username') ."</td>\n";
        print <<ENDOFBLOCK;
<td>&nbsp;<input type=submit name="updateuser" value="Retrieve User Information"></td></tr>
</table>
</td></tr>
</table>
</center>

ENDOFBLOCK

    } elsif ($command eq "updateuser2form") {
        print "<center>\n";
        print "<table border=0 width=680>\n";
        print "<tr><td colspan=4 align=center><table border=0>\n";
        tie my %availusers, "Tie::IxHash";
        #eval {
        #    %availusers = &get_lookup_values ($dbh, $schema, 'users', 'username', "firstname || ' ' || lastname", 'id = id ORDER BY username');
        #};
        #if ($@) {
        #    $message = errorMessage($dbh,$username,$userid,$schema,"get available users.",$@);
        #    #$message =~ s/\n/\\n/g;
        #}
        eval {
        #    print "<tr><td><b>Select User: </b>&nbsp;</td><td>" . &build_drop_box('u_username', \%availusers, get_username($dbh,$schema,$u_id));
            print "<tr><td><b>Select User: </b>&nbsp;</td><td><select name=u_username size=1>\n";
            my $csr = $dbh->prepare("SELECT username, firstname || ' ' || lastname FROM $schema.users ORDER BY username");
            my $status = $csr->execute;
            while (my ($username, $fullname) = $csr->fetchrow_array) {
                print "<option value='$username'" . (($username eq $u_username) ? " selected" : "") . ">$fullname</option>\n";
            }
            $csr->finish;
            print "</select>\n";
        };
        if ($@) {
            $message = errorMessage($dbh,$username,$userid,$schema,"get username.",$@);
            #$message =~ s/\n/\\n/g;
        }
        print "</td>\n";
        print "<td>&nbsp;<input type=submit name=updateuser value=\"Retrieve User Information\" onClick=\"document.$form.command.value='updateuser'\"></td></tr>\n";
        print "<tr><td><b>Username: </b>&nbsp;&nbsp;</td><td><b>$u_username</b></td></tr>\n";
        print "<tr><td><b>ID: </b>&nbsp;&nbsp;</td><td><b>". &lpadzero($u_id, 4) . "</b><input type=hidden name=u_id value=$u_id></td></tr>\n";
        print "<tr><td><b>User Status: </b>&nbsp;&nbsp;</td><td><b>";
        if ($u_isactive eq 'T') {
            print "Active";
        } else {
            print "Inactive";
        }
        print "</b></td></tr>\n";
        print "</table></td></tr>\n";
        print "<tr><td colspan=4><hr></td></tr>\n";
        print "<tr><td colspan=4><br></td></tr>\n";
        print "<tr><td colspan=4 align=center><table border=0 width=650>\n";
        print "<tr><td><b>Last Name: </b>&nbsp</td><td><input type=text name=lastname value=\"$u_lastname\" maxlength=25 size=20></td>\n";
        print "<td><b>First Name: </b>&nbsp</td><td><input type=text name=firstname value=\"$u_firstname\" maxlength=25 size=20></td></tr>\n";
        print "<tr><td colspan=4><br></td></tr>\n";
        print "<tr><td><b>Organization: </b>&nbsp</td><td><input type=text name=organization value=\"$u_organization\" maxlength=25 size=20></td>\n";
        print "<td><b>Location: </b>&nbsp</td><td><input type=text name=location value=\"$u_location\" maxlength=25 size=20></td></tr>\n";
        print "<tr><td colspan=4><br></td></tr>\n";
        print "<tr><td><b>E-mail: </b>&nbsp</td><td><input type=text name=email value=\"$u_email\" maxlength=50 size=25></td>\n";
        print "<td><b>Phone Number: </b>&nbsp</td><td><input type=text size=3 maxlength=3 name=areacode value=\"$u_areacode\"> - <input type=text size=7 maxlength=8 name=phonenumber value=\"$u_phonenumber\"><b>ext. </b><input type=text size=4 maxlength=5 name=phoneextension value=\"$u_extension\"></td></tr>\n";
        print "<tr><td colspan=4><br></td></tr>\n";
        my %accesstypes;
        eval {
            %accesstypes = &get_lookup_values ($dbh, $schema, 'system_access_type', 'id', 'name');
        };
        if ($@) {
            $message = errorMessage($dbh,$username,$userid,$schema,"get access types.",$@);
            #$message =~ s/\n/\\n/g;
        }
        print "<tr><td><b>Accesstype: </b>&nbsp</td><td>" . build_drop_box('accesstype', \%accesstypes, $u_accesstype) . "</td></tr>\n";
        print "<tr><td colspan=4><br></td></tr>\n";
        print "<tr><td colspan=4 align=center>\n";
        my %userprivs;
        eval {
            %userprivs = &get_lookup_values ($dbh, $schema, 'system_privilege', 'id', 'name', ' id > 0');
        };
        if ($@) {
            $message = errorMessage($dbh,$username,$userid,$schema,"get user privileges.",$@);
            #$message =~ s/\n/\\n/g;
        }
        my %currprivs;
        $sqlquery = "select u_priv.privilege, s_priv.name from $schema.user_privilege u_priv, $schema.system_privilege s_priv where (u_priv.privilege=s_priv.id) and (u_priv.userid=$u_id) and (u_priv.privilege > 0)";
        eval {
            $csr = $dbh->prepare($sqlquery);
            $csr->execute;
            while (@values = $csr->fetchrow_array) {
                $currprivs{$values[0]} = $values[1];
            }
            $csr->finish;
        };
        if ($@) {
            $message = errorMessage($dbh,$username,$userid,$schema,"display user privileges.",$@);
            #$message =~ s/\n/\\n/g;
        }
        print build_dual_select ('privlist', "$form", \%userprivs, \%currprivs, "<b>Available Privileges</b>", "<b>Selected Privileges</b>", "1", "10");
        print "</td></tr>\n";
        print "</table></td></tr>\n";
        print "<tr><td colspan=4>&nbsp;<hr></td></tr>\n";
        print "<tr><td colspan=4 align=center><input type=submit name=submit value=\"Submit Updated Information\"> &nbsp;\n";
        if ($u_isactive eq 'T') {
            print "<input type=submit name=disable value=\"Disable Account\" onClick=\"document.$form.command.value='disableuser'\"> &nbsp;\n";
        } else {
            print "<input type=submit name=enable value=\"Enable Account\" onClick=\"document.$form.command.value='enableuser'\"> &nbsp;\n";
        }
        print "<input type=submit name=reset value=\"Reset Password\" onClick=\"document.$form.command.value='resetpassword'\"> </td></tr>\n";
        print "</table>\n";
        print "</center>\n";
    } elsif ($command eq "changepasswordform") {
        my $passwordGuidelines = "<b><ul>Password Guidelines<br>";
        $passwordGuidelines .= "<li>- 8 or more characters</li>";
        $passwordGuidelines .= "<li>- can not contain form of username (forward or reverse)</li>";
        $passwordGuidelines .= "<li>- can not use some common strings</li>";
        $passwordGuidelines .= "<li>- can not start or end with a digit</li>";
        $passwordGuidelines .= "<li>- must have three of the following four:<ul>";
        $passwordGuidelines .= "<li> - a special character</li>";
        $passwordGuidelines .= "<li> - a digit<br>";
        $passwordGuidelines .= "<li> - an uppercase letter</li>";
        $passwordGuidelines .= "<li> - a lowercase letter</li></ul></li>";
        $passwordGuidelines .= "<li>- can not reuse the last six passwords</li>";
        $passwordGuidelines .= "</ul></b>\n";
    
        print "<center>\n";
        print "\n<table border=0><tr><td align=center>";
        print "<font size=+1><b>User Name:</b></font><br><b>$username</b><br><br>\n";
        print "<b>Old Password:</b><br><input type=password name=oldpassword size=15 maxlength=15><br><br>\n";
        print "<b>New Password:</b><br><input type=password name=newpassword size=15 maxlength=15><br><br>\n";
        print "<b>Retype New Password:</b><br><input type=password name=newpassword2 size=15 maxlength=15><br><br>\n";
        print "<input type=submit name=submit value='Change Password'>\n";
        print "</td><td>$passwordGuidelines</td></tr></table>\n";
        print "</center>\n";
    } elsif ($command eq "becomeusernameform") {
        print "<center>\n";
        tie my %availusers, "Tie::IxHash";
        eval {
            %availusers = &get_lookup_values ($dbh, $schema, 'users', 'id', "firstname || ' ' || lastname", 'id > 0 and id < 1000 ORDER BY username');
        };
        if ($@) {
            $message = errorMessage($dbh,$username,$userid,$schema,"get available users.",$@);
            #$message =~ s/\n/\\n/g;
        }
        print "<b>Select Username: </b>&nbsp;" . &build_drop_box('newuserid', \%availusers, '$username') ."<br><br>\n";
        print "\n";
        print "<input type=submit name=submit value='Become User'>\n";
        print "</center>\n";
    } elsif ($command eq "browse") {
       eval {
          print "<center><table cellspacing=0 cellpadding=20 border=0><ul><tr><td valign=top><b>";
          print "<li><a href='#By Last Name'>By Last Name</a>";
          print "<li><a href='#Document Capture'>Document Capture</a>";
          print "<li><a href='#Supplemental Data Entry'>Supplemental Data Entry</a>";
          print "<li><a href='#Technical Editors'>Technical Editors</a>";
          print "</td><td valign=top><b>";
          print "<li><a href='#Response Writers'>Response Writers</a>";
          print "<li><a href='#Technical Reviewers'>Technical Reviewers</a>";
          print "<li><a href='#" . &FirstReviewName . " Team'>" . &FirstReviewName . " Team</a>";
          print "<li><a href='#" . &SecondReviewName . " Reviewers'>" . &SecondReviewName . " Reviewers</a>";
          print "</td><td valign=top><b>";
          print "<li><a href='#Bin Coordinators'>Bin Coordinators</a>";
          print "<li><a href='#System Administrators'>System Administrators</a>";
          print "<li><a href='#Software Developers'>Software Developers</a>";
          print "</b></td></tr></ul></table><br>\n";
          print &writeUserTable(endID => 9999, privilege => 1, title => 'By Last Name');
          print &writeUserTable(privilege => 10, title => 'System Administrators', titleBackground => '#cdecff');
          print &writeUserTable(privilege => 2, title => 'Document Capture', titleBackground => '#ffc0ff');
          print &writeUserTable(privilege => 3, title => 'Supplemental Data Entry', titleBackground => '#ffc0ff');
          print &writeUserTable(privilege => 8, title => 'Bin Coordinators', titleBackground => '#c0ffff');
          print &writeUserTable(privilege => 4, title => 'Response Writers', titleBackground => '#f0e0b0');
          print &writeUserTable(privilege => 5, title => 'Technical Reviewers', titleBackground => '#cdecff');
          print &writeUserTable(privilege => 9, title => 'Technical Editors', titleBackground => '#f0f080');
          print &writeUserTable(privilege => 6, title => &FirstReviewName . ' Team', titleBackground => '#c0ffc0');
          print &writeUserTable(privilege => 7, title => &SecondReviewName . ' Reviewers', titleBackground => '#ffc0c0');
          print &writeUserTable(startID => 1001, endID => 9999, title => 'Software Developers');
          print "</center>";
       };
       if ($@) {
          $message = errorMessage($dbh, $username, $userid, $schema, "browse users", $@);
          #$message =~ s/\n/\\n/g;
       }
    } elsif ($command eq "displayuserform") {
        print "<center>\n";
        print gen_table (\@uservalues);
        print "<br><br><a href=javascript:history.back()><b>Return to Previous Page</b></a>\n";
        print "</center>\n";
    }

print "<script language=javascript><!--\n";
if (defined($message) && $message gt " ") {
    print doAlertBox( text => $message, includeScriptTags => 'F');
    #print "   alert('$message');\n";
}
print "//--></script>\n";

}
print "<br><br>\n";
print "</td></tr></table>\n";
print "</form>\n";
print "</font>\n";
print "<form name=dummy$form>\n";
print "<input type=hidden name=username value=\"$username\">\n";
print "<input type=hidden name=userid value=\"$userid\">\n";
print "<input type=hidden name=schema value=\"$schema\">\n";
print "<input type=hidden name=server value=$Server>\n";
print "<input type=hidden name=id value=0>\n";
print "<input type=hidden name=command value=0>\n";
print "</form>\n";
print $crdcgi->end_html;
db_disconnect($dbh);
