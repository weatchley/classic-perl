#
# $Source: /data/dev/rcs/pcl/perl/RCS/UIProject.pm,v $
#
# $Revision: 1.5 $
#
# $Date: 2003/02/12 18:50:29 $
#
# $Author: atchleyb $
#
# $Locker:  $
#
# $Log: UIProject.pm,v $
# Revision 1.5  2003/02/12 18:50:29  atchleyb
# added session management
#
# Revision 1.4  2003/02/03 21:57:04  atchleyb
# removed refs to SCM
#
# Revision 1.3  2002/11/27 01:34:42  starkeyj
# modified create and update screens to add sccb field - also modified hidden field name
# in update - project changed to project1 to accomodate name change on UIUtilities page
#
# Revision 1.2  2002/11/01 00:25:08  johnsonc
# Removed intermediate screen for the update project function.
# ,
#
# Revision 1.1  2002/10/31 18:52:29  johnsonc
# Initial revision
#
#
#
package UIProject;
use strict;
use SharedHeader qw(:Constants);
use UIShared qw(:Functions);
use DBShared qw(:Functions);
use DBProject qw(:Functions);
use CGI qw(param);
use Tie::IxHash;
use Carp;

use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS $VERSION $AUTOLOAD);

use Exporter;
$VERSION = 1.00;

@ISA = qw(Exporter);

@EXPORT = qw ();
@EXPORT_OK = qw(
   &createProjectBody &getProjectList &updateProjectBody &getInitialValues &doBody &doHeader
);
%EXPORT_TAGS =( Functions => [qw(
   &createProjectBody &getProjectList &updateProjectBody &getInitialValues &doBody &doHeader
)]);

my $mycgi = new CGI;

#################
sub doHeader {
#################
	my %args = (
		schema => $ENV{SCHEMA},
		title => 'Project Management',
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

	my $extraJS = "";
	$extraJS .= <<JavaScript;
	function validateProject(f, script, command, option) {
		var errors = "";
		var msg;
		if ((option == "create") && (f.projectname.value == null || f.projectname.value == "")) {
			errors += "\\tThe Project Name text field must contain a value.\\n";
		}
		if ((option == "create") && (f.projectacronym.value == null || f.projectacronym.value == "")) {
			errors += "\\tThe Project Acronym text field must contain a value.\\n";
		}
		if (f.projectdesc.value == null || f.projectdesc.value == "") {
			errors += "\\tThe Descripton of Project text area must contain a value.\\n";
		}
		msg  = "______________________________________________________\\n\\n";
		msg += "The form was not submitted because of the following error(s).\\n";
		msg += "Please correct these errors(s) and re-submit.\\n";
		msg += "______________________________________________________\\n";
		if (errors != "") {
			msg += "\\n" + errors;
			alert(msg);
			return false;
		}
		else {
			submitFormCGIResults(script,command);
		}
	}
JavaScript

	$output .= &doStandardHeader(schema => $args{schema}, title => $args{title}, displayTitle => $args{displayTitle}, 
			     						  settings => \%settings, form => $form, path => $path, extraJS => $extraJS, 
			     						  includeJSUtilities => 'F', includeJSWidgets => 'F');
	return($output);
}

###################################################################################################################################
sub getInitialValues {  # routine to get initial CGI values and return in a hash
###################################################################################################################################
    my %args = (
        dbh => "",
        @_,
    );
    my %valueHash = (
       schema => (defined($mycgi->param("schema"))) ? $mycgi->param("schema") : $ENV{'SCHEMA'},
       command => (defined ($mycgi -> param("command"))) ? $mycgi -> param("command") : "browse",
       username => (defined($mycgi->param("username"))) ? $mycgi->param("username") : "",
       userid => (defined($mycgi->param("userid"))) ? $mycgi->param("userid") : "",
       sccbid => (defined($mycgi->param("sccbid"))) ? $mycgi->param("sccbid") : 0,
       projectname => (defined($mycgi->param("projectname"))) ? $mycgi->param("projectname") : "",
       acronym => (defined($mycgi->param("projectacronym"))) ? $mycgi->param("projectacronym") : "",
       desc => (defined($mycgi->param("projectdesc"))) ? $mycgi->param("projectdesc") : "",
       projectManagerID => (defined($mycgi->param("projectManagerID"))) ? $mycgi->param("projectManagerID") : 0,
       requirementsManagerID => (defined($mycgi->param("requirementsManagerID"))) ? $mycgi->param("requirementsManagerID") : 0,
       configurationManagerID => (defined($mycgi->param("configurationManagerID"))) ? $mycgi->param("configurationManagerID") : 0,
       sessionID => (defined($mycgi->param("sessionid"))) ? $mycgi->param("sessionid") : "0",
       projectID => (defined($mycgi->param("project1"))) ? $mycgi->param("project1") : 0

    );    
    return (%valueHash);
}

#################
sub createProjectBody {
#################
   my %args = (
      schema => $ENV{SCHEMA},
      @_,
   );
   tie my %sccblist, "Tie::IxHash";
   %sccblist = %{&getSCCBNames(schema => $args{schema}, dbh => $args{dbh}, orderBy => ' upper(name) ')};
	my $outstring = "";
	$outstring .= <<END_OF_BLOCK4;
	<center>
	<table cellpadding=4 cellspacing=0 border=0 width=50%>
	<tr><td height=17></td></tr>
	<tr><td align=left><b><font size=-1>Project Name:</font></b></td><td><input type=text name=projectname size=40></td></tr>
	<tr><td align=left><b><font size=-1>Project Acronym:</font></b></td><td><input type=text name=projectacronym size=10 maxlength=8></td></tr>
END_OF_BLOCK4
	$outstring .= &createUserList(dbh => $args{dbh}, label => 'Project Manager', name => 'projectManagerID', managerID => 0);
	$outstring .= "<tr><td><font size=-1><b>SCCB:</b.</font></td><td><select name=sccbid size=1>\n";
	$outstring .= "<option value=0>No SCCB Assigned\n";
	foreach my $sccb (keys (%sccblist)) {
		$outstring .= "<option value=$sccb>$sccblist{$sccb}\n";
	}
	$outstring .= <<END_OF_BLOCK2;
	<tr><td height=7 colspan=2></td></tr>
	<tr><td align=left colspan=2><b><font size=-1>Description of Project:</font></b><br>
	<textarea name=projectdesc rows=4 cols=60></textarea></td><tr>
	<tr><td height=25></td></tr>
	<tr><td colspan=2 align=center><input type=button value="Create Project" onClick=validateProject(document.$args{form},'project','db_create_project','create');></td></tr>
	</table><br><br>
	</center>
END_OF_BLOCK2
	return ($outstring);
}

#################
sub updateProjectBody {
#################
   my %args = (
      schema => $ENV{SCHEMA},
      @_,
   );
	my %project = &getProjectInfo(dbh => $args{dbh}, schema => $args{schema}, projectId => $args{projectID});
   print STDERR "\n--$args{projectID}\n";
   my $sccbid = &getProjectSCCB(dbh => $args{dbh}, schema => $args{schema}, id => $args{projectID});
   my $sccbname = &getSCCBName(dbh => $args{dbh}, schema => $args{schema}, id => $sccbid);
   tie my %sccblist, "Tie::IxHash";
   %sccblist = %{&getSCCBNames(schema => $args{schema}, dbh => $args{dbh}, orderBy => ' upper(name) ')};
   my $outstring = <<END_OF_BLOCK3;
   <center>
   <input type=hidden name=project1 value=$args{projectID}>
	<table cellpadding=4 cellspacing=0 border=0 width=50%>
	<tr><td height=17></td></tr>
	<tr><td align=left><font size=-1><b>Project Name:</b></font></td><td><b>$project{'name'}</b></td></tr>
	<tr><td align=left><font size=-1><b>Project Acronym:</b></font></td><td><b>$project{'acronym'}</b></td></tr>
END_OF_BLOCK3
	$outstring .= &createUserList(dbh => $args{dbh}, label => 'Project Manager', name => 'projectManagerID', managerID => $project{'projectManagerID'});
	$outstring .= &createUserList(dbh => $args{dbh}, label => 'Requirements Manager', name => 'requirementsManagerID', managerID => $project{'requirementsManagerID'});
	$outstring .= &createUserList(dbh => $args{dbh}, label => 'Software Configuration Manager', name => 'configurationManagerID', managerID => $project{'configurationManagerID'});
 	$outstring .= "<tr><td><font size=-1><b>SCCB:</b.</font></td><td><select name=sccbid size=1>\n";
 	$outstring .= "<option value=0>No SCCB Assigned\n";
	foreach my $sccb (keys (%sccblist)) {
		if ($sccbid == $sccb) {$outstring .= "<option selected value=$sccb>$sccblist{$sccb}\n";}
		else {$outstring .= "<option value=$sccb>$sccblist{$sccb}\n";}
	}
 	$outstring .= <<END_OF_BLOCK5;
 	</select></td></tr>
	<tr><td height=5></td></tr>
	<tr><td align=left colspan=2><font size=-1><b>Description of Project:</b></font><br>
	<textarea name=projectdesc rows=4 cols=60>$project{'description'}</textarea></td></tr>
	<tr><td height=15></td></tr>
	<tr><td colspan=2 align=center><input type=button value="Update Project" onClick=validateProject(document.$args{form},'project','db_update_project','update');></td></tr>
	</table>
	<input type=hidden name=projectname value="$project{'name'}">
	</center>
END_OF_BLOCK5
	return ($outstring);
}

#################
sub createUserList {
#################
   my %args = (
      schema => $ENV{SCHEMA},
      @_,
   );
	tie my %userlist, "Tie::IxHash";
	%userlist = &getUsersByPrivilege(schema => $args{schema}, dbh => $args{dbh}, privilegeID => -1);
	my $outstring = "";
	$outstring .= "<tr><td><font size=-1><b>$args{label}:</b></font></td><td><select name=$args{name} size=1>\n";
	foreach my $userprivid (keys (%userlist)) {
	   if ($userprivid eq $args{managerID}) {$outstring .= "<option value=$userprivid selected>$userlist{$userprivid}{'name'}\n";}
		else {$outstring .= "<option value=$userprivid>$userlist{$userprivid}{'name'}\n";}
	}
	$outstring .= "</select></td></tr>\n";
}

#################
sub getProjectList {
#################
   my %args = (
      schema => $ENV{SCHEMA},
      @_,
   );
	tie my %projectlist, "Tie::IxHash";
	%projectlist = &getProjects(schema => $args{schema}, dbh => $args{dbh});
	my $outstring = "";
	$outstring .= "<center>\n";
	$outstring .= "<table cellpadding=4 cellspacing=0 border=0>\n";
	$outstring .= "<tr><td height=17></td></tr>\n";
	$outstring .= "<tr><td><font size=-1><b>Project:&nbsp;&nbsp;</b></font></td><td><select name=projectID size=1>\n";
	foreach my $project (keys (%projectlist)) {
	   if ($projectlist{$project}{configurationManagerID} == $args{userID} || $projectlist{$project}{projectManagerID} == $args{userID} || $args{userID} == 1004) {$outstring .= "<option value=$project>$projectlist{$project}{name}\n";}
	}
	$outstring .= <<END_OF_TEXT;
	</select></td></tr>
	</table><br><br>
	<input type=button value="Update Project" onClick=submitForm('project','getProject');><br><br>
END_OF_TEXT
}


#################
sub doBody {
#################
	my %args = (
		schema => $ENV{SCHEMA},
		@_,
	);
	my $outstring = "";
	foreach my $row (@{$args{text}}) {
		$outstring .= "$row\n";
	}
   return ($outstring);
}

1; #return true

