#
# $Source: /data/dev/rcs/pcl/perl/RCS/UISCCB.pm,v $
#
# $Revision: 1.3 $ 
#
# $Date: 2003/02/12 18:51:44 $
#
# $Author: atchleyb $
#
# $Locker:  $
#
# $Log: UISCCB.pm,v $
# Revision 1.3  2003/02/12 18:51:44  atchleyb
# added session management
#
# Revision 1.2  2003/02/07 21:22:59  starkeyj
# modified 'use DB_scm' to 'use DBShared', 'use UI_scm' to 'use UIShared'
#  and 'use SCM_Header' to 'use SharedHeader'
#
# Revision 1.1  2002/12/12 00:11:15  starkeyj
# Initial revision
#
#
package UISCCB;
use strict;
use SharedHeader qw(:Constants);
use UI_Widgets qw(:Functions);
use DBShared qw(:Functions);
use UIShared qw(:Functions);
use Tables qw(:Functions);
use DBSCCB qw(:Functions);
use CGI qw(param);
use Tie::IxHash;
use Carp;

use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS $VERSION $AUTOLOAD);
use integer;

use Exporter;
$VERSION = 1.00;

@ISA = qw(Exporter);

@EXPORT = qw ();
@EXPORT_OK = qw(
      &doBrowseSCCBTable 	   	&doHeader                  &doFooter                     
      &getInitialValues				&doBrowseSCCB					&createSCCBBody	
      &continueSCCBBody				&updateSCCBBody				&doCreateSCCB
      &doUpdateSCCB
    );
%EXPORT_TAGS =( 
    Functions => [qw(
      &doBrowseSCCBTable 	   	&doHeader                  &doFooter                     
      &getInitialValues				&doBrowseSCCB					&createSCCBBody
      &continueSCCBBody				&updateSCCBBody				&doCreateSCCB
      &doUpdateSCCB
    )]
);

my $mycgi = new CGI;

###################################################################################################################################
###################################################################################################################################


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
       project => (defined($mycgi->param("project"))) ? $mycgi->param("project") : 0,
       select1 => (defined($mycgi->param("select1"))) ? $mycgi->param("select1") : 0,
       sccbselect => (defined($mycgi->param("sccbselect"))) ? $mycgi->param("sccbselect") : 0,
       sccb => (defined($mycgi->param("sccb"))) ? $mycgi->param("sccb") : 0,
       project => (defined($mycgi->param("project"))) ? $mycgi->param("project") : 0,
       description => (defined($mycgi->param("description"))) ? $mycgi->param("description") : 0,
       roles => (defined($mycgi->param("roles"))) ? $mycgi->param("roles") : 0,
       updateroles => (defined($mycgi->param("updateroles"))) ? $mycgi->param("updateroles") : 0,
       removeroles => (defined($mycgi->param("removeroles"))) ? $mycgi->param("removeroles") : 0,
       primaries => (defined($mycgi->param("primaries"))) ? $mycgi->param("primaries") : 0,
       alternates => (defined($mycgi->param("alternates"))) ? $mycgi->param("alternates") : 0,
       updateprimaries => (defined($mycgi->param("updateprimaries"))) ? $mycgi->param("updateprimaries") : 0,
       updatealternates => (defined($mycgi->param("updatealternates"))) ? $mycgi->param("updatealternates") : 0,
       sccbname => (defined($mycgi->param("sccbname"))) ? $mycgi->param("sccbname") : 0,
       sccbprojectlist => (defined($mycgi->param("sccbprojectlist"))) ? $mycgi->param("sccbprojectlist") : 0,
       sessionID => (defined($mycgi->param("sessionid"))) ? $mycgi->param("sessionid") : "0",
       title => (defined($mycgi->param("title"))) ? $mycgi->param("title") : "SCCB"
    );
    
    return (%valueHash);
}

###################################################################################################################################
sub doHeader {  # routine to generate html page headers
###################################################################################################################################
    my %args = (
        schema => $ENV{SCHEMA},
        title => 'Document Management',
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
    $extraJS .= <<END_OF_BLOCK;
		 function displayCurrentMembers(sccbdate,project) {
			  //$form.command.value = 'browseversions';
			  $form.command.value = 'browsefilemoves';
			  $form.project.value = project;
			  $form.baselinedate.value = sccbdate;
			  $form.action = '$path$form.pl';
			  $form.target = 'main';
			  $form.submit();
       }
       function submitProcessForm(script,command,updates) {
           updates = updates.split(",");
       	  var errors = "";
			  var msg;
			  var error = 0;
       	  var rolelist = '';
       	  var updaterolelist = '';
       	  var removerolelist = '';
       	  var primarylist = '';
       	  var alternatelist = '';
       	  var updateprimarylist = '';
       	  var updatealternatelist = '';
       	  var sccbprojectlist = '';
       	  var i = document.$form.length;

			  
			  if (command == 'db_update') {
			  		
			  }
			  else if (command == 'db_create') {
				  if (isblank(document.$form.sccbname.value) ) {
						errors += "- SCCB Name must have a value\\n";   	  		
				  }
				  if (document.$form.roleprimary1.options.length == 1) {
						errors += "- SCCB Chair must be assigned a Primary Member\\n";   	  		
				  }
				  if (document.$form.rolealternate1.options.length == 1) {
						errors += "- SCCB Chair must be assigned an Alternate Member\\n";   	  		
				  } 
				  if (isblank(document.$form.RSISlead.value) ) {
						errors += "- The RSIS Lead Role must have a name\\n";   	  		
				  }
				  if (document.$form.roleprimary2.options.length == 1) {
						errors += "- RSIS Lead must be assigned a Primary Member\\n";   	  		
				  }
				  if (document.$form.rolealternate2.options.length == 1) {
						errors += "- RSIS Lead must be assigned an Alternate Member\\n";   	  		
				  } 
				  rolelist += "Chair--";
				  e = document.$form.roleprimary1;
				  for (var k=0; k<e.length;k++) {
						if (k != 0) {primarylist += ",";}
						primarylist += e[k].value ;
				  }
				  primarylist += "--";
				  e = document.$form.rolealternate1;
				  for (var m=0; m<e.length;m++) {
						if (m != 0) {alternatelist += ",";}
						alternatelist += e[m].value ;
				  }
				  alternatelist += "--";
				  rolelist += document.$form.RSISlead.value + "--";
				  e = document.$form.roleprimary2;
				  for (var k=0; k<e.length;k++) {
						if (k != 0) {primarylist += ",";}
						primarylist += e[k].value ;
				  }
				  primarylist += "--";
				  e = document.$form.rolealternate2;
				  for (var m=0; m<e.length;m++) {
						if (m != 0) {alternatelist += ",";}
						alternatelist += e[m].value ;
				  }
				  alternatelist += "--";
			  }
			  if (document.$form.sccbprojects.length == 1) {errors += "- You must assign the SCCB to a Project\\n";}
			  else {
			  		for (var f=0;f<document.$form.sccbprojects.length;f++) {
			  			if (f != 0) {sccbprojectlist += ",";}
			         sccbprojectlist += document.$form.sccbprojects.options[f].value;
			      }
 			  }
       	  for (var j=0;j<i;j++) {
       	  		e = document.$form.elements[j];
       	  		if (e.name.substr(0,4) == "role" && e.name.length <= 6 && e.name != "roles") {
       	  			if (document.$form.elements[j].checked) {removerolelist += e.name.substr(4) + ",";}
       	  			else if (document.$form.elements[j+1].length == 1) {error = 1;}
       	  			else {
       	  				updaterolelist += e.name.substr(4) + "--";
       	  				e = document.$form.elements[j+1];
							for (var k=0; k<e.length;k++) {
								if (k != 0) {updateprimarylist += ",";}
								updateprimarylist += e[k].value ;
							}
							updateprimarylist += "--";
							e = document.$form.elements[j+7];
							for (var m=0; m<e.length;m++) {
								if (m != 0) {updatealternatelist += ",";}
								updatealternatelist += e[m].value ;
							}
							updatealternatelist += "--";
       	  			}
       	  			j+=7;
       	  		}
       	  		if (e.name.substr(0,7) == "newrole" && e.name.substr(7,3) != "num") {
       	  			if (!(isblank(e.value) && document.$form.elements[j+1].options.length == 1 
       	  			    && document.$form.elements[j+7].options.length == 1)) {
       	  			      if (isblank(e.value)) {
       	  			      	errors += "- You have added members to a new role and the role name has no value\\n";
       	  			      }
       	  					else if (document.$form.elements[j+1].length == 1) {
       	  						errors += "- Role " + e.value + " must have a Primary Member assigned\\n";
       	  					}
       	  					else if (document.$form.elements[j+7].length == 1) {
       	  						errors += "- Role " + e.value + " must have an Alternate Member assigned\\n";
       	  					}
       	  					else {
       	  						rolelist += e.value + "--" ;
       	  						e = document.$form.elements[j+1];
									for (var k=0; k<e.length;k++) {
										if (k != 0) {primarylist += ", ";}
										primarylist += e[k].value ;
									}
									primarylist += "--";
									e = document.$form.elements[j+7];
									for (var m=0; m<e.length;m++) {
										if (m != 0) {alternatelist += ", ";}
										alternatelist += e[m].value ;
									}
									alternatelist += "--";
								}
								j+=7;
       	  			}
       	  		}
		     }
		     if (error) {errors += "- All Current Roles must have a Primary and Alternate Member assigned\\n";}
			  msg  = "______________________________________________________\\n\\n";
			  msg += "The form was not submitted because of the following error(s).\\n";
			  msg += "Please correct these errors(s) and re-submit.\\n";
			  msg += "______________________________________________________\\n";
			  if (errors != "") {
					msg += "\\n" + errors;
					alert(msg);
			  }
		     else {
       	  		document.$form.roles.value = rolelist;
       	  		document.$form.updateroles.value = updaterolelist;
       	  		document.$form.removeroles.value = removerolelist;
       	  		document.$form.primaries.value = primarylist;
       	  		document.$form.alternates.value = alternatelist;
       	  		document.$form.updateprimaries.value = updateprimarylist;
       	  		document.$form.updatealternates.value = updatealternatelist;
       	  		document.$form.sccbprojectlist.value = sccbprojectlist;
			  		document.$form.command.value = command;
			  		document.$form.action = '$path' + script + '.pl';
			  		document.$form.target = 'cgiresults';
			  		document.$form.submit();
			 }
       }
       function displayUser(id) {
          document.$form.id.value = id;
          submitForm ('users', 'displayuser');
       }
  	    function addRole(id,userlist) {
			var j = 0;
			userlist = userlist.replace(/_/g,"'");
			var userlist2 = userlist.split(",");	    
			var i = parseInt(document.$form.newrolenum.value);
			var usertext = "<table border=0 width=700 align=center>\\n";
			usertext += "<tr><td colspan=5><font size=-1>SCCB Role:&nbsp;</font><input type=text name=newrole" + i + " size=100></td></tr>\\n";
			usertext += "<tr><td style=font-size:14;>Primary:<br><select name=newprimary" + i + " multiple size=5 style=font-size:10;>";
			usertext +="<option value=0>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</select></td>\\n";
	 	  	usertext += "<td style=font-size:14; align=center><input type=button name=selectprimary" + i + " onclick=process_dual_select_option(document.sccb.newuser" + i + ",document.sccb.newprimary" + i + ",'move'); value='<-- Select Primary' style=font-size:10;><br>";
	 	  	usertext += "<input type=button name=deselectprimary" + i + " onclick=process_dual_select_option(document.sccb.newprimary" + i + ",document.sccb.newuser" + i + ",'move','1'); value='Deselect Primary -->' style=font-size:10;></td>\\n";
	 	  	usertext += "<td style=font-size:14;>Available Users:<br><select name=newuser" + i + " size=5 style=font-size:10;>\\n";
	 	  	for (j;j<userlist2.length;j++) {
	 	  		usertext += "<option value=" + userlist2[j++] + " style=font-size:14;>" + userlist2[j] + "\\n";
	 	  	}
	 	  	usertext += "</select></td>\\n";
	 	  	usertext += "<td style=font-size:14; align=center><input type=button name=selectalternate" + i + " onclick=process_dual_select_option(document.sccb.newuser" + i + ",document.sccb.newalternate" + i + ",'move'); value='Select Alternate -->' style=font-size:10;><br>";
	 	  	usertext += "<input type=button name=deselectalternate" + i + " onclick=process_dual_select_option(document.sccb.newalternate" + i + ",document.sccb.newuser" + i + ",'move','1'); value='<-- Deselect Alternate' style=font-size:10;></td>\\n";
	 	  	usertext += "<td style=font-size:14;>Alternates:<br><select name=newalternate" + i + " multiple size=5 style=font-size:10;>";
	 	  	usertext += "<option value=0>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</select></td></tr>";
			usertext += "<tr bgcolor=#bbbbcc><td colspan=5 height=4></td></tr></table>\\n"
			document.$form.newrolenum.value = i + 1;
	    	document.$form.rolecount.value = i;
			document.all.newroles.innerHTML = document.all.newroles.innerHTML + usertext;
	 }

END_OF_BLOCK
    $output .= &doStandardHeader(schema => $args{schema}, title => $args{title}, displayTitle => $args{displayTitle}, 
              settings => \%settings, form => $form, path => $path, extraJS => $extraJS, useFileUpload => 'T',
              includeJSUtilities => 'T', includeJSWidgets => 'T');
              
    #$output .= "<input type=hidden name=sccb value=''>\n";
    $output .= "<input type=hidden name=newrolenum value=1>\n";
    $output .= "<input type=hidden name=roles value=''>\n";
    $output .= "<input type=hidden name=updateroles value=''>\n";
	 $output .= "<input type=hidden name=removeroles value=''>\n";
	 $output .= "<input type=hidden name=primaries value=''>\n";
	 $output .= "<input type=hidden name=alternates value=''>\n";
	 $output .= "<input type=hidden name=updateprimaries value=''>\n";
	 $output .= "<input type=hidden name=updatealternates value=''>\n";
	 $output .= "<input type=hidden name=sccbprojectlist value=''>\n";
	 $output .= "<input type=hidden name=rolecount value=0>\n";
    
    return($output);
}


###################################################################################################################################
sub doFooter {  # routine to generate html page footers
###################################################################################################################################
    my %args = (
        @_,
    );
    my $output = "";
    
    $output .= "</form>\n</body>\n</html>\n";
    
    return($output);
}


###################################################################################################################################
###################################################################################################################################


###################################################################################################################################
sub doBrowseSCCBTable {  # routine to display a table of documents
###################################################################################################################################
    my %args = (
        itemType => 0, # all
        title => 'Software Baseline Versions',
        status => 0, # all
        userID => 0, # all
        update => 'F',
        @_,
    );
    my $output = '';
    my $numColumns = 3;
    my $count = 0;
    my @sccbList = &getSCCBList(dbh => $args{dbh}, schema => $args{schema});
	 $output .= &startTable(columns => $numColumns, title => "Software Configuration Control Boards (xxx)", width => 740);
	 $output .= &addSpacerRow (columns => $numColumns);
	 $output .= &startRow (bgColor => "#f0f0f0");
	 $output .= &addCol (value => "Name", align => 'center');
	 $output .= &addCol (value => "Date/Time Created", align => 'center');
	 $output .= &addCol (value => "Associated Projects", align => 'center');
	 $output .= &endRow();

    for (my $i = 0; $i < $#sccbList; $i++) {
        my ($sccbid,$name) = 
          ($sccbList[$i]{sccbid},$sccbList[$i]{name});
			$output .= &startRow;
			$output .= &addCol (value=>"$name");
			$output .= &addCol (value=>'Date');
			$output .= &addCol (value=>'Projects');
    		$output .= &endRow();
    		$count++;
    }
    $output =~ s/xxx/$count/;
    $output =~ s/&quot;/'/g;  #should not need this, I am doing something wrong *****************************************************************
    return($output);
}

#################
sub createSCCBBody {
#################
   my %args = (
      schema => $ENV{SCHEMA},
      @_,
   );
   my $userlist = "";
   my @users = &getSCCBUserRoleList(dbh=>$args{dbh},schema=>$args{schema},sccb=>0,excludeRole=>1);
   for (my $m=0; $m<$#users;$m++) {
   	$userlist .= "$users[$m]{userid},$users[$m]{username},";
   }
   $userlist =~ s/'/_/;
   chop($userlist);
	my $outstring = "";
	my @roles = split /,/, $args{roles};
	my $rolecount = $#roles;
	my $numColumns = 5;
	$outstring .= &startTable(columns => $numColumns, width => 700, border=>0,titleBackground => "#f0f0f0");
	$outstring .= &addSpacerRow (columns => $numColumns);
	$outstring .= &startRow (bgColor => "#f0f0f0");
	$outstring .= &addCol (value => "<font color=black size=-1><b>SCCB Name:</b></font>", colspan=>1);
	$outstring .= &addCol (value => "<b><input type=text name=sccbname size=80></b>", colspan=>4);
	$outstring .= &endRow;
	$outstring .= &startRow (bgColor => "#f0f0f0");
	$outstring .= &build_dos_select (dbh=>$args{dbh},sccb=>$args{sccb},sccb=>0);
	$outstring .= &endRow;
	$outstring .= &endTable;
	$outstring .= &startTable(columns => $numColumns, width => 700, border=>0,titleBackground => "#f0f0f0");
	$outstring .= &addSpacerRow (columns => $numColumns);
	$outstring .= &startRow (bgColor => "#f0f0f0");
	$outstring .= &addCol (value => "<font color=black size=-1><b>Required Roles:</b></font>", colspan=>$numColumns);
	$outstring .= &endRow();
	$outstring .= &startRow (bgColor => "#f0f0f0");
	$outstring .= &addCol (value => "<b>Chair</b>", colspan=>$numColumns);
	$outstring .= &endRow();
	$outstring .= &startRow (bgColor => "#f0f0f0");
	$outstring .= &build_tri_select (dbh=>$args{dbh},sccb=>0,roleid=>1);
	$outstring .= &endRow();
	$outstring .= &addSpacerRow (columns => $numColumns,spacerBackground=>"#bbbbcc");
	$outstring .= &startRow (bgColor => "#f0f0f0");
	$outstring .= &addCol (value => "<b>RSIS Lead:</b>&nbsp;<input name=RSISlead value='Software Development Lead' size=100>", colspan=>$numColumns);
	$outstring .= &endRow();
	$outstring .= &startRow (bgColor => "#f0f0f0");
	$outstring .= &build_tri_select (dbh=>$args{dbh},sccb=>0,roleid=>2);
	$outstring .= &endRow();
	$outstring .= &addSpacerRow (columns => $numColumns,spacerBackground=>"#bbbbcc");
	$outstring .= &endTable;
	$outstring .= <<END_OF_BLOCK2;
	<div id=newroles></div>
	<table  id="roleTable" cellpadding=4 cellspacing=1 border=0 width=70% align=center>
	<tr><td>&nbsp;&nbsp;<a href="javascript:addRole('roleTable','$userlist');"><font size=-1>Add Role</font></a></td></tr>
	</table>
	<table width=700 border=0 align=center>
	<tr><td height=25></td></tr>
	<tr><td colspan=2 align=center><input type=button value="Create SCCB" onClick=submitProcessForm('sccb','db_create','');></td></tr>
	</table><br><br>
	</center>
END_OF_BLOCK2
	return ($outstring);
}
#################
sub updateSCCBBody {
#################
   my %args = (
      schema => $ENV{SCHEMA},
      @_,
   );
   my $userlist = "";
   my @users = &getSCCBUserRoleList(dbh=>$args{dbh},schema=>$args{schema},sccb=>$args{sccb});
   for (my $m=0; $m<$#users;$m++) {
   	$userlist .= "$users[$m]{userid},$users[$m]{username},";
   }
   $userlist =~ s/'/_/;
   chop($userlist);
   my @userRoleArray;
   my $roleList = '';
   my $rolenames = "";
	my $outstring = "";
	my @roles = split /,/, $args{roles};
	my $rolecount = $#roles;
	my @roleArray = &getSCCBRoleList(dbh=>$args{dbh},schema=>$args{schema},sccb=>$args{sccb});
	my $numColumns = 5;
	$outstring .= &startTable(columns => $numColumns, title => "$roleArray[0]{sccbname} SCCB", width => 700, border=>0,titleBackground => "#f0f0f0");
	$outstring .= &addSpacerRow (columns => $numColumns);
	$outstring .= &startRow (bgColor => "#f0f0f0");
	$outstring .= &build_dos_select (dbh=>$args{dbh},sccb=>$args{sccb},sccb=>$args{sccb});
	$outstring .= &endRow();
	$outstring .= &addSpacerRow (columns => $numColumns,spacerBackground=>"#bbbbcc");
	for (my $i = 0; $i < $#roleArray; $i++) {
	   $roleList .= "," if ($i != 0);
	   $roleList .= "$roleArray[$i]{roleid}";
		$outstring .= &startRow (bgColor => "#f0f0f0");
		$outstring .= &addCol (value => "SCCB Role:&nbsp;$roleArray[$i]{rolename}", colspan=>4);
		if ($i>=2) { #not allowing removal of required roles but allowing user updates
			$outstring .= &addCol (value => "<input type=checkbox name='role$roleArray[$i]{roleid}'><font size=-2>Remove Role</font>",align=>'center');
		}
		else {
			$outstring .= &addCol (value => "<input type=hidden name='role$roleArray[$i]{roleid}'>&nbsp;",align=>'center');
		}
		@userRoleArray = &getSCCBUserRoleList(dbh=>$args{dbh},schema=>$args{schema},sccb=>$args{sccb},roleid=>$roleArray[$i]{roleid},isalt=>'F');
		$outstring .= &endRow();
		$outstring .= &startRow (bgColor => "#f0f0f0");
		$outstring .= &build_tri_select (dbh=>$args{dbh},sccb=>$args{sccb},roleid=>$roleArray[$i]{roleid});
		$outstring .= &endRow();
		$outstring .= &addSpacerRow (columns => $numColumns,spacerBackground=>"#bbbbcc");
	}
	$outstring .= &endTable;
	$outstring .= <<END_OF_BLOCK2;
	<div id=newroles></div>
	<table  id="roleTable" cellpadding=4 cellspacing=1 border=0 width=70% align=center>
	<tr><td>&nbsp;&nbsp;<a href="javascript:addRole('roleTable','$userlist');"><font size=-1>Add Role</font></a></td></tr>
	</table>
	<table width=700 border=0 align=center>
	<tr><td height=25></td></tr>
	<tr><td colspan=2 align=center><input type=button value="Update SCCB" onClick=submitProcessForm('sccb','db_update',"$roleList");></td></tr>
	</table><br><br>
	</center>
END_OF_BLOCK2
	$outstring .= "<input type=hidden name=sccbname value='$roleArray[0]{sccbname}'>\n";
	$outstring .= "<input type=hidden name=sccb value=$args{sccb}>\n";
	return ($outstring);
}

###################################################################################################################################
sub doBrowseSCCB{  # routine to display a table of documents
###################################################################################################################################
    my %args = (
        project => 0,  # null
        title => 'Software Baseline Items',
        userID => 0, # all
        @_,
    );
    my $output = '';
    my $numColumns = 3;
    my $count;
    my $first = 1;
    my ($itemid,$itemmajor,$itemminor,$baselinedate,$itemname,$itemsource);
    my @itemList = &getCurrentBaseline(dbh => $args{dbh}, schema => $args{schema}, project => $args{project});
    for (my $i = 0; $i < $#itemList; $i++) {
         ($itemid,$itemmajor,$itemminor,$baselinedate,$itemname,$itemsource) = 
          ($itemList[$i]{itemid},$itemList[$i]{itemmajor},$itemList[$i]{itemminor},
          $itemList[$i]{baselinedate},$itemList[$i]{itemname},$itemList[$i]{itemsource});
        $count++;
        if ($first) {
			  $output .= &startTable(columns => $numColumns, title => "$args{title}", width => 500);
			  $output .= &startRow (bgColor => "#f0f0f0");
			  $output .= &addCol (value => "Configuration Item", align => "center");
			  $output .= &addCol (value => "Version", align => "center");
			  $output .= &addCol (value => "Baseline Date", align => "center");
			  $output .= &endRow();
			  $output .= &addSpacerRow (columns => $numColumns);
			  $first = 0;
        }
		  $output .= &startRow;
		  my $prompt = "";
		  $output .= &addCol (value=>$itemname);
		  $output .= &addCol (value=>$itemmajor . "." . $itemminor);
		  $output .= &addCol (value=>$baselinedate);
		  $output .= &endRow;
    }
    $output .= &endTable();
    $output =~ s/xxx/$count/;
    $output =~ s/&quot;/'/g;  #should not need this, I am doing something wrong *****************************************************************
    $output = '' if ($count == 0);
    return($output);
}
###################################################################################################################################
sub buildProjectSelect { #temporary!! - move when UI_scm function is complete
###################################################################################################################################
	 my %args = (
    	 schema => $SCHEMA,
  	 	 userID => 0,
  		 name => 'project1',
  		 @_,
	 );
	 my $dbh = $args{dbh};
	 my $userid = $args{userID};
	 my $notes;
	 tie my %projectlist, "Tie::IxHash";

	 %projectlist = &getProjects(dbh => $dbh);
	 my $outstring = "";
	 $outstring .= "<select name=$args{name} size=1>\n";
	 foreach my $project (keys (%projectlist)) {
	 	 $notes = ($args{notesfilter} eq 'F' || $projectlist{$project}{isNotes} eq 'F') ? 1 : 0;
	    if (($projectlist{$project}{configurationManagerID} == $userid || $projectlist{$project}{projectManagerID} == $userid || 
			&doesUserHavePriv(dbh => $dbh, schema => $args{schema}, userid => $userid, privList => [11]) == 1) && $notes) 
				 {$outstring .= "<option value=$project>$projectlist{$project}{name}\n";}
	 }
	 $outstring .= <<END_OF_TEXT;
	 </select>
END_OF_TEXT
	 return($outstring);
}

#################
sub createUserList {
#################
   my %args = (
      schema => $ENV{SCHEMA},
      @_,
   );
   my $multiple = ($args{label} eq 'Alternate(s)') ? " multiple" : "";
   #my $size = ($args{label} eq 'Alternate(s)') ? " size=1 " : " size=1 ";
   my ($userid,$username);
	my @userList = &getUserList(schema => $args{schema}, dbh => $args{dbh});
	my $outstring = "";
	$outstring .= "<font size=-1><b>$args{label}:&nbsp;&nbsp;</b></font><select name=$args{name} size=1 $multiple>\n";
	for (my $i = 0; $i < $#userList; $i++) {
	    ($userid,$username) = ($userList[$i]{userid},$userList[$i]{name});
	    $outstring .= "<option value=$userid>$username\n";
	}
	$outstring .= "<option value=0>TBD\n" if ($args{label} eq 'Alternate(s)');
	$outstring .= "</select>\n";
	return($outstring);
}

 ####################################################################################################################################
 sub build_tri_select {
 # routine to build a triple selection box from arrays passed to it
 ####################################################################################################################################
	my %args = (
		schema => $ENV{SCHEMA},
	   @_,
   );
	my @userRoleArray;
	my $outstring = "";
	my $rolenames;
	@userRoleArray = &getSCCBUserRoleList(dbh=>$args{dbh},schema=>$args{schema},sccb=>$args{sccb},includeRole=>$args{roleid},isalt=>'F');
	$outstring .= "<td style=\"font-size: 14;\">Primary:<br><select name=roleprimary$args{roleid} multiple size=5 style=\"font-size: 10;\">\n";
	for (my $i = 0; $i < $#userRoleArray; $i++) {
		$outstring .= "<option value=$userRoleArray[$i]{userid}>$userRoleArray[$i]{username}\n";
	}
	$outstring .= "<option value=0>" . &nbspaces(29) . "\n";
	$outstring .= "</select></td><td align=center><input type=button name=primary$args{roleid} onclick=\"process_dual_select_option(document.sccb.users$args{roleid},document.sccb.roleprimary$args{roleid},'move');\" value=\"<-- Select Primary\"  style=\"font-size: 10;\"><br>";
	$outstring .= "<input type=button name=deselectprimary$args{roleid} onclick=\"process_dual_select_option(document.sccb.roleprimary$args{roleid},document.sccb.users$args{roleid},'move','1');\"  value=\"Deselect Primary -->\"  style=\"font-size: 10;\"></td>\n";
	my @users = &getSCCBUserRoleList(dbh=>$args{dbh},schema=>$args{schema},sccb=>$args{sccb},excludeRole=>$args{roleid});
	$outstring .= "<td style=\"font-size: 14; \">Available Users:<br><select name=users$args{roleid} multiple size=5 ondblclick=\"process_dual_select_option(document.sccb.users$args{roleid},document.sccb.rolealternate$args{roleid},'move')\" style=\"font-size: 10;\">\n";
	for (my $j = 0; $j < $#users; $j++) {
		$outstring .= "<option value=$users[$j]{userid}>$users[$j]{username}\n";
	}
	$outstring .= "</select></td><td align=center><input type=button name=alternate$args{roleid} onclick=\"process_dual_select_option(document.sccb.users$args{roleid},document.sccb.rolealternate$args{roleid},'move');\" value=\"Select Alternate -->\"  style=\"font-size: 10;\"><br>";
	$outstring .= "<input type=button name=deselectprimary$args{roleid} onclick=\"process_dual_select_option(document.sccb.rolealternate$args{roleid},document.sccb.users$args{roleid},'move','1');\" value=\"<-- Deselect Alternate\"  style=\"font-size: 10;\"></td>\n";
	@userRoleArray = &getSCCBUserRoleList(dbh=>$args{dbh},schema=>$args{schema},sccb=>$args{sccb},includeRole=>$args{roleid},isalt=>'T');
	$outstring .= "<td style=\"font-size: 14;\">Alternates:<br><select name=\"rolealternate$args{roleid}\" multiple size=5  style=\"font-size:10;\">\n";
	for (my $k = 0; $k < $#userRoleArray; $k++) {
		$outstring .= "<option value=$userRoleArray[$k]{userid}>$userRoleArray[$k]{username}\n";
	}
	$outstring .= "<option value=0>" . &nbspaces(29) . "\n";
	$outstring .= "</select></td>\n";
   return ($outstring);
 }
 
 ####################################################################################################################################
  sub build_dos_select {
  # routine to build a triple selection box from arrays passed to it
  ####################################################################################################################################
 	my %args = (
 		schema => $ENV{SCHEMA},
 		sccb => 0,
 	   @_,
    );
   my @projectSCCBs = &getSCCBProjectList(dbh=>$args{dbh},schema=>$args{schema},sccb=>$args{sccb});
 	my @projectSCCBselect = &getSCCBProjectList(dbh=>$args{dbh},schema=>$args{schema},includesccb=>'F',sccb=>$args{sccb});
 	my $outstring = "";
 	$outstring .= "<td colspan=2 align=center style=\"font-size: 14;\">Assigned Projects:<br><select name=sccbprojects multiple size=3 style=\"font-size: 10;\">\n";
 	for (my $i = 0; $i < $#projectSCCBs; $i++) {
 		$outstring .= "<option value=$projectSCCBs[$i]{projectid}>$projectSCCBs[$i]{projectname}\n";
 	}
 	$outstring .= "<option value=0>" . &nbspaces(45) . "\n";
 	$outstring .= "</select></td><td align=center><input type=button name=sccbselect onclick=\"process_dual_select_option(document.sccb.sccbprojectselect,document.sccb.sccbprojects,'move');\" value=\"<-- Select Project\"  style=\"font-size: 10;\"><br>";
 	$outstring .= "<input type=button name=sccbdeselect onclick=\"process_dual_select_option(document.sccb.sccbprojects,document.sccb.sccbprojectselect,'move','1');\"  value=\"Deselect Project -->\"  style=\"font-size: 10;\"></td>\n";
 	$outstring .= "<td colspan=2 align=center style=\"font-size: 14;\">Available Projects:<br><select name=\"sccbprojectselect\" multiple size=3  style=\"font-size:10;\">\n";
 	for (my $k = 0; $k < $#projectSCCBselect; $k++) {
 		$outstring .= "<option value=$projectSCCBselect[$k]{projectid}>$projectSCCBselect[$k]{projectname}\n";
 	}
 	$outstring .= "<option value=0>" . &nbspaces(45) . "\n";
 	$outstring .= "</select></td>\n";
    return ($outstring);
 }
###################################################################################################################################
sub doCreateSCCB {  # routine to insert a new document into the DB
###################################################################################################################################
	my %args = (
		 project => 0,  # null
		 userID => 0,
		 userName => '',
		 @_,
	);
   my $hashRef = $args{settings};
   my %settings = %$hashRef;
   my $output = "";

   my $status = &doProcessCreateSCCB(dbh => $args{dbh}, schema => $args{schema}, userID => $args{userID}, 
   		userName => $args{userName}, sccbname => $args{sccbname}, project => $args{project},settings => \%settings);
    
	$output .= doAlertBox(text => "$settings{sccbname} successfully created");
	$output .= "<script language=javascript><!--\n";
	$output .= "   changeMainLocation('utilities');\n";
	$output .= "//--></script>\n";
	   
   return($output);
     
}

###################################################################################################################################
sub doUpdateSCCB {  # routine to insert a new document into the DB
###################################################################################################################################
	my %args = (
		 project => 0,  # null
		 userID => 0,
		 userName => '',
		 sccb => 0,
		 @_,
	);
 
   my $hashRef = $args{settings};
   my %settings = %$hashRef;
   my $output = "";

   my $status = &doProcessUpdateSCCB(dbh => $args{dbh}, schema => $args{schema}, userID => $args{userID}, userName => $args{userName}, sccbname => $args{sccbname}, 
   				sccb => $args{sccb}, project => $args{project},settings => \%settings);
 
   $output .= doAlertBox(text => "$args{sccbname} successfully updated");
   $output .= "<script language=javascript><!--\n";
   $output .= "   changeMainLocation('utilities');\n";
   $output .= "//--></script>\n";
   
   return($output);
}
###################################################################################################################################
###################################################################################################################################

sub new {
    my $self = {};
    bless $self;
    return $self;
}

# proccess variable name methods
sub AUTOLOAD {
    my $self = shift;
    my $type = ref($self) || croak "$self is not an object";
    my $name = $AUTOLOAD;
    $name =~ s/.*://; # strip fully-qualified portion
    unless (exists $self->{$name} ) {
        croak "Can't Access '$name' field in object of class $type";
    }
    if (@_) {
        return $self->{$name} = shift;
    } else {
        return $self->{$name};
    }
}

1; #return true
