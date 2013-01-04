# UI User functions
#
# $Source: /data/dev/rcs/plaqads/perl/RCS/UIRoles.pm,v $
#
# $Revision: 1.1 $
#
# $Date: 2004/07/27 18:27:16 $
#
# $Author: atchleyb $
#
# $Locker:  $
#
# $Log: UIRoles.pm,v $
# Revision 1.1  2004/07/27 18:27:16  atchleyb
# Initial revision
#
# Revision 1.1  2003/11/12 20:34:30  atchleyb
# Initial revision
#
#
#
#
#

package UIRoles;
#
# get all required libraries and modules
use strict;
use SharedHeader qw(:Constants);
use CGI;
use DBRoles qw(:Functions);
use DBUsers qw(getUserArray);
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
      &doBrowse                     &doUpdateUserSelect
      &doUserEntryForm              &doUserEntry        
      &getInitialValues             &doFooter               
      &getTitle                     &doHeader
      &doUserRoleDelegationReview   &doUserRoleDelegationForm
      &doUserRoleDelegation
    );
%EXPORT_TAGS =( 
    Functions => [qw(
      &doBrowse                     &doUpdateUserSelect
      &doUserEntryForm              &doUserEntry        
      &getInitialValues             &doFooter               
      &getTitle                     &doHeader
      &doUserRoleDelegationReview   &doUserRoleDelegationForm
      &doUserRoleDelegation
    )]
);

my $mycgi = new CGI;


###################################################################################################################################
sub getTitle {
###################################################################################################################################
   my %args = (
      @_,
   );
   my $title = "$args{command}";
   if (($args{command} eq "updateuser") || ($args{command} eq "updateuserform") || ($args{command} eq "updateuserselect")) {
      $title = "Update Roles";
   } elsif (($args{command} eq "browse")) {
      $title = "Browse Roles";
   } elsif (($args{command} eq "userroledelegationreview") || ($args{command} eq "userroledelegationform") || ($args{command} eq "userroledelegation")) {
      $title = "Delegate Roles";
   }
   return ($title);
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
       ruserid => (defined($mycgi->param("ruserid"))) ? $mycgi->param("ruserid") : 0,
       role => (defined($mycgi->param("role"))) ? $mycgi->param("role") : 0,
       delegatedto => (defined($mycgi->param("delegatedto"))) ? $mycgi->param("delegatedto") : 0,
       delegationstart => (defined($mycgi->param("delegationstart"))) ? $mycgi->param("delegationstart") : "",
       delegationstop => (defined($mycgi->param("delegationstop"))) ? $mycgi->param("delegationstop") : "",
    ));
    my @roleList = $mycgi->param("rolelist");
    $valueHash{rolelist} = \@roleList;
    $valueHash{title} = &getTitle(command => $valueHash{command});
    
    return (%valueHash);
}


###################################################################################################################################
sub doHeader {  # routine to generate html page headers
###################################################################################################################################
    my %args = (
        dbh => '',
        schema => $ENV{SCHEMA},
        title => "$SYSType Role Functions",
        displayTitle => 'T',
        includeJSCalendar => 'F',
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

    function submitRoleDelegation(role) {
        document.$form.command.value = 'userroledelegationform';
        document.$form.role.value = role;
        document.$form.target = 'main';
        document.$form.action = '$path' + 'roles' + '.pl';
        document.$form.submit();
    }


END_OF_BLOCK
    $output .= &doStandardHeader(dbh => $args{dbh}, schema => $args{schema}, title => $args{title}, displayTitle => $args{displayTitle}, 
              includeJSCalendar => $args{includeJSCalendar},
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
    
    $output .= &doStandardFooter(form => $form, extraHTML => $extraHTML);

    return($output);
}


###################################################################################################################################
sub doBrowse {  # routine to generate a table of roles for browse
###################################################################################################################################
    my %args = (
        @_,
    );
    my $output = "";
    my @roleList = &getRoleListArray(dbh=>$args{dbh}, schema=>$args{schema});
    
    $output .="<center><table border=0><tr><td>\n";
    for (my $i=0; $i<$#roleList; $i++) {
      my $text = "";
      for (my $j=0; $j<$roleList[$i]{userCount}; $j++) {
          $text .= "<a href=\"javascript:displayUser($roleList[$i]{users}[$j]{userid})\">$roleList[$i]{users}[$j]{lastname}, $roleList[$i]{users}[$j]{firstname}</a><br>\n";
          if ($roleList[$i]{users}[$j]{delegatedto} != 0) {
              my $delegatedtoName = &getFullName(dbh=>$args{dbh}, schema=>$args{schema}, userID=>$roleList[$i]{users}[$j]{delegatedto});
              $text .= " - (Delegated to: $delegatedtoName From: $roleList[$i]{users}[$j]{delegationstart} To: $roleList[$i]{users}[$j]{delegationstop})<br>";
          } 
      }
      $output .= &buildSectionBlock(title=> "$roleList[$i]{name} ($roleList[$i]{userCount})", contents=>$text);
    }

    $output .= "</td></tr></table></center>";
    

    return($output);
}


###################################################################################################################################
sub doUpdateUserSelect {  # routine to generate a select box of users for update
###################################################################################################################################
    my %args = (
        selectedUser => 0,
        onlyActive => 'F',
        command => 'updateuserform',
        commandText => "Retrieve Role Information",
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
        $output .= "<input type=hidden name=u_id value=$users[$selectedID]{id}>\n";
    }
    $output .= <<END_OF_BLOCK;
</table>
</td></tr>
</table>
END_OF_BLOCK
    

    return($output);
}


###################################################################################################################################
sub doUserEntryForm {  # routine to generate a user role data update form
###################################################################################################################################
    my %args = (
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $output = "";
    my %userInfo = (
        id => 0,
        roles => "",
        roleids => ""
    );
    my $id = 0;
    $id = getUserID(dbh => $args{dbh}, schema => $args{schema}, userName => $settings{u_username});
    $output .= &doUpdateUserSelect(dbh => $args{dbh}, schema => $args{schema}, title => $args{title}, form => $args{form}, 
                                   userID => $args{userID}, settings => \%settings, selectedUser => $id);

    $output .= "<table border=0 align=center>\n";
    $output .= "<tr><td colspan=4><hr></td></tr>\n";
    $output .= "<tr><td colspan=4><br></td></tr>\n";
    $output .= "<tr><td colspan=4 align=center><table border=0 width=650>\n";

# roles

    tie my %roles, "Tie::IxHash";
    %roles = %{&getLookupValues (dbh => $args{dbh}, schema => $args{schema}, table=>'roles', idColumn=>'id', nameColumn=>'name', orderBy=>'name')};
    tie my %currroles, "Tie::IxHash";
    %currroles = %{&getUserRolesHash (dbh => $args{dbh}, schema => $args{schema}, userID=>$id)};
    $output .= "<tr><td colspan=4 align=center>\n";
    $output .= build_dual_select ('rolelist', "$args{form}", \%roles, \%currroles, "<b>Available Roles</b>", "<b>Selected Roles</b>", 0);
    $output .= "</td></tr>\n";


    $output .= "</table></td></tr>\n";

    $output .= "<tr><td colspan=4 align=center><br><input type=button name=submitbutton value=\"Submit Role Information\" onClick=\"verifySubmit(document.$args{form})\"> &nbsp;\n";
    $output .= "</table>\n";
    
    my $nextCommand = "updateuser";
    $output .= <<END_OF_BLOCK;

<script language=javascript><!--

function verifySubmit (f){
// javascript form verification routine
    var msg = "";
    for (index=0; index < f.rolelist.length-1;index++) {
        f.rolelist.options[index].selected = true;
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
sub doUserEntry {  # routine to update user/role data
###################################################################################################################################
    my %args = (
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $output = "";
    my $message = "";
    
    my ($status, $userName) = &doProcessUserRoleEntry(dbh => $args{dbh}, schema => $args{schema}, userID => $args{userID}, 
          settings => \%settings);

    $message = "Roles for user '$userName' have been updated";
    $output .= doAlertBox(text => "$message");
    &logActivity (dbh => $args{dbh}, schema => $args{schema}, userID => $args{userID}, logMessage => "user $userName updated", type => 5);
    #$output .= "<input type=hidden name=u_id value=$args{u_id}>\n";
    $output .= "<input type=hidden name=u_username value='$userName'>\n";
    $output .= "<script language=javascript><!--\n";
    $output .= "   submitForm('$args{form}','updateuserform');\n";
    $output .= "//--></script>\n";

    return($output);
}


###################################################################################################################################
sub doUserRoleDelegationReview {  # routine to display user roles available for delegation
###################################################################################################################################
    my %args = (
        userID=>0,
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $output = "";
    my $message = "";
    
    my @roles = &getUserRoleInfoArray(dbh=>$args{dbh}, schema=>$args{schema}, userID=>$args{rUserID});
    
    $output .= "<center><h2>Role Delegations for ". &getFullName(dbh=>$args{dbh}, schema=>$args{schema}, userID=>$args{rUserID}) . "</h2>\n";
    
    if ($#roles == 0) {
        $output .= "No roles have been assigned for user\n";
    } else {
        $output .= "<table cellpadding=4 cellspacing=0 border=1 align=center>\n";
        $output .= "<input type=hidden name=ruserid value=$args{rUserID}>\n";
        $output .= "<input type=hidden name=role value=0>\n";
        $output .= "<tr bgcolor=#a0e0c0><td align=center><b>Role</b></td><td align=center><b>Delegated to</b></td><td><b>Start</b></td>";
        $output .= "<td align=center><b>Stop</b></td><td>&nbsp;</td></tr>\n";
        for (my $i=0; $i<=$#roles; $i++) {
            $output .= "<tr><td>$roles[$i]{rolename}</td>";
            if ($roles[$i]{delegatedto} == 0) {
                $output .= "<td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td>\n";
            } else {
                $output .= "<td>" . &getFullName(dbh=>$args{dbh}, schema=>$args{schema}, userID=>$roles[$i]{delegatedto}) . "</td>";
                $output .= "<td>$roles[$i]{delegationstart}</td><td>$roles[$i]{delegationstop}</td>";
            }
            if ($roles[$i]{canbedelegated} eq 'T') {
                $output .= "<td align=center><a href=\"javascript:submitRoleDelegation($roles[$i]{roleid});\">Update</a></td></tr>\n";
            } else {
                $output .= "<td align=center>Can not be delegated</td></tr>\n";
            }
        }
        $output .= "</table>\n";
    }
    
    $output .= "</center>\n";
    
    


    return($output);
}


###################################################################################################################################
sub doUserRoleDelegationForm {  # routine to display form role delegation
###################################################################################################################################
    my %args = (
        userID=>0,
        rUserID=>0,
        role=>0,
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $output = "";
    my $message = "";
    my $form = $args{form};
    
    my @roles = &getUserRoleInfoArray(dbh=>$args{dbh}, schema=>$args{schema}, userID=>$args{rUserID}, role=>$args{role});
    my $username = &getFullName(dbh=>$args{dbh}, schema=>$args{schema}, userID=>$args{rUserID});
    
    $output .= "<input type=hidden name=ruserid value=$args{rUserID}>\n";
    $output .= "<input type=hidden name=role value=$args{role}>\n";
    
    $output .= "<table border=0 align=center>\n";
    $output .= "<tr><td>User:</td><td>$username</td></tr>\n";
    $output .= "<tr><td>Role:</td><td>$roles[0]{rolename}</td></tr>\n";
    $output .= "<tr><td>Delegated to:</td><td><select name=delegatedto size=1>\n";
    my @users = getUserArray(dbh => $args{dbh}, schema => $args{schema}, onlyActive => 'T', excludeDevelopers => 'F');
    $output .= "<option value=0>Not Delegated</option>\n";
    for (my $i=0; $i<$#users; $i++) {
        $output .= "<option value=$users[$i]{id}" . (($users[$i]{id}==$roles[0]{delegatedto}) ? " selected" : "") . ">$users[$i]{firstname} $users[$i]{lastname}</option>\n";
    }
    $output .= "</select></td></tr>\n";
    $output .= "<tr><td>Start Date</td><td><input type=text size=10 maxlength=10 name=delegationstart value='" . (($roles[0]{delegatedto}!=0) ? $roles[0]{delegationstart} : "") . "' onfocus=\"this.blur(); showCal('caldelegationstart')\"><span id=\"delegationstartid\" style=\"position:relative;\">&nbsp;</span></td></tr>\n";
    $output .= "<tr><td>Stop Date</td><td><input type=text size=10 maxlength=10 name=delegationstop value='" . (($roles[0]{delegatedto}!=0) ? $roles[0]{delegationstop} : "") . "' onfocus=\"this.blur(); showCal('caldelegationstop')\"><span id=\"delegationstopid\" style=\"position:relative;\">&nbsp;</span></td></tr>\n";
    #$output .= "<tr><td>Start Date</td><td><input type=text size=10 maxlength=10 name=delegationstart value='" . (($roles[0]{delegatedto}!=0) ? $roles[0]{delegationstart} : "") . "'></td></tr>\n";
    #$output .= "<tr><td>Stop Date</td><td><input type=text size=10 maxlength=10 name=delegationstop value='" . (($roles[0]{delegatedto}!=0) ? $roles[0]{delegationstop} : "") . "'></td></tr>\n";
    
    $output .= "<tr><td colspan=2 align=center><input type=button name=dorolesubmit value='Submit' onClick=\"verifySubmit(document.$args{form})\">\n";
    $output .= "<input type=button name=doclear value='Clear' onClick=\"$form.delegatedto[0].selected=true;$form.delegationstart.value='';$form.delegationstop.value='';\"</td></tr>\n";
    $output .= "<table>\n";

    $output .= <<END_OF_BLOCK;

<script language=javascript><!--

function verifySubmit (f){
// javascript form verification routine
    var msg = "";
    if (f.delegatedto[0].selected == true && (!isblank(f.delegationstart.value) || !isblank(f.delegationstop)))  {
        msg += "Dates can not be set when no delegation is made.\\n";
    }
    if (f.delegatedto[0].selected == false && (isblank(f.delegationstart.value) && isblank(f.delegationstop)))  {
        msg += "Both dates must set when a delegation is made.\\n";
    }
    if (msg != "") {
        alert (msg);
    } else {
        submitFormCGIResults('$args{form}', 'userroledelegation');
    }
}
//--></script>

END_OF_BLOCK


    return($output);
}


###################################################################################################################################
sub doUserRoleDelegation {  # routine to update role delegation
###################################################################################################################################
    my %args = (
        userID=>0,
        rUserID=>0,
        role=>0,
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $output = "";
    my $message = "";
    my $form = $args{form};
    
    my ($status, $userName) = &doProcessUserRoleDelegation(dbh => $args{dbh}, schema => $args{schema}, userID => $args{userID}, 
          rUserID => $args{rUserID}, role => $args{role}, settings => \%settings);

    $message = "Role delegation for user '$userName' has been updated";
    $output .= doAlertBox(text => "$message");
    &logActivity (dbh => $args{dbh}, schema => $args{schema}, userID => $args{userID}, logMessage => "user $userName had role delegation updated", type => 5);
    $output .= "<script language=javascript><!--\n";
    $output .= "   $form.id.value=$args{rUserID};\n";
    $output .= "   submitForm('$args{form}','userroledelegationreview');\n";
    $output .= "//--></script>\n";

    return($output);
}


###################################################################################################################################
###################################################################################################################################



1; #return true
