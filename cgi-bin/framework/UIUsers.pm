# UI User functions
#
# $Source$
#
# $Revision$
#
# $Date$
#
# $Author$
#
# $Locker$
#
# $Log$
#
#
#
#

package UIUsers;
#
# get all required libraries and modules
use strict;
use SharedHeader qw(:Constants);
use CGI;
use DBUsers qw(:Functions);
use UI_Widgets qw(:Functions);
use DBShared qw(:Functions);
use UIShared qw(:Functions);
use Sessions qw(:Functions);
use Tie::IxHash;
use Tables;

use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS $VERSION $AUTOLOAD);
#use vars qw ();
use integer;

use Exporter;
$VERSION = 1.00;

@ISA = qw(Exporter);

@EXPORT = qw ();
@EXPORT_OK = qw(
      &writeUserTable         &doBrowse             &doDisplayUser
      &getInitialValues       &doHeader             &doUpdateUserSelect
      &doFooter               &getTitle             &doUserEntryForm
      &doUserEntry            &doEnableDisableUser  &doResetPassword
      &doChangePasswordForm   &doChangePassword     &doBecomeUsernameForm
      &doBecomeUsername       $SYSLockoutCount       $SYSLockoutTime
    );
%EXPORT_TAGS =( 
    Functions => [qw(
      &writeUserTable         &doBrowse             &doDisplayUser
      &getInitialValues       &doHeader             &doUpdateUserSelect
      &doFooter               &getTitle             &doUserEntryForm
      &doUserEntry            &doEnableDisableUser  &doResetPassword
      &doChangePasswordForm   &doChangePassword     &doBecomeUsernameForm
      &doBecomeUsername       $SYSLockoutCount      $SYSLockoutTime
    )]
);

my $mycgi = new CGI;


###################################################################################################################################
sub getTitle {
###################################################################################################################################
   my %args = (
      @_,
   );
   my $title = "";
   if (($args{command} eq "adduser") || ($args{command} eq "adduserform")) {
      $title = "Add User";
   } elsif (($args{command} eq "updateuser") || ($args{command} eq "updateuserform") || ($args{command} eq "updateuserselect")) {
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
      privilege => 0,
      startID => 0,
      endID => 0,
      titleBackground => '#cdecff',
      titleForeground => '#000099',
      align => 'center',
      @_,
   );
   my $output = "<a name='$args{title}'></a>\n";
   $output .= &startTable(columns => 3, align => $args{align}, title => $args{title});
   $output .= &startRow(bgcolor => "#f0f0f0") . &addCol(value => "Name", width => 140) . &addCol(value => "Username", width => 100) . &addCol(value => "Organization", width => 120) . &endRow;
   my @users = &getUserArray(dbh => $args{dbh}, schema => $args{schema}, startID => $args{startID}, endID => $args{endID}, privilege => $args{privilege});
   for (my $i=0; $i < $#users; $i++) {
      my ($id, $username, $lastname, $firstname, $organization) = ($users[$i]{id},$users[$i]{username},$users[$i]{lastname},$users[$i]{firstname},$users[$i]{organization});
      my $fullName = &get_fullname($args{dbh}, $args{schema}, $id);
      my $prompt = "Click here to display information for $fullName";
      $output .= &startRow . &addCol(value => $fullName, url => "javascript:displayUser($id)", prompt => $prompt);
      $output .= &addCol(value => $username) . &addCol(value => ((defined($organization)) ? $organization : "&nbsp;")) . &endRow;
   }
   $output .= &endTable;
   $output .= "<br><b><a href=#top title='Click here to return to the top of the page'>Back to Top</a></b><br><br>\n";
   return ($output);
}


###################################################################################################################################
sub getInitialValues {  # routine to get initial CGI values and return in a hash
###################################################################################################################################
    my %args = (
        dbh => "",
        @_,
    );
    
    my %valueHash = (
       &getStandardValues, (
       command => (defined ($mycgi -> param("command"))) ? $mycgi -> param("command") : "browse",
       id => (defined($mycgi->param("id"))) ? $mycgi->param("id") : "",
       u_username => (defined($mycgi->param("u_username"))) ? $mycgi->param("u_username") : "",
       u_id => (defined($mycgi->param("u_id"))) ? $mycgi->param("u_id") : "",
       oldpassword => (defined($mycgi->param("oldpassword"))) ? $mycgi->param("oldpassword") : "",
       newpassword => (defined($mycgi->param("newpassword"))) ? $mycgi->param("newpassword") : "",
       newpassword2 => (defined($mycgi->param("newpassword2"))) ? $mycgi->param("newpassword2") : "",
       lastname => (defined($mycgi->param("lastname"))) ? $mycgi->param("lastname") : "",
       firstname => (defined($mycgi->param("firstname"))) ? $mycgi->param("firstname") : "",
       organization => (defined($mycgi->param("organization"))) ? $mycgi->param("organization") : "",
       location => (defined($mycgi->param("location"))) ? $mycgi->param("location") : "",
       email => (defined($mycgi->param("email"))) ? $mycgi->param("email") : "",
       areacode => (defined($mycgi->param("areacode"))) ? $mycgi->param("areacode") : "",
       phonenumber => (defined($mycgi->param("phonenumber"))) ? $mycgi->param("phonenumber") : "",
       phoneextension => (defined($mycgi->param("phoneextension"))) ? $mycgi->param("phoneextension") : "",
       accesstype => (defined($mycgi->param("accesstype"))) ? $mycgi->param("accesstype") : "",
#       privlist => $mycgi->param("privlist"),
    ));
    my @privList = $mycgi->param("privlist");
    $valueHash{privlist} = \@privList;
    $valueHash{title} = &getTitle(command => $valueHash{command});
    
    return (%valueHash);
}


###################################################################################################################################
sub doHeader {  # routine to generate html page headers
###################################################################################################################################
    my %args = (
        dbh => '',
        schema => $ENV{SCHEMA},
        title => "$SYSType User Functions",
        displayTitle => 'T',
        @_,
    );
    my $output = "";
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $form = $args{form};
    my $path = $args{path};
    my $username = $settings{username};
    my $userid = $settings{userid};
    my $Server = $settings{server};
    
    my $extraJS = "";
    $extraJS .= <<END_OF_BLOCK;

    function submitFormDummy(script, command) {
        document.dummy$form.command.value = command;
        document.dummy$form.action = '$path' + script + '.pl';
        document.dummy$form.target = 'main';
        document.dummy$form.submit();
    }


    function submitFormHeader(script) {
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

END_OF_BLOCK
    $output .= &doStandardHeader(dbh => $args{dbh}, schema => $args{schema}, title => $args{title}, displayTitle => $args{displayTitle}, 
              settings => \%settings, form => $form, path => $path, extraJS => $extraJS);
#              settings => \%settings, form => $form, path => $path, extraJS => $extraJS, onSubmit => "return verify_$form(this)");
    
    $output .= "<table border=0 width=750 align=center><tr><td>\n";

    return($output);
}


###################################################################################################################################
sub doFooter {  # routine to generate html page footers
###################################################################################################################################
    my %args = (
        @_,
    );
    my $output = "";
    my $form = $args{form};
    my $path = $args{path};
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $username = $settings{username};
    my $userid = $settings{userid};
    my $Server = $settings{server};
    my $schema = $settings{schema};
    my $sessionID = $settings{sessionID};
    my $extraHTML = "";
    
    $output .= "<br><br>\n</td></tr></table>\n";
    $extraHTML .= &doStartForm(schema => $schema, form => "dummy" . $form, sessionID => $sessionID, username => $username, userid => $userid, server => $Server);
    $extraHTML .= "</form>\n";
    
    $output .= &doStandardFooter(form => $form, extraHTML => $extraHTML);

    return($output);
}


###################################################################################################################################
sub doBrowse {  # routine to generate a table of users for browse
###################################################################################################################################
    my %args = (
        @_,
    );
    my $output = "";

    $output .= "<center><table cellspacing=0 cellpadding=20 border=0><ul><tr><td valign=top><b>";
    $output .= "<li><a href='#By Last Name' title='Click here to view by last name'>By Last Name</a>";
    $output .= "</td><td valign=top><b>";
    $output .= "<li><a href='#System Administrators' title='Click here to view system administrators'>System Administrators</a>";
    $output .= "</td><td valign=top><b>";
    $output .= "<li><a href='#Software Developers' title='Click here to view software developers'>Software Developers</a>";
    $output .= "</b></td></tr></ul></table><br>\n";
    $output .= &writeUserTable(dbh => $args{dbh}, schema => $args{schema}, endID => 9999, title => 'By Last Name');
    $output .= &writeUserTable(dbh => $args{dbh}, schema => $args{schema}, privilege => 10, title => 'System Administrators', titleBackground => '#cdecff');
    $output .= &writeUserTable(dbh => $args{dbh}, schema => $args{schema}, privilege => -1, title => 'Software Developers');
    $output .= "</center>";
    

    return($output);
}


###################################################################################################################################
sub doDisplayUser {  # routine to display a user
###################################################################################################################################
    my %args = (
        @_,
    );
    my $output = "";
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my @uservalues;
    my ($id) = (0);
    $id = $settings{id};
    my %userInfo = &getUserInfo(dbh => $args{dbh}, schema => $args{schema}, ID => $id);
    
    $uservalues[0][0] = 'User Information';
    $uservalues[1][0] ='<b>User ID:</b>' . &nbspaces(2);
    $uservalues[1][1] ='<b>' . $userInfo{id} . '</b>';
    $uservalues[2][0] ='<b>Username:</b>' . &nbspaces(2);
    $uservalues[2][1] ='<b>' . $userInfo{username} . '</b>';
    $uservalues[3][0] ='<b>Name:</b>' . &nbspaces(2);
    $uservalues[3][1] ="<b>$userInfo{firstname} $userInfo{lastname}</b>";
    $uservalues[4][0] ='<b>Organization:</b>' . &nbspaces(2);
    $uservalues[4][1] ='<b>' . $userInfo{organization} . '</b>';
    $uservalues[5][0] ='<b>Phone Number:</b>' . &nbspaces(2);
    my $ext = (!(defined($userInfo{extension})) || $userInfo{extension} eq "") ? "" : " ext. $userInfo{extension}";
    $uservalues[5][1] ="<b>($userInfo{areacode}) " . substr($userInfo{phonenumber},0,3) . "-" . substr($userInfo{phonenumber},3,4) . "$ext</b>";
    $uservalues[6][0] ='<b>Email Address:</b>' . &nbspaces(2);
    $uservalues[6][1] ='<b>' . $userInfo{email} . '</b>';
    $uservalues[7][0] ='<b>SCCB User ID:</b>' . &nbspaces(2);
    $uservalues[7][1] ='<b>' . ((defined($userInfo{sccbid})) ? $userInfo{sccbid} : "") . '</b>';
    $uservalues[8][0] ='<b>Privileges:</b>';
    $userInfo{privileges} =~ s/\t/<br>/g;
    $uservalues[8][1] ="<b>" . $userInfo{privileges};
    $uservalues[9][0] = '<b>Status:</b>';
    $uservalues[9][1] = '<b>' . (($userInfo{isactive} eq 'T') ? 'Active' : 'Inactive') . '</b>';
    $uservalues[10][0] = '<b>Failed Logins:</b>';
    $uservalues[10][1] = "<b>" . $userInfo{failedattempts} . "</b>";
    $uservalues[11][0] = '<b>Lockout Time:</b>';
    $uservalues[11][1] = '<b>' . ((defined($userInfo{lockout})) ? $userInfo{lockout} : "&nbsp;") . '</b>';
    
    $output .= "<center>\n";
    $output .= gen_table (\@uservalues);
    $output .= "<br><br><a href=javascript:history.back() title='Click here to return to the previous page'><b>Return to Previous Page</b></a>\n";
    $output .= "</center>\n";
    

    return($output);
}


###################################################################################################################################
sub doUpdateUserSelect {  # routine to generate a select box of users for update
###################################################################################################################################
    my %args = (
        selectedUser => 0,
        onlyActive => 'F',
        command => 'updateuserform',
        commandText => "Retrieve User Information",
        excludeDevelopers => 'F',
        target => "",
        @_,
    );
    my $output = "";
    my @users = getUserArray(dbh => $args{dbh}, schema => $args{schema}, onlyActive => $args{onlyActive}, excludeDevelopers => $args{excludeDevelopers});
    my $selectedID = 0;

    $output .= <<END_OF_BLOCK;
<table border=0 width=680 align=center>
<tr><td colspan=4 align=center>
<table border=0>
END_OF_BLOCK
    $output .= "<tr><td><b>Select User: </b>&nbsp;</td><td><select name=u_username size=1>\n";
    for (my $i=0; $i < $#users; $i++) {
        my ($id, $username, $lastname, $firstname, $organization) = ($users[$i]{id},$users[$i]{username},$users[$i]{lastname},$users[$i]{firstname},$users[$i]{organization});
        my $selected = "";
        if ($id == $args{selectedUser}) {
            $selected = "selected";
            $selectedID = $i;
        }
        $output .= "<option value='$username' $selected>$firstname $lastname</option>\n";
    }
    $output .= "</select></td>\n";
    my $target = (($args{target} gt "") ? "document.$args{form}.target.value='$args{target}';" : "");
    $output .= <<END_OF_BLOCK;
<td>&nbsp;<input type=submit name="updateuser" value="$args{commandText}" onClick="document.$args{form}.command.value='$args{command}';$target"></td></tr>
END_OF_BLOCK
    if ($args{selectedUser} != 0) {
        $output .= "<tr><td><b>Username:</b></td><td><b>$users[$selectedID]{username}</b></td></tr>";
        $output .= "<tr><td><b>ID:</b></td><td><b>$users[$selectedID]{id}</b><input type=hidden name=u_id value=$users[$selectedID]{id}></td></tr>";
        $output .= "<tr><td><b>Status:</b></td><td><b>" . (($users[$selectedID]{isactive} eq 'T') ? "Active" : "Inactive") . "</b></td></tr>";
    }
    $output .= <<END_OF_BLOCK;
</table>
</td></tr>
</table>
END_OF_BLOCK
    

    return($output);
}


###################################################################################################################################
sub doUserEntryForm {  # routine to generate a user data entry/update form
###################################################################################################################################
    my %args = (
        type => 'new',
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $output = "";
    my %userInfo = (
        id => 0,
        username => "",
        firstname => "",
        lastname => "",
        organization => "",
        areacode => "",
        phonenumber => "",
        extension => "",
        email => "",
        isactive => "T",
        location => "",
        privileges => "",
        privilegeids => ""
    );
    my $id = 0;
    if ($args{type} eq 'update') {
        $id = getUserID(dbh => $args{dbh}, schema => $args{schema}, userName => $settings{u_username});
        %userInfo = &getUserInfo(dbh => $args{dbh}, schema => $args{schema}, ID => $id);
        $output .= &doUpdateUserSelect(dbh => $args{dbh}, schema => $args{schema}, title => $args{title}, form => $args{form}, 
                                   userID => $args{userID}, settings => \%settings, selectedUser => $id);
    }

    $output .= "<table border=0 align=center>\n";
    $output .= "<tr><td colspan=4><hr></td></tr>\n" if ($args{type} eq 'update');
    $output .= "<tr><td colspan=4><br></td></tr>\n" if ($args{type} eq 'update');
    $output .= "<tr><td colspan=4 align=center><table border=0 width=650>\n";
    $output .= "<tr><td><b>Last Name: </b>&nbsp</td><td><input type=text name=lastname value=\"$userInfo{lastname}\" maxlength=25 size=20></td>\n";
    $output .= "<td><b>First Name: </b>&nbsp</td><td><input type=text name=firstname value=\"$userInfo{firstname}\" maxlength=25 size=20></td></tr>\n";
    $output .= "<tr><td><b>Organization: </b>&nbsp</td><td colspan=3><input type=text name=organization value=\"$userInfo{organization}\" maxlength=75 size=40></td></tr>\n";
    $output .= "<tr><td><b>Location: </b>&nbsp</td><td colspan=3><input type=text name=location value=\"$userInfo{location}\" maxlength=75 size=40></td></tr>\n";
    $output .= "<tr><td><b>E-mail: </b>&nbsp</td><td><input type=text name=email value=\"$userInfo{email}\" maxlength=50 size=25></td>\n";
    $output .= "<td><b>Phone Number: </b>&nbsp</td><td><input type=text size=3 maxlength=3 name=areacode value=\"$userInfo{areacode}\"> - <input type=text size=7 maxlength=8 name=phonenumber value=\"$userInfo{phonenumber}\"><b>ext. </b><input type=text size=4 maxlength=5 name=phoneextension value=\"$userInfo{extension}\"></td></tr>\n";
    $output .= "<tr><td><b>Access Type: </b>&nbsp</td><td colspan=3><select name=accesstype>\n";
    my %atypes = %{&getLookupValues (dbh => $args{dbh}, schema => $args{schema}, table => 'system_access_type', idColumn => 'id', nameColumn => 'name')};

    my $key;
    foreach $key (sort keys %atypes) {
        my $selected = (($args{type} eq 'new' && $key == 2) || ($userInfo{accesstype} == $key)) ? " selected" : "";
        $output .= "<option value=\"$key\"$selected>$atypes{$key}\n";
    }

    $output .= "</select></td></tr>\n";
    if (&doesUserHavePriv(dbh => $args{dbh}, schema => $args{schema}, userid => $args{userID}, privList => [-1])) {
        $output .= "<tr><td colspan=4><br></td></tr>\n";
    }
    $output .= "<tr><td colspan=4 align=center>\n";
    my %userprivs;
    if (&doesUserHavePriv(dbh => $args{dbh}, schema => $args{schema}, userid => $args{userID}, privList => [-1])) {
        %userprivs = %{&getLookupValues (dbh => $args{dbh}, schema => $args{schema}, table => 'system_privilege', idColumn => 'id', nameColumn => 'name', where => ' id > 0')};
    } else {
        %userprivs = %{&getLookupValues (dbh=>$args{dbh}, schema=>$args{schema}, table=>'system_privilege', idColumn=>'id', nameColumn=>'name', where=>' id > 0 AND id <> 11')};
    }
    my %currprivs;
    my @privs = split("\t",$userInfo{privilegeids} . '0');
    for (my $i=0; $i<$#privs; $i++) {
        if ($privs[$i] > 0) {
            $currprivs{$privs[$i]} = $userInfo{"priv$privs[$i]"};
        }
    }
    if (&doesUserHavePriv(dbh => $args{dbh}, schema => $args{schema}, userid => $args{userID}, privList => [-1])) {
            $output .= build_dual_select ('privlist', "$args{form}", \%userprivs, \%currprivs, "<b>Available Privileges</b>", "<b>Selected Privileges</b>", "1");
    } elsif (&doesUserHavePriv(dbh => $args{dbh}, schema => $args{schema}, userid => $args{userID}, privList => [11])) {
            $output .= build_dual_select ('privlist', "$args{form}", \%userprivs, \%currprivs, "<b>Available Privileges</b>", "<b>Selected Privileges</b>", "1", "11");
    } else {
            $output .= build_dual_select ('privlist', "$args{form}", \%userprivs, \%currprivs, "<b>Available Privileges</b>", "<b>Selected Privileges</b>", "1", "10", "11");
    }
    $output .= "</td></tr>\n";
    $output .= "</table></td></tr>\n";
    $output .= "<tr><td colspan=4 align=center><br><input type=button name=submitbutton value=\"Submit User Information\" onClick=\"verifySubmit(document.$args{form})\"> &nbsp;\n";
    if ($args{type} eq 'update') {
        if ($userInfo{isactive} eq 'T') {
            $output .= "<input type=submit name=disable value=\"Disable Account\" onClick=\"document.$args{form}.command.value='disableuser'\"> &nbsp;\n";
        } else {
            $output .= "<input type=submit name=enable value=\"Enable Account\" onClick=\"document.$args{form}.command.value='enableuser'\"> &nbsp;\n";
        }
        $output .= "<input type=submit name=reset value=\"Reset Password\" onClick=\"document.$args{form}.command.value='resetpassword'\"> </td></tr>\n";
    }
    $output .= "</table>\n";
    
    my $nextCommand = (($args{type} eq 'new') ? "adduser" : "updateuser");
    $output .= <<END_OF_BLOCK;

<script language=javascript><!--

function verifySubmit (f){
// javascript form verification routine
    var msg = "";
    if (isblank(f.lastname.value) || isblank(f.firstname.value) || isblank(f.organization.value) ||
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
    if (isblank(f.location.value)) {
        msg += "The location of the user must be specified \\n";
    }
    for (index=0; index < f.privlist.length-1;index++) {
        f.privlist.options[index].selected = true;
    }
    if (msg != "") {
      alert (msg);
    } else {
      submitFormCGIResults('$args{form}', '$nextCommand');
    }
}
//--></script>

END_OF_BLOCK

    return($output);
}


###################################################################################################################################
sub doUserEntry {  # routine to get user entry/update data
###################################################################################################################################
    my %args = (
        type => 'new',
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $output = "";
    my $message = "";
    
    if ($args{type} eq 'new') {
        $settings{password} = &doGenPassword(length => 8);
    }
    my ($status, $userName) = &doProcessUserEntry(dbh => $args{dbh}, schema => $args{schema}, userID => $args{userID}, 
          type => $args{type}, settings => \%settings);

    $message = "User '$userName' has been " . (($args{type} eq 'new') ? "added with password '$settings{password}'" : "updated");
    $output .= doAlertBox(text => "$message");
    if ($args{type} eq 'new') {
        &logActivity (dbh => $args{dbh}, schema => $args{schema}, userID => $args{userID}, logMessage => "user $userName inserted", type => 4);
    } else {
        &logActivity (dbh => $args{dbh}, schema => $args{schema}, userID => $args{userID}, logMessage => "user $userName updated", type => 5);
    }
    #$output .= "<input type=hidden name=u_id value=$args{u_id}>\n";
    $output .= "<input type=hidden name=u_username value='$userName'>\n";
    $output .= "<script language=javascript><!--\n";
    $output .= "   submitForm('$args{form}','updateuserform');\n";
    $output .= "//--></script>\n";

    return($output);
}


###################################################################################################################################
sub doChangePasswordForm {  # routine to display a password change form
###################################################################################################################################
    my %args = (
        userID => 0,
        type => "Enable",
        form => "",
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $output = "";
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
    
    $output .= "<center>\n";
    $output .= "<table border=0 align=center valign=top><tr><td align=center valign=top width=50%>\n";
    $output .= "<font size=+1><b>User Name:</b></font><br><b>$settings{username}</b><br><br>\n";
    $output .= "<b>Old Password:</b><br><input type=password name=oldpassword size=15 maxlength=15><br><br>\n";
    $output .= "<b>New Password:</b><br><input type=password name=newpassword size=15 maxlength=15><br><br>\n";
    $output .= "<b>Retype New Password:</b><br><input type=password name=newpassword2 size=15 maxlength=15><br><br>\n";
    $output .= "<input type=button name=submitchange value='Change Password' onClick=\"doVerifySubmit(document.$args{form});\"><br><br>\n";
    $output .= "</td><td>&nbsp;</td><td valign=top width=50%>\n";
    $output .= "$passwordGuidelines\n";
    $output .= "</td></tr></table>\n";
    $output .= "</center>\n";
    
    $output .= <<END_OF_BLOCK;
<script language=javascript><!--
function doVerifySubmit(f) {
    var msg = "";
    if (isblank(f.oldpassword.value) || isblank(f.newpassword.value) || isblank(f.newpassword2.value)) {
      msg += "All form fields must be entered.\\n";
    }
    if (f.newpassword.value != f.newpassword2.value) {
      msg += "New password entries do not match.\\n";
    }
    if (f.oldpassword.value == f.newpassword.value) {
      msg += "Old password and New password can not be the same.\\n";
    }
    if (msg != "") {
        alert (msg);
    } else {
        submitFormCGIResults('$args{form}','changepassword');
    }
}
//--></script>
END_OF_BLOCK

    return($output);
}


###################################################################################################################################
sub doChangePassword {  # routine to process a password change
###################################################################################################################################
    my %args = (
        userID => 0,
        type => "Enable",
        form => "",
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $output = "";
    my $message = "";
    my $status = 0;
    
    my $reusedPassword = &isReusedPassword(dbh => $args{dbh}, schema => $args{schema}, userID => $args{userID}, password=>$settings{newpassword});
    if (&doTestPassword(password => $settings{newpassword}, username => $settings{username}) eq 'T' && !$reusedPassword) {
        ($status) = &doProcessChangePassword(dbh => $args{dbh}, schema => $args{schema}, userID => $args{userID}, settings => \%settings);
    } else {
        $status=-2;
    }
    
    my $userName = getUserName(dbh=>$args{dbh}, schema=>$args{schema}, userID=>$args{userID});
    if ($status == 1) {
        &logActivity (dbh => $args{dbh}, schema => $args{schema}, userID => $args{userID}, logMessage => "user $userName password changed", type => 2);
        $message = "The password for user $userName has been Changed";
        $output .= doAlertBox(text => "$message");
        $output .= "<script language=javascript><!--\n";
        $output .= "   submitFormHeader('header', 'header');\n";
        $output .= "   submitForm('utilities','');\n";
        $output .= "//--></script>\n";
    } elsif ($status == -2) {
        $output .= doAlertBox(text => "Password Does not meet security requirements");
    } else {
        $message = "The old password is not correct";
        $output .= doAlertBox(text => "$message");
    }

    return($output);
}


###################################################################################################################################
sub doResetPassword {  # routine to reset a user's password to the system default
###################################################################################################################################
    my %args = (
        userID => 0,
        type => "Enable",
        form => "",
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $output = "";
    my $newPassword = &doGenPassword(length => 8);
    
    my ($status) = &doProcessResetPassword(dbh => $args{dbh}, schema => $args{schema}, userID => $args{userID}, password => $newPassword, settings => \%settings);
    
    my $userName = getUserName(dbh=>$args{dbh}, schema=>$args{schema}, userID=>$args{userID});
    &logActivity (dbh => $args{dbh}, schema => $args{schema}, userID => $settings{userid}, logMessage => "user $userName password reset", type => 3);
    $output .= doAlertBox(text => "The password for user $userName has been reset to $newPassword");
    $output .= "<input type=hidden name=u_id value=$args{userID}>\n";
    $output .= "<input type=hidden name=u_username value='" . getUserName(dbh=>$args{dbh},schema=>$args{schema},userID=>$args{userID}) . "'>\n";
    $output .= "<script language=javascript><!--\n";
    $output .= "   submitForm('$args{form}','updateuserform');\n";
    $output .= "//--></script>\n";

    return($output);
}


###################################################################################################################################
sub doEnableDisableUser {  # routine to enable/disable a user
###################################################################################################################################
    my %args = (
        userID => 0,
        type => "Enable",
        form => "",
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $output = "";
    
    my ($status) = &doProcessEnableDisableUser(dbh => $args{dbh}, schema => $args{schema}, type => $args{type}, userID => $args{userID}, settings => \%settings);
    
    my $userName = getUserName(dbh=>$args{dbh}, schema=>$args{schema}, userID=>$args{userID});
    &logActivity (dbh => $args{dbh}, schema => $args{schema}, userID => $settings{userid}, logMessage => "user $userName $args{type}d", type => 5);
    $output .= doAlertBox(text => "User $userName $args{type}d");
    $output .= "<input type=hidden name=u_id value=$args{userID}>\n";
    $output .= "<input type=hidden name=u_username value='" . getUserName(dbh=>$args{dbh},schema=>$args{schema},userID=>$args{userID}) . "'>\n";
    $output .= "<script language=javascript><!--\n";
    $output .= "   submitForm('$args{form}','updateuserform');\n";
    $output .= "//--></script>\n";

    return($output);
}


###################################################################################################################################
sub doBecomeUsernameForm {  # routine to display a form for becoming another user
###################################################################################################################################
    my %args = (
        userID => 0,
        type => "Enable",
        form => "",
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $output = "";
    
    $output .= &doUpdateUserSelect(dbh => $args{dbh}, schema => $args{schema}, title => $args{title}, form => $args{form}, excludeDevelopers => 'T',
                   userID => $args{userID}, onlyActive => 'T', command => 'becomeusername', commandText => "Become User", settings => \%settings);
    
    return($output);
}


###################################################################################################################################
sub doBecomeUsername {  # routine to become another user
###################################################################################################################################
    my %args = (
        userID => 0,
        type => "Enable",
        form => "",
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $output = "";
    
    my $userID = &getUserID(dbh => $args{dbh}, schema => $args{schema}, userName => $settings{u_username});
    my $sessionID = (($SYSUseSessions eq 'T') ? &sessionCreate(dbh => $args{dbh}, schema => $args{schema}, userID => $userID, application => $SYSType, timeout => $SYSTimeout) : 0);
    $output .= "<script language=javascript><!--\n";
    $output .= "    document.$args{form}.userid.value=$userID;\n";
    $output .= "    document.$args{form}.username.value='$settings{u_username}';\n";
    $output .= "    document.$args{form}.sessionid.value='$sessionID';\n";
    $output .= "    alert('Changing current username/userid to $settings{u_username}/$userID');\n";
    $output .= "    submitFormHeader('header');\n";
    $output .= "    submitForm('home','');\n";
    $output .= "    submitFormStatus('title_bar','$settings{u_username}','$userID');\n";
    $output .= "//--></script>\n";
    
    return($output);
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
sub doGenPassword {  # routine to generate a random password
###################################################################################################################################
    my %args = (
        length => 8,
        @_,
    );
    my $output = "";
    my @TestVals = ("0".."9","a".."z","A".."Z",'!','@','#','$','%','^','&','*','(',')','+');
    my $looptest = "notdone";
    srand (time|$$);
    while (&doTestPassword(password=>$output) ne 'T') {
        $output = "";
        for (my $pos = 0; ($pos < $args{length}); $pos++) {
          $output = $output . $TestVals [rand (77)];
        }
    }
    
    return($output);
}


###################################################################################################################################
###################################################################################################################################



1; #return true
