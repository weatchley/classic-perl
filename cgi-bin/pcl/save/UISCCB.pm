#
# $Source: $
#
# $Revision: $ 
#
# $Date: $
#
# $Author: $
#
# $Locker: $
#
# $Log: $
#
package UISCCB;
use strict;
use SCM_Header qw(:Constants);
use UI_Widgets qw(:Functions);
use DB_scm qw(:Functions);
use UI_scm qw(:Functions);
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
      &continueSCCBBody				&updateSCCBBody
    );
%EXPORT_TAGS =( 
    Functions => [qw(
      &doBrowseSCCBTable 	   	&doHeader                  &doFooter                     
      &getInitialValues				&doBrowseSCCB					&createSCCBBody
      &continueSCCBBody				&updateSCCBBody
    )]
);

my $scmcgi = new CGI;

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
       schema => (defined($scmcgi->param("schema"))) ? $scmcgi->param("schema") : $ENV{'SCHEMA'},
       command => (defined ($scmcgi -> param("command"))) ? $scmcgi -> param("command") : "browse",
       username => (defined($scmcgi->param("username"))) ? $scmcgi->param("username") : "",
       userid => (defined($scmcgi->param("userid"))) ? $scmcgi->param("userid") : "",
       project => (defined($scmcgi->param("project"))) ? $scmcgi->param("project") : 0,
       select1 => (defined($scmcgi->param("select1"))) ? $scmcgi->param("select1") : 0,
       project => (defined($scmcgi->param("project"))) ? $scmcgi->param("project") : 0,
       description => (defined($scmcgi->param("description"))) ? $scmcgi->param("description") : 0,
       roles => (defined($scmcgi->param("roles"))) ? $scmcgi->param("roles") : 0,
       title => (defined($scmcgi->param("title"))) ? $scmcgi->param("title") : "SCCB"
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
    
    $output .= $scmcgi->header('text/html');
    $output .= "<html>\n<head>\n<title>$args{title}</title>\n";
    $output .= <<END_OF_BLOCK;
    <script language=javascript><!--
		 function displayCurrentMembers(sccbdate,project) {
			  //$form.command.value = 'browseversions';
			  $form.command.value = 'browsefilemoves';
			  $form.project.value = project;
			  $form.baselinedate.value = sccbdate;
			  $form.action = '$path$form.pl';
			  $form.target = 'main';
			  $form.submit();
       }
       function submitFormCGIResults(script,command) {
           document.$form.command.value = command;
           document.$form.action = '$path' + script + '.pl';
           document.$form.target = 'cgiresults';
           document.$form.submit();
       }
       function submitForm(script,command) {
           document.$form.command.value = command;
           document.$form.action = '$path' + script + '.pl';
           document.$form.target = 'main';
           document.$form.submit();
       }
       function submitContinueForm(script,command) {
       	  var i =  document.$form.length; 
       	  var rolestart = 0;
       	  var rolecount = document.$form.rolecount.value;
       	  var j = 0;
       	  var rolelist = '';
       	  for (j; j<i; j++) {
       	    if (document.$form.elements[j].name == 'role1') {
       	    	rolestart = j;
       	    }
       	  }
       	  for (j=0; j < rolecount; j++,rolestart++) {
       	      if (!isblank(rolelist)) rolelist = rolelist + ',';
       	  		if (!isblank(document.$form.elements[rolestart].value)) rolelist = rolelist + document.$form.elements[rolestart].value;
       	  }
       	  document.$form.roles.value = rolelist;
			  document.$form.command.value = command;
			  document.$form.action = '$path' + script + '.pl';
			  document.$form.target = 'main';
			  document.$form.submit();
       }
       function displayUser(id) {
          document.$form.id.value = id;
          submitForm ('users', 'displayuser');
       }
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
		function createBox() {
		   var number = parseInt(document.$form.rolenum.value);
			data = "";
			inter = "'";
			spaces="    ";
			data = data + "Role: " + number + " :</td><td>" + spaces
			+ "<input type='text' size=25 name=" + inter
			+ "role" + number + inter + "'><br>";
			cust.innerHTML = cust.innerHTML + data;
			document.$form.rolenum.value = number + 1;
		}
	  function addRole(id,change){
	  		if (change) changeButton();
	  		var i = parseInt(document.$form.rolenum.value);
	  		var tbody = document.getElementById
		 	(id).getElementsByTagName("TBODY")[0];
		 	var row = document.createElement("TR");
		  	var td1 = document.createElement("TD");
		  	var b1 = document.createElement("b");
		  	var f1 = document.createElement("font");
		  	f1.setAttribute("size","-1");
		  	b1.appendChild(document.createTextNode("Role"));
		  	f1.appendChild(b1);
		  	td1.appendChild(f1);
		  	var td2 = document.createElement("TD");
		  	td2.appendChild (document.createElement("<input type=text name=role" + i + " size=55>"));
		  	row.appendChild(td1);
		  	row.appendChild(td2);
   		tbody.appendChild(row);
   		document.$form.rolenum.value = i + 1;
   		document.$form.rolecount.value = i;
  	 }
  	 function changeButton() {
	 	parent.main.updatebutton.style.display = 'none';
	 	parent.main.continuebutton.style.display = 'block';
}
    //-->
    </script>
END_OF_BLOCK
    $output .= "</head>\n";
    $output .= "<body text=#000099 background=$SCMImagePath/background.gif>\n";
    $output .=  (($args{displayTitle} eq 'T') ? &writeTitleBar(userName => $username, userID => $userid, schema => $args{schema}, title => $args{title}) : "");
    $output .= "<form enctype=\"multipart/form-data\" name=$form method=post target=main action=$path$form.pl>\n";
    $output .= "<input type=hidden name=userid value=$userid>\n";
    $output .= "<input type=hidden name=username value=$username>\n";
    $output .= "<input type=hidden name=schema value=$args{schema}>\n";
    $output .= "<input type=hidden name=command value=''>\n";
    $output .= "<input type=hidden name=project value=''>\n";
    $output .= "<input type=hidden name=id value=''>\n";
    $output .= "<input type=hidden name=rolenum value=1>\n";
    $output .= "<input type=hidden name=roles value=''>\n";
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
	my $outstring = "";
	$outstring .= <<END_OF_BLOCK4;
	<center>
	<table id="roleTable" cellpadding=4 cellspacing=0 border=0 width=50%>
	<tr><td height=17></td></tr>
	<tr><td align=left><b><font size=-1>SCCB Name:</font></b></td><td><input type=text name=sccbname size=40></td></tr>
	<tr><td align=left><b><font size=-1>Project:</font></b></td>
END_OF_BLOCK4
	$outstring .= "<td>" . &buildProjectSelect(dbh=>$args{dbh}, schema=>$args{schema},name=>'project',userID=>$args{userID},notesfilter=>'F') . "</td></tr>\n";
	$outstring .= <<END_OF_BLOCK2;
	<tr><td height=7 colspan=2></td></tr>
	<tr><td colspan=2><font color=black size=-1><b>Required Roles:</b></font></td></tr>
	<tr><td colspan=2><b><font size=-1><li>Chair</font></b></td></tr>
	<tr><td colspan=2><b><font size=-1><li>Software Development Lead</font></b></td></tr>
	<tr><td>&nbsp;&nbsp;<a href="javascript:addRole('roleTable',0)"><font size=-1>Add Additional Role</font></a></td></tr>
	<tbody><tr><td colspan=2 height=7</td></tr>
	</tbody></td></tr>
	<tr><td height=25></td></tr>
	<tr><td colspan=2 align=center><input type=button value="Continue" onClick=submitContinueForm('sccb','continue');></td></tr>
	</table><br><br>
	</center>
END_OF_BLOCK2
	return ($outstring);
}

#################
sub continueSCCBBody {
#################
   my %args = (
      schema => $ENV{SCHEMA},
      @_,
   );
   my $i = 0;
	my $outstring = "";
	my @roles = split /,/, $args{roles};
	my $rolecount = $#roles;
	$outstring .= <<END_OF_BLOCK4;
	<center>
	<table cellpadding=4 cellspacing=0 border=0 width=70%>
	<tr><td height=17></td></tr>
	<tr><td align=left><b><font size=-1>SCCB Name:</font></b></td><td colspan=2>-- SCCB NAME --</td></tr>
	<tr><td align=left><b><font size=-1>Project:</font></b></td><td colspan=2>-- PROJECT --</td></tr>
	<tr><td height=7 colspan=3></td></tr>
END_OF_BLOCK4
	$outstring .= "<tr><td colspan=3><font color=black size=-1><b>Required Roles:</b></font></td></tr>\n";
	$outstring .= "<tr><td valign=bottom><b><font size=-1><li>Chair</font></b></td><td nowrap>" . &createUserList(dbh=>$args{dbh}, schema=>$args{schema},name=>"role$i",label=>'Primary') . "</td><td nowrap>"  . &createUserList(dbh=>$args{dbh}, schema=>$args{schema},name=>"altrole$i",label=>'Alternate(s)') . "</td></tr>\n";
		$i++;
	$outstring .= "<tr><td nowrap valign=bottom><b><font size=-1><li>Software Development Lead</font></b></td><td>" . &createUserList(dbh=>$args{dbh}, schema=>$args{schema},name=>"role$i",label=>'Primary') . "</td><td nowrap>"  . &createUserList(dbh=>$args{dbh}, schema=>$args{schema},name=>"altrole$i",label=>'Alternate(s)') . "</td></tr>\n";
		$i++;
	$outstring .= "<tr><td height=7 colspan=3></td></tr>\n";
	$outstring .= "<tr><td colspan=3><font color=black size=-1><b>Additional Roles:</b></font></td></tr>\n";
	foreach my $role (@roles) {
		$outstring .= "<tr><td valign=bottom><b><font size=-1><li>$role</font></b></td><td nowrap>" . &createUserList(dbh=>$args{dbh}, schema=>$args{schema},name=>"primaryrole$i",label=>'Primary') . "</td><td nowrap>"  . &createUserList(dbh=>$args{dbh}, schema=>$args{schema},name=>"altrole$i",label=>'Alternate(s)') . "</td></tr>\n";
		$i++;
	}
	$outstring .= <<END_OF_BLOCK2;
	<tr><td height=25></td></tr>
	<tr><td colspan=3 align=center><input type=button value="Create SCCB" onClick=alert('pending');></td></tr>
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
	my $outstring = "";
	my @roles = split /,/, $args{roles};
	my $rolecount = $#roles;
	my @roleArray = &getSCCBUserRoleList(dbh=>$args{dbh},schema=>$args{schema},project=>2);
	my $numColumns = 5;
	$outstring .= <<END_OF_BLOCK4;
	<center>
	<table cellpadding=4 cellspacing=1 border=0 width=70%>
	<tr><td height=17></td></tr>
	<tr><td height=7 colspan=5></td></tr>
END_OF_BLOCK4
	$outstring .= &startTable(columns => $numColumns, title => "$roleArray[0]{sccbname}", width => 700,border=>0);
	$outstring .= &addSpacerRow (columns => $numColumns);
	$outstring .= &startRow (bgColor => "#f0f0f0");
	$outstring .= &startRow (bgColor => "#f0f0f0");
	$outstring .= &addCol (value => "Project(s): projectname(s)", colspan=>$numColumns-1);
	$outstring .= &addCol (value => "<a href=javascript:alert('edit');>Edit</a>", align => 'center');
	$outstring .= &endRow();
	$outstring .= &addCol (value => "Role", align => 'center');
	$outstring .= &addCol (value => "Primary", align => 'center');
	$outstring .= &addCol (value => "Alternates", align => 'center');
	$outstring .= &addCol (value => "Edit", align => 'center');
	$outstring .= &addCol (value => "Delete", align => 'center');
	$outstring .= &endRow();
	for (my $i = 0; $i < $#roleArray; $i++) {
		$outstring .= &startRow;
		$outstring .= &addCol (value => "$roleArray[$i]{desc}",width=>300);
		$outstring .= &addCol (value => "$roleArray[$i]{name}");
		if ($roleArray[$i]{desc} eq $roleArray[$i+1]{desc}) {
			$outstring .= &addCol (value => "$roleArray[$i+1]{name}");
			$i++;
		}
		else {$outstring .= &addCol (value => "TBD");}
		$outstring .= &addCol (value => "<a href=javascript:alert('edit');>Edit</a>");
		$outstring .= &addCol (value => "<a href=javascript:alert('delete');>Delete</a>");
	}
	$outstring .= <<END_OF_BLOCK2;
	</table>
	<table  id="roleTable" cellpadding=4 cellspacing=1 border=0 width=70%>
	<tr><td>&nbsp;&nbsp;<a href="javascript:addRole('roleTable',1)"><font size=-1>Add Role</font></a></td></tr>
	<tbody><tr><td colspan=2 height=7</td></tr>
	</tbody></td></tr>
	<tr><td height=25></td></tr>
	<tr><td height=25></td></tr>
	<tr><td colspan=2 align=center><span id="continuebutton" Style=Display:none;><input type=button value="Continue" onClick=alert('pending');></span></td></tr>
	<tr><td colspan=2 align=center><span id="updatebutton" Style=Display:block;><input type=button value="Update SCCB" onClick=alert('pending');></span></td></tr>
	</table><br><br>
	</center>
END_OF_BLOCK2
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
