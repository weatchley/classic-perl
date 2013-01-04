# UI User functions
#
# $Source: /usr/local/www/gov.ymp.intradev/rcs/mms/perl/RCS/UIRoles.pm,v $
#
# $Revision: 1.5 $
#
# $Date: 2009/06/26 21:57:40 $
#
# $Author: atchleyb $
#
# $Locker:  $
#
# $Log: UIRoles.pm,v $
# Revision 1.5  2009/06/26 21:57:40  atchleyb
# ACR0906_001 - List of changes
#
# Revision 1.4  2006/03/27 19:15:18  atchleyb
# CR 0023 - Updated to add a new function/utility for transfering pending approvals to a new role holder.
#
# Revision 1.3  2005/08/18 19:48:51  atchleyb
# added role delegation report
#
# Revision 1.2  2005/06/10 23:08:59  atchleyb
# CR0011
# updated to use sitename instead of site code
# form validation on delegation scrren to force entry of both dates
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
use UIPurchaseDocuments qw(formatXLSRow);
use DBPurchaseDocuments qw(getMimeType);
use UI_Widgets qw(:Functions);
use DBShared qw(:Functions);
use UIShared qw(:Functions);
use Sessions qw(:Functions);
use Tie::IxHash;
use Tables;
use PDF;

use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS $VERSION $AUTOLOAD);
#use vars qw ();
use integer;

use Exporter;
$VERSION = 1.00;

@ISA = qw(Exporter);

@EXPORT = qw ();
@EXPORT_OK = qw(
      &doBrowse                     &doUpdateUserSiteSelect
      &doUserSiteEntryForm          &doUserSiteEntry        
      &getInitialValues             &doFooter               
      &getTitle                     &doHeader
      &doUserRoleDelegationReview   &doUserRoleDelegationForm
      &doUserRoleDelegation         &doPrintDelegations
      &doReassignApprovalsSelect    &doReassignApprovalsForm
      &doReassignApprovals
    );
%EXPORT_TAGS =( 
    Functions => [qw(
      &doBrowse                     &doUpdateUserSiteSelect
      &doUserSiteEntryForm          &doUserSiteEntry        
      &getInitialValues             &doFooter               
      &getTitle                     &doHeader
      &doUserRoleDelegationReview   &doUserRoleDelegationForm
      &doUserRoleDelegation         &doPrintDelegations
      &doReassignApprovalsSelect    &doReassignApprovalsForm
      &doReassignApprovals
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
   if (($args{command} eq "updateusersite") || ($args{command} eq "updateusersiteform") || ($args{command} eq "updateusersiteselect")) {
      $title = "Update Roles";
   } elsif (($args{command} eq "browse")) {
      $title = "Browse Roles";
   } elsif (($args{command} eq "userroledelegationreview") || ($args{command} eq "userroledelegationform") || ($args{command} eq "userroledelegation")) {
      $title = "Delegate Roles";
   } elsif (($args{command} eq "reassignapprovals") || ($args{command} eq "reassignapprovalsform") || ($args{command} eq "processreassignapprovals")) {
      $title = "Reassign Pending Approvals";
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
       u_site => (defined($mycgi->param("u_site"))) ? $mycgi->param("u_site") : "",
       u_siteid => (defined($mycgi->param("u_siteid"))) ? $mycgi->param("u_siteid") : "",
       rolesite => (defined($mycgi->param("rolesite"))) ? $mycgi->param("rolesite") : 0,
       ruserid => (defined($mycgi->param("ruserid"))) ? $mycgi->param("ruserid") : 0,
       site => (defined($mycgi->param("site"))) ? $mycgi->param("site") : 0,
       urdsite => (defined($mycgi->param("urdsite"))) ? $mycgi->param("urdsite") : 0,
       role => (defined($mycgi->param("role"))) ? $mycgi->param("role") : 0,
       delegatedto => (defined($mycgi->param("delegatedto"))) ? $mycgi->param("delegatedto") : 0,
       delegationstart => (defined($mycgi->param("delegationstart"))) ? $mycgi->param("delegationstart") : "",
       delegationstop => (defined($mycgi->param("delegationstop"))) ? $mycgi->param("delegationstop") : "",
       oldapprover => (defined($mycgi->param("oldapprover"))) ? $mycgi->param("oldapprover") : 0,
       newapprover => (defined($mycgi->param("newapprover"))) ? $mycgi->param("newapprover") : 0,
       rolename => (defined($mycgi->param("rolename"))) ? $mycgi->param("rolename") : "",
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

    function submitRoleDelegation(role,site) {
        document.$form.command.value = 'userroledelegationform';
        document.$form.site.value = site;
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
        site => 0,  # 0 = all sites
        @_,
    );
    my $output = "";
    my @roleList = &getRoleListArray(dbh=>$args{dbh}, schema=>$args{schema}, site=>$args{site});
    
    $output .="<center><table border=0><tr><td>\n";
    for (my $i=0; $i<$#roleList; $i++) {
      my $text = "";
      for (my $j=0; $j<$roleList[$i]{userCount}; $j++) {
          $text .= "<a href=\"javascript:displayUser($roleList[$i]{users}[$j]{userid})\">$roleList[$i]{users}[$j]{sitename} - $roleList[$i]{users}[$j]{lastname}, $roleList[$i]{users}[$j]{firstname}</a><br>\n";
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
sub doUpdateUserSiteSelect {  # routine to generate a select box of users/sites for update
###################################################################################################################################
    my %args = (
        selectedUser => 0,
        selectedSite => 0,
        onlyActive => 'T',
        command => 'updateusersiteform',
        commandText => "Retrieve Role Information",
        excludeDevelopers => 'F',
        target => "",
        @_,
    );
    my $output = "";
    my @users = getUserArray(dbh => $args{dbh}, schema => $args{schema}, onlyActive => $args{onlyActive}, excludeDevelopers => $args{excludeDevelopers});
    my $selectedID = 0;
    my $selectedSite = 0;
    my @sites = getSiteInfoArray(dbh => $args{dbh}, schema => $args{schema});

    $output .= <<END_OF_BLOCK;
<table border=0 width=680 align=center>
<tr><td colspan=4 align=center>
<table border=0>
END_OF_BLOCK
    $output .= "<tr><td><b>Select User/Site: </b>&nbsp;</td><td><select name=u_username size=1>\n";
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

    $output .= "<td><select name=u_site size=1>\n";
    for (my $i=1; $i <= $#sites; $i++) {
        my ($id, $name) = ($sites[$i]{id}, $sites[$i]{name});
        my $selected = "";
        if ($id == $args{selectedSite}) {
            $selected = "selected";
            $selectedSite = $id;
        }
        $output .= "<option value='$id' $selected>$name</option>\n";
    }
    $output .= "</select></td>\n";
    my $target = (($args{target} gt "") ? "document.$args{form}.target.value='$args{target}';" : "");
    $output .= <<END_OF_BLOCK;
<td>&nbsp;<input type=submit name="updateuser" value="$args{commandText}" onClick="document.$args{form}.command.value='$args{command}';$target"></td></tr>
END_OF_BLOCK
    if ($args{selectedUser} != 0) {
        $output .= "<tr><td><b>Username:</b></td><td><b>$users[$selectedID]{username}</b></td></tr>";
        $output .= "<tr><td><b>Site:</b></td><td><b>$sites[$selectedSite]{name}</b><input type=hidden name=u_id value=$users[$selectedID]{id}></td></tr>";
        $output .= "<input type=hidden name=u_siteid value=$selectedSite>\n";
    }
    $output .= <<END_OF_BLOCK;
</table>
</td></tr>
</table>
END_OF_BLOCK
    

    return($output);
}


###################################################################################################################################
sub doUserSiteEntryForm {  # routine to generate a user role data update form
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
    $output .= &doUpdateUserSiteSelect(dbh => $args{dbh}, schema => $args{schema}, title => $args{title}, form => $args{form}, 
                                   userID => $args{userID}, settings => \%settings, selectedUser => $id, selectedSite => $settings{u_site});

    $output .= "<table border=0 align=center>\n";
    $output .= "<tr><td colspan=4><hr></td></tr>\n";
    $output .= "<tr><td colspan=4><br></td></tr>\n";
    $output .= "<tr><td colspan=4 align=center><table border=0 width=650>\n";

# roles

    tie my %roles, "Tie::IxHash";
    %roles = %{&getLookupValues (dbh => $args{dbh}, schema => $args{schema}, table=>'roles', idColumn=>'id', nameColumn=>'name', orderBy=>'name')};
    tie my %currroles, "Tie::IxHash";
    %currroles = %{&getUserSiteRolesHash (dbh => $args{dbh}, schema => $args{schema}, userID=>$id, site=>$settings{u_site})};
    $output .= "<tr><td colspan=4 align=center>\n";
    $output .= build_dual_select ('rolelist', "$args{form}", \%roles, \%currroles, "<b>Available Roles</b>", "<b>Selected Roles</b>", 0);
    $output .= "</td></tr>\n";


    $output .= "</table></td></tr>\n";

    $output .= "<tr><td colspan=4 align=center><br><input type=button name=submitbutton value=\"Submit Role Information\" onClick=\"verifySubmit(document.$args{form})\"> &nbsp;\n";
    $output .= "</table>\n";
    
    my $nextCommand = "updateusersite";
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
sub doUserSiteEntry {  # routine to update user/site/role data
###################################################################################################################################
    my %args = (
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $output = "";
    my $message = "";
    
    my ($status, $userName) = &doProcessUserRoleEntry(dbh => $args{dbh}, schema => $args{schema}, userID => $args{userID}, 
          site => $settings{u_siteid}, settings => \%settings);

    $message = "Roles for user '$userName' have been updated";
    $output .= doAlertBox(text => "$message");
    &logActivity (dbh => $args{dbh}, schema => $args{schema}, userID => $args{userID}, logMessage => "user $userName updated", type => 5);
    #$output .= "<input type=hidden name=u_id value=$args{u_id}>\n";
    $output .= "<input type=hidden name=u_username value='$userName'>\n";
    $output .= "<input type=hidden name=u_site value=$settings{u_siteid}>\n";
    $output .= "<script language=javascript><!--\n";
    $output .= "   submitForm('$args{form}','updateusersiteform');\n";
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
        $output .= "No delegatable roles for this user\n";
    } else {
        $output .= "<table cellpadding=4 cellspacing=0 border=1 align=center>\n";
        $output .= "<input type=hidden name=ruserid value=$args{rUserID}>\n";
        $output .= "<input type=hidden name=site value=0>\n";
        $output .= "<input type=hidden name=role value=0>\n";
        $output .= "<tr bgcolor=#a0e0c0><td align=center><b>Role</b></td><td align=center><b>Delegated to</b></td><td><b>Start</b></td>";
        $output .= "<td align=center><b>Stop</b></td><td>&nbsp;</td></tr>\n";
        for (my $i=0; $i<=$#roles; $i++) {
            $output .= "<tr><td>$roles[$i]{sitename} - $roles[$i]{rolename}</td>";
            if ($roles[$i]{delegatedto} == 0) {
                $output .= "<td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td>\n";
            } else {
                $output .= "<td>" . &getFullName(dbh=>$args{dbh}, schema=>$args{schema}, userID=>$roles[$i]{delegatedto}) . "</td>";
                $output .= "<td>$roles[$i]{delegationstart}</td><td>$roles[$i]{delegationstop}</td>";
            }
            if ($roles[$i]{canbedelegated} eq 'T') {
                $output .= "<td align=center><a href=\"javascript:submitRoleDelegation($roles[$i]{roleid},$roles[$i]{site});\">Update</a></td></tr>\n";
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
        site=>0,
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $output = "";
    my $message = "";
    my $form = $args{form};
    
    my @roles = &getUserRoleInfoArray(dbh=>$args{dbh}, schema=>$args{schema}, userID=>$args{rUserID}, site=>$args{site}, role=>$args{role});
    my $username = &getFullName(dbh=>$args{dbh}, schema=>$args{schema}, userID=>$args{rUserID});
    
    $output .= "<input type=hidden name=ruserid value=$args{rUserID}>\n";
    $output .= "<input type=hidden name=site value=$args{site}>\n";
    $output .= "<input type=hidden name=role value=$args{role}>\n";
    
    $output .= "<table border=0 align=center>\n";
    $output .= "<tr><td>User:</td><td>$username</td></tr>\n";
    $output .= "<tr><td>Site/Role:</td><td>$roles[0]{sitename} - $roles[0]{rolename}</td></tr>\n";
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
    if (f.delegatedto[0].selected == true && (!isblank(f.delegationstart.value) || !isblank(f.delegationstop.value)))  {
        msg += "Dates can not be set when no delegation is made.\\n";
    }
    if (f.delegatedto[0].selected == false && (isblank(f.delegationstart.value) || isblank(f.delegationstop.value)))  {
        msg += "Both dates must be set when a delegation is made.\\n";
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
        site=>0,
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $output = "";
    my $message = "";
    my $form = $args{form};
    
    my ($status, $userName) = &doProcessUserRoleDelegation(dbh => $args{dbh}, schema => $args{schema}, userID => $args{userID}, 
          rUserID => $args{rUserID}, site => $args{site}, role => $args{role}, settings => \%settings);

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
sub doPrintDelegations {  # routine to print a role delegation report
###################################################################################################################################
    my %args = (
        site=>0,
        forDisplay => 'T',
        format => 'pdf',
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $xlsBuff = '';
    my $output = "";
    my @delg = getCurrentPendingDelegations(dbh => $args{dbh}, schema => $args{schema});
    
    my $pdf = new PDF;
#    $pdf->setup(orientation => 'landscape', useGrid => 'F', leftMargin => .5, rightMargin => .5, topMargin => .5, bottomMargin => .5,
#        cellPadding => 4);

#######

## Headers

    my $colCount = 1;
    my @colWidths = (762);
    my @colAlign = ("center");
    my $fontID = $pdf->setFont(font => "Helvetica-Bold", fontSize => 10.0);
    my @colData = ("Current & Pending Role Delegation Report\n\n");
    $pdf->addHeaderRow(fontSize => 12, fontID => $fontID,
               colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0);
    $xlsBuff .= formatXLSRow(cols=>$colCount, row=>\@colData);
#    my @siteInfo = &getSiteInfoArray(dbh => $args{dbh}, schema => $args{schema});
#    @colData = ("From: $args{startDate}  To: $args{endDate}\nSite: " . (($args{site} == 0) ? "All" : $siteInfo[$args{site}]{name}));
#    $pdf->addHeaderRow(fontSize => 10, fontID => $fontID,
#               colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0);
#    $xlsBuff .= formatXLSRow(cols=>$colCount, row=>\@colData);


    $colCount = 6;
    @colWidths = (100,100,75,75,65,65);
    @colAlign = ("center", "center", "center", "center", "center", "center");
    @colData = ("Site", "Role", "User", "Delegated To", "Delegation Start", "Delegation Stop");
    $fontID = $pdf->setFont(font => "Helvetica-Bold", fontSize => 10.0);
    $pdf->addHeaderRow(fontSize => 8, fontID => $fontID,
               colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0.01);
    $xlsBuff .= formatXLSRow(cols=>$colCount, row=>\@colData);

## Footers
#
    $colCount = 1;
    @colWidths = (762);
    @colAlign = ("center");
    my $reportDate = &getSysdate(dbh=>$args{dbh});
    @colData = ("\nReport generated on: $reportDate\nPage <page>");
    $fontID = $pdf->setFont(font => "Helvetica", fontSize => 10.0);
    $pdf->addFooterRow(fontSize => 8, fontID => $fontID,
               colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0);


    $pdf->newPage(orientation => 'portrait', useGrid => 'F');

# page contents

# line items
    $colCount = 6;
    @colWidths = (100,100,75,75,65,65);
    @colAlign = ("left", "left", "left", "left", "center", "center");
    $fontID = $pdf->setFont(font => "Helvetica", fontSize => 10.0);
    my $changeTotal = 0;
    for (my $i=0; $i<=$#delg; $i++) {
        @colData = ($delg[$i]{role}{site},$delg[$i]{role}{name},"$delg[$i]{user}{lastname}, $delg[$i]{user}{firstname}",
              "$delg[$i]{delegation}{user}{lastname}, $delg[$i]{delegation}{user}{firstname}",
              $delg[$i]{delegation}{start},$delg[$i]{delegation}{stop});
        $pdf->tableRow(fontSize => 8, fontID => $fontID,
                   colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0.01);
        $xlsBuff .= formatXLSRow(cols=>$colCount, row=>\@colData);
    }

## finish report
    my $repBuff = '';
    if ($args{format} eq 'pdf') {
        $repBuff = $pdf->finish;
    } elsif ($args{format} eq 'xls') {
        $repBuff = $xlsBuff;
    }
########    
    
    if ($args{forDisplay} eq 'T') {
        my $mimeType = &getMimeType(dbh => $args{dbh}, schema => $args{schema}, name=>".$args{format}");
        $output .= "Content-type: $mimeType\n\n";
        #$output .= "Content-disposition: inline; filename=$args{id}.$args{format}\n";
        $output .= "\n";
    }
    $output .= $repBuff;

    

    return($output);
}


###################################################################################################################################
sub doReassignApprovalsSelect {  # routine to select an approval for reassignment
###################################################################################################################################
    my %args = (
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $output = "";
    my $message = "";
    my $form = $args{form};
    
    my @pa = &getPendingApprovals(dbh => $args{dbh}, schema => $args{schema});
    
    $output .= "<table border=1 cellpadding=4 cellspacing=0 align=center>\n";
    $output .= "<tr bgcolor=#a0e0c0><td><b>PR / PO</b></td><td><b>Role</b></td><td colspan=2><b>User</b></td></tr>\n";
    for (my $i=0; $i<$#pa; $i++) {
        $output .= "<tr bgcolor=#ffffff><td>$pa[$i]{prnumber}" . 
              ((defined($pa[$i]{ponumber})) ? "/$pa[$i]{ponumber}" . ((defined($pa[$i]{amendment})) ? $pa[$i]{amendment} : "") : "") . "</td>";
        $output .= "<td>$pa[$i]{rolename}</td><td>$pa[$i]{lastname}, $pa[$i]{firstname}</td>";
        $output .= "<td><a href=\"javascript:reassignPA('$pa[$i]{prnumber}',$pa[$i]{role},$pa[$i]{userid});\">Reassign</a></td></tr>\n";
    }
    $output .= "</table>\n";
    $output .= "<input type=hidden name=ruserid value=0>\n";
    $output .= "<input type=hidden name=role value=0>\n";

    $output .= <<END_OF_BLOCK;

<script language=javascript><!--

function reassignPA (id, role, user) {
    var msg = '';
    $args{form}.id.value=id;
    $args{form}.role.value=role;
    $args{form}.ruserid.value=user;
    submitForm('$args{form}', 'reassignapprovalsform');
}

//--></script>

END_OF_BLOCK
    

    return($output);
}


###################################################################################################################################
sub doReassignApprovalsForm {  # routine to generate a form for reassigning an approval
###################################################################################################################################
    my %args = (
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $output = "";
    my $message = "";
    my $form = $args{form};
    
    my @pa = &getPendingApprovals(dbh => $args{dbh}, schema => $args{schema}, userID=>$settings{ruserid}, role=>$settings{role},
          pd=>$settings{id});
    
    $output .= "<table border=0 align=center cellpadding=5>\n";
    $output .= "<tr><td><b>PR / PO:</b></td><td>$pa[0]{prnumber}" . 
              ((defined($pa[0]{ponumber})) ? "/$pa[0]{ponumber}" . ((defined($pa[0]{amendment})) ? $pa[0]{amendment} : "") : "") . "</td></tr>\n";
    $output .= "<tr><td><b>Role:</b></td><td>$pa[0]{rolename}</td></tr>\n";
    $output .= "<tr><td><b>Current Approver:</b> &nbsp; </td><td>$pa[0]{lastname}, $pa[0]{firstname}</td></tr>\n";
    $output .= "<tr><td><b>New Approver:</b></td><td><select name=newapprover size=1><option value=0></option>\n";
    my @rusers = &getUserRoleListArray(dbh => $args{dbh}, schema => $args{schema}, site=>$pa[0]{site}, role=>$pa[0]{role});
    for (my $i=0; $i<$#rusers; $i++) {
        $output .= "<option value=$rusers[$i]{userid}>$rusers[$i]{lastname}, $rusers[$i]{firstname}</option>\n";
    }
    $output .= "</select></td></tr>\n";
    $output .= "<input type=hidden name=pd value='$settings{id}'>\n";
    $output .= "<input type=hidden name=role value=$settings{role}>\n";
    $output .= "<input type=hidden name=oldapprover value=$settings{ruserid}>\n";
    $output .= "<input type=hidden name=rolename value=$pa[0]{rolename}>\n";
    $output .= "<tr><td>&nbsp;</td><td><input type=button name=submitit value='Reassign Approval' onClick=\"verifySubmit(document.$args{form});\"></td></tr>\n";
    $output .= "</table>";
    $output .= <<END_OF_BLOCK;

<script language=javascript><!--

function verifySubmit (f){
// javascript form verification routine
    var msg = "";
    f.id.value = '$settings{id}';
    var indx = f.newapprover.selectedIndex;
    if (f.newapprover[indx].value == 0 || f.newapprover[indx].value == $settings{ruserid}) {
        msg += "A new approver must be selected.\\n";
    }
    if (msg != "") {
        alert (msg);
    } else {
        submitFormCGIResults('$form','processreassignapprovals');
//        alert ("Made it!");
    }
}

//--></script>

END_OF_BLOCK
    

    return($output);
}


###################################################################################################################################
sub doReassignApprovals {  # routine to process reassigning an approval
###################################################################################################################################
    my %args = (
        userID=>0,
        role=>0,
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $output = "";
    my $message = "";
    my $form = $args{form};
    
    my ($status, $userName) = &doProcessReassignApprovals(dbh => $args{dbh}, schema => $args{schema}, pd => $settings{id}, 
          oldUser => $settings{oldapprover}, newUser => $settings{newapprover}, site => $settings{site}, role => $args{role});

    my $oldName = &getFullName(dbh => $args{dbh}, schema => $args{schema}, userID=>$settings{oldapprover});
    my $newName = &getFullName(dbh => $args{dbh}, schema => $args{schema}, userID=>$settings{newapprover});
    $message = "$settings{rolename} approval on $settings{id} has been reassigned from $oldName to $newName.";
    $output .= doAlertBox(text => "$message");
    &logActivity (dbh => $args{dbh}, schema => $args{schema}, userID => $args{userID}, logMessage => $message, type => 0);
    $output .= "<script language=javascript><!--\n";
    $output .= "   submitForm('$args{form}','reassignapprovals');\n";
    $output .= "//--></script>\n";

    return($output);
}


###################################################################################################################################
###################################################################################################################################



1; #return true
