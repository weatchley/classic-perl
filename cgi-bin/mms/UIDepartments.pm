# UI Department functions
#
# $Source: /usr/local/www/gov.ymp.intradev/rcs/mms/perl/RCS/UIDepartments.pm,v $
#
# $Revision: 1.6 $
#
# $Date: 2009/06/26 21:57:40 $
#
# $Author: atchleyb $
#
# $Locker:  $
#
# $Log: UIDepartments.pm,v $
# Revision 1.6  2009/06/26 21:57:40  atchleyb
# ACR0906_001 - List of changes
#
# Revision 1.5  2006/01/26 22:29:23  atchleyb
# CR 0022 - added member display to department browse
#
# Revision 1.4  2005/08/18 19:11:10  atchleyb
# CR00015 - changed to select screen after insert or update
#
# Revision 1.3  2005/06/10 22:40:28  atchleyb
# CR001
# updated to use site name instead of sitecode
#
# Revision 1.2  2004/01/12 20:15:24  atchleyb
# fixed typo in name
#
# Revision 1.1  2004/01/09 18:58:16  atchleyb
# Initial revision
#
#
#
#
#
#

package UIDepartments;
#
# get all required libraries and modules
use strict;
use SharedHeader qw(:Constants);
use CGI;
use DBDepartments qw(:Functions);
use UI_Widgets qw(:Functions);
use DBShared qw(:Functions);
use UIShared qw(:Functions);
use DBPurchaseDocuments qw(getChargeNumberArray);
use DBUsers qw(getUserArray);
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
      &getInitialValues       &doHeader             &doUpdateDepartmentSelect
      &doFooter               &getTitle             &doDepartmentEntryForm
      &doDepartmentEntry      &doDepartmentDelete
    );
%EXPORT_TAGS =( 
    Functions => [qw(
      &getInitialValues       &doHeader             &doUpdateDepartmentSelect
      &doFooter               &getTitle             &doDepartmentEntryForm
      &doDepartmentEntry      &doDepartmentDelete
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
   if (($args{command} eq "adddept") || ($args{command} eq "adddeptform")) {
      $title = "Add Department";
   } elsif (($args{command} eq "updatedept") || ($args{command} eq "updatedeptform") || ($args{command} eq "updatedeptselect") ||
           ($args{command} eq "deletedept")) {
      $title = "Update Department";
   } elsif (($args{command} eq "browse") || (($args{command} eq "displaydept")) || ($args{command} eq "displaydeptform")) {
      $title = "Browse Department";
   } else {
      $title = "$args{command}";
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
       deptid => (defined($mycgi->param("deptid"))) ? $mycgi->param("deptid") : 0,
       site => (defined($mycgi->param("site"))) ? $mycgi->param("site") : 0,
       name => (defined($mycgi->param("name"))) ? $mycgi->param("name") : "",
       chargenumber => (defined($mycgi->param("chargenumber"))) ? $mycgi->param("chargenumber") : "",
       manager => (defined($mycgi->param("manager"))) ? $mycgi->param("manager") : "",
       groupcode => (defined($mycgi->param("groupcode"))) ? $mycgi->param("groupcode") : "",
       active => (defined($mycgi->param("active"))) ? $mycgi->param("active") : "T",
       activeonly => (defined($mycgi->param("activeonly"))) ? $mycgi->param("activeonly") : "F",
       initialrun => (defined($mycgi->param("initialrun"))) ? $mycgi->param("initialrun") : "T",
    ));
    
    $valueHash{activeonly} = (($valueHash{initialrun} eq 'T') ? "T" : $valueHash{activeonly});

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


END_OF_BLOCK
    $output .= &doStandardHeader(dbh => $args{dbh}, schema => $args{schema}, title => $args{title}, displayTitle => $args{displayTitle}, 
              settings => \%settings, form => $form, path => $path, extraJS => $extraJS,includeJSUtilities => 'T', includeJSWidgets => 'F',);
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
sub doUpdateDepartmentSelect {  # routine to generate a select box of Departments for update
###################################################################################################################################
    my %args = (
        browseOnly => 'F',
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $output = "";
    my @depts = getDeptArray(dbh => $args{dbh}, schema => $args{schema}, activeOnly=>$settings{activeonly});
    my $selectedID = 0;
    my $activeOnly = (($settings{activeonly} eq 'T') ? "checked" : "");

    $output .= <<END_OF_BLOCK;
<table border=0 width=680 align=center>
<tr><td colspan=4 align=center><b>Active Only:</b> <input type=checkbox name=activeonly value='T' $activeOnly> &nbsp; 
<input type=button value=Refresh onClick="submitForm('$args{form}', '$settings{command}')"></td></tr>
<input type=hidden name=initialrun value='F'>
<tr><td colspan=4 align=center>
<table border=0>
END_OF_BLOCK
    $output .= "<tr><td><table border=1 cellpadding=2 cellspacing=0 align=center>\n";
    $output .= "<tr bgcolor=#a0e0c0><td><b>Name</b></td><td><b>Site</b></td></tr>\n";
    for (my $i=0; $i < $#depts; $i++) {
        $output .= "<tr bgcolor=#ffffff><td>" . (($depts[$i]{active} eq 'T') ? "" : "<i>") . "<a href=javascript:" . (($args{browseOnly} eq 'F') ? "update" : "browse") . "Department($depts[$i]{id})>";
        $output .= "$depts[$i]{name}</a>" . (($depts[$i]{active} eq 'T') ? "" : " - inactive</i>") . "</td><td>$depts[$i]{sitename}</td></tr>\n";
    }
    $output .= <<END_OF_BLOCK;

<script language=javascript><!--

function updateDepartment (id) {
    $args{form}.id.value=id;
    submitForm('$args{form}', 'updatedeptform');
}

function browseDepartment (id) {
    $args{form}.id.value=id;
    submitForm('$args{form}', 'displaydept');
}
//--></script>

</table>
</td></tr>
</table>
END_OF_BLOCK
    

    return($output);
}


###################################################################################################################################
sub doDepartmentEntryForm {  # routine to generate a Department data entry/update form
###################################################################################################################################
    my %args = (
        type => 'new',
        browseOnly => 'F',
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $output = "";
    my %dept;
    my $id = $settings{id};
    if ($args{type} eq 'update' || $args{browseOnly} eq 'T') {
        %dept = &getDeptInfo(dbh=>$args{dbh}, schema=>$args{schema}, id=>$id);
    } else {
        $dept{id} = 0;
        $dept{name} = "";
        $dept{site} = 0;
        $dept{chargenumber} = "";
        $dept{manger} = 0;
        $dept{groupcode} = "";
        $dept{active} = "T";
    }

    $output .= "<table border=0 align=center>\n";
# Name
    $output .= "<tr><td colspan=2 align=center><table border=0>\n";
    $output .= "<input type=hidden name=deptid value=$id>\n";
    $output .= "<tr><td><b>Name: </b>&nbsp</td><td>";
    if ($args{browseOnly} ne 'T') {
        $output .= "<input type=text name=name value=\"$dept{name}\" maxlength=50 size=40>";
    } else {
        $output .= "$dept{name}";
    }
    $output .= "</td><tr>\n";
# Site
    $output .= "<tr><td><b>Site: </b>&nbsp</td><td>\n";
    if ($args{browseOnly} ne 'T') {
        if ($args{type} eq 'new') {
            my @sites = &getSiteInfoArray(dbh=>$args{dbh}, schema=>$args{schema});
            $output .= "<select size=1 name=site><option value=0>Please select a site</option>\n";
            for (my $i=1; $i<=$#sites; $i++) {
                $output .= "<option value=$sites[$i]{id}" . (($dept{site} == $sites[$i]{id}) ? " selected" : "") . ">$sites[$i]{name}</option>\n";
            }
            $output .= "</select>\n";
        } else {
            $output .= "$dept{sitename}<input type=hidden name=site value=$dept{site}>\n";
        }
    } else {
        $output .= "$dept{sitename}";
    }
    $output .= "</td></tr>\n";
# Charge Number
    $output .= "<tr><td><b>Charge Number: </b>&nbsp;</td><td>";
    if ($args{browseOnly} ne 'T') {
        $output .= "<select size=1 name=chargenumber><option value=0>Please select a charge number</option>\n";
        my @CNs = &getChargeNumberArray(dbh=>$args{dbh}, schema=>$args{schema}, onlyFY=>'T');
        my $found = "F";
        for (my $i=0; $i<$#CNs; $i++) {
            if ($args{type} eq 'new' || $dept{site} == $CNs[$i]{site}) {
                $output .= "<option value=$CNs[$i]{chargenumber}" . (($CNs[$i]{chargenumber} eq $dept{chargenumber}) ? " selected" : "") . ">";
                $output .= "$CNs[$i]{chargenumber} - $CNs[$i]{sitename}</option>\n";
                if ($CNs[$i]{chargenumber} eq $dept{chargenumber}) {
                    $found = 'T';
                }
            }
        }
        if ($found ne "T") {
            $output .= "<option value=$dept{chargenumber} selected>$dept{chargenumber}</option>\n";
        }
        $output .= "</select>\n";
    } else {
        $output .= "$dept{chargenumber}";
    }
    $output .= "</td></tr>\n";
#print STDERR "\nid: $dept{id}, name:$dept{name}, site:$dept{site}, cn:$dept{chargenumber}, manager:$dept{manager}, gc:$dept{groupcode}\n\n";
# Manager
    $output .= "<tr><td><b>Manager: </b>&nbsp;</td><td>";
    if ($args{browseOnly} ne 'T') {
        $output .= "<select size=1 name=manager><option value=0>Please select a manager</option>\n";
        my $found = "F";
        my @users = &getUserArray(dbh=>$args{dbh}, schema=>$args{schema}, role=>16);
        for (my $i=0; $i<$#users; $i++) {
            $output .= "<option value=$users[$i]{id}" . (($users[$i]{id} == $dept{manager}) ? " selected" : "") . ">$users[$i]{lastname}, $users[$i]{firstname}</option>\n";
            if ($users[$i]{id} == $dept{manager}) {
                $found = 'T';
            }
        }
        if ($found ne "T" && $dept{manager}>0) {
            $output .= "<option value=$dept{manager} selected>" . getFullName(dbh=>$args{dbh}, schema=>$args{schema}, userID=>$dept{manager}) . " - disabled/not manager</option>\n";
        }
        $output .= "</select>";
    } else {
        $output .= "$dept{managername}";
    }
    $output .= "</td></tr>\n";
# Group Code
    $output .= "<tr><td><b>Group Code: </b>&nbsp;</td><td>";
    if ($args{browseOnly} ne 'T') {
        $output .= "<input type=text name=groupcode size=3 maxlength=3 value='$dept{groupcode}'>";
    } else {
        $output .= "$dept{groupcode}";
    }
    $output .= "</td></tr>\n";
# is active
    $output .= "<input type=hidden name=active value='$dept{active}'>\n";
# Members
    if ($args{browseOnly} eq 'T') {
        $output .= "<tr><td valign=top><b>Members: </b>&nbsp;</tc><td>";
        my @users = &getUserArray(dbh=>$args{dbh}, schema=>$args{schema}, dept=> $dept{id});
        for (my $i=0; $i<$#users; $i++) {
            $output .= "$users[$i]{lastname}, $users[$i]{firstname}<br>\n";
        }
        
        $output .= "</td></tr>\n";
    }
# controls
    if ($args{browseOnly} ne 'T') {
        $output .= "<tr><td colspan=2 align=center><input type=button name=deptsubmit value='Submit' onClick=verifySubmit(document.$args{form})></td></tr>\n";
        
        if ($dept{isCurrent} eq 'F' && $dept{active} eq 'T') {
            $output .= "<tr><td colspan=2 align=center><input type=button name=deptdisable value='Disable' onClick=disableDepartment(document.$args{form})></td></tr>\n";
        }
        if ($dept{active} eq 'F') {
            $output .= "<tr><td colspan=2 align=center><input type=button name=deptenable value='Activate' onClick=enableDepartment(document.$args{form})></td></tr>\n";
        }
        if ($dept{isUsed} eq 'F') {
            $output .= "<tr><td colspan=2 align=center><input type=button name=deptdelete value='Delete' onClick=deleteDepartment(document.$args{form})></td></tr>\n";
        }
    }
    
    $output .= "</table>\n";
    
    my $nextCommand = (($args{type} eq 'new') ? "adddept" : "updatedept");
    $output .= <<END_OF_BLOCK;

<script language=javascript><!--

function disableDepartment (f){
// javascript form verification routine
    f.active.value='F';
    verifySubmit(f);
}

function enableDepartment (f){
// javascript form verification routine
    f.active.value='T';
    verifySubmit(f);
}

function deleteDepartment (f){
// javascript form verification routine
    f.id.value = $dept{id};
    submitFormCGIResults('$args{form}', 'deletedept');
}

function verifySubmit (f){
// javascript form verification routine
    var msg = "";
    if (isblank(f.name.value) || isblank(f.groupcode.value) || f.chargenumber[0].selected || f.manager[0].selected) {
      msg += "All form fields must be entered.\\n";
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
sub doDepartmentEntry {  # routine to get department entry/update data
###################################################################################################################################
    my %args = (
        type => 'new',
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $output = "";
    my $message = "";
    
    my ($status, $id) = &doProcessDepartmentEntry(dbh => $args{dbh}, schema => $args{schema}, userID => $args{userID}, 
          type => $args{type}, settings => \%settings);

    if ($args{type} eq 'new') {
        &logActivity (dbh => $args{dbh}, schema => $args{schema}, userID => $args{userID}, logMessage => "department $id inserted", type => 16);
    } else {
        &logActivity (dbh => $args{dbh}, schema => $args{schema}, userID => $args{userID}, logMessage => "department $id updated", type => 17);
    }
    $output .= "<script language=javascript><!--\n";
    #$output .= "   document.$args{form}.id.value=$id;\n";
    $output .= "   submitForm('$args{form}','updatedeptselect');\n";
    $output .= "//--></script>\n";

    return($output);
}


###################################################################################################################################
sub doDepartmentDelete {  # routine to delete a department
###################################################################################################################################
    my %args = (
        id => 0,
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $output = "";
    my $message = "";
    
    my ($status, $id) = &doProcessDepartmentDelete(dbh => $args{dbh}, schema => $args{schema}, userID => $args{userID}, 
          id => $args{id}, settings => \%settings);

    &logActivity (dbh => $args{dbh}, schema => $args{schema}, userID => $args{userID}, logMessage => "department $id deleted", type => 17);
    $output .= "<script language=javascript><!--\n";
    $output .= "   submitForm('$args{form}','updatedeptselect');\n";
    $output .= "//--></script>\n";

    return($output);
}


###################################################################################################################################
###################################################################################################################################



1; #return true
