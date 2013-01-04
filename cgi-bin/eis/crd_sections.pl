#!/usr/local/bin/newperl -w
#
# $Source: /data/dev/rcs/crd/perl/RCS/crd_sections.pl,v $
#
# $Revision: 1.8 $
#
# $Date: 2002/02/20 16:41:48 $
#
# $Author: atchleyb $
#
# $Locker:  $
#
# $Log: crd_sections.pl,v $
# Revision 1.8  2002/02/20 16:41:48  atchleyb
# removed depricated function use named parameters and changed the html header
#
# Revision 1.7  2001/11/21 00:12:06  atchleyb
# added count of mapped bins to the display/update table
#
# Revision 1.6  2001/11/20 19:05:50  atchleyb
# fixed quote problem in save/update
#
# Revision 1.5  2001/11/02 22:19:28  atchleyb
# changed javascript submit functions to not reset values after submition
# changed alert box code to handle single quotes
#
# Revision 1.4  2001/09/13 19:47:39  atchleyb
# made the font size smaller on the browse/update table
#
# Revision 1.3  2001/09/13 17:22:50  atchleyb
# changed crd connect to use defalut server
#
# Revision 1.2  2001/06/22 21:26:24  atchleyb
# added activitylog updates for several functions.
#
# Revision 1.1  2001/06/14 20:14:30  atchleyb
# Initial revision
#
#
#

use integer;
use strict;
use CRD_Header qw(:Constants);
use UI_Widgets qw(:Functions);
use DB_Utilities_Lib qw(:Functions);
use DBI;
use DBD::Oracle qw(:ora_types);
use CGI qw(param);
use Tie::IxHash;

$| = 1;

my $crdcgi = new CGI;
my $userid = $crdcgi->param("userid");
my $username = $crdcgi->param("username");
my $schema = $crdcgi->param("schema");

&checkLogin ($username, $userid, $schema);

$ENV{SCRIPT_NAME} =~ m%(.*/)(.*)\..*$%;
my $path = $1;
my $form = $2;

my $command = $crdcgi->param("command");
my $dbh = db_connect();
#my $dbh = db_connect(server =>'ydoradev');

#$dbh->{LongTruncOk} = 1;   # specify whether to fetch whole text or truncated fraction 
#$dbh->{LongReadLen} = 10000000;


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
   if (($args{command} eq "browse") || ($args{command} eq "browseTable")) {
      $title = "Browse CRD Sections";
   } elsif (($args{command} eq "update") || ($args{command} eq 'update1') || ($args{command} eq 'update2')) {
      $title = "Update CRD Sections";
   } elsif ($args{command} eq "add" || ($args{command} eq 'add2')) {
      $title = "Add CRD Sections";
   } elsif ($args{command} eq "delete" || ($args{command} eq 'delete1')) {
      $title = "Delete CRD Section";
   }
   return ($title);
}

###################################################################################################################################
sub buildForm {                                                                                                                   #
###################################################################################################################################
    my %args = (
        formType => 'New',
        item => {ID => 0, section_number => '', section_name => '', parent => 0},
        @_,
    );
    my $outputstring = '';
    
    $outputstring .= "<input type=hidden name=crdsectionid value=$args{item}{ID}>\n";
    $outputstring .= "<table border=0 align=center>\n";
    $outputstring .= "<tr><td valign=bottom><b>Number: &nbsp; </b><input type=text size=20 maxlength=20 name=crdsectionnumber value=\"$args{item}{section_number}\"> &nbsp; </td></tr>\n";
    $outputstring .= "<tr><td valign=bottom><b>Name: &nbsp; </b><input type=text size=60 maxlength=150 name=crdsectionname value=\"$args{item}{section_name}\"> &nbsp; </td></tr>\n";
    my @itemList = getItemList (dbh => $args{dbh}, schema => $args{schema});
    $outputstring .= "<tr><td valign=bottom><b>Parent: &nbsp; </b><select name=crdsectionparent". (($args{formType} ne 'New') ? " onChange=testForBins(this)" : '') . ">\n";
    $outputstring .= "<option value=0>None\n";
    for (my $i=0; $i <= $#itemList; $i++) {
        if ($itemList[$i]{ID} != $args{item}{ID}) {
            $outputstring .= "<option value=$itemList[$i]{ID}>" . getDisplayString("$itemList[$i]{section_number} $itemList[$i]{section_name}",75) . "\n";
        }
    }
    $outputstring .= "</select></tr>\n";
    $outputstring .= "<script language=javascript><!-- \n";
    $outputstring .= "set_selected_option(document.$form.crdsectionparent, $args{item}{parent});\n";
    $outputstring .= "//-->\n";
    $outputstring .= "</script>\n";
    $outputstring .= "</td></tr>\n";
    $outputstring .= "<tr><td align=center><br><input type=button name=crdsectionsubmit value=Submit onClick=\"if(process_$form(document.$form)) {submitFormCGIResults('$form','". (($args{formType} eq 'Update') ? 'update2' : 'add2') . "',0);}\"><br>&nbsp;</td></tr>\n";
    $outputstring .= "</table>\n";
    if ($args{formType} ne 'New') {
        my ($count) = $args{dbh}->selectrow_array("SELECT count(*) FROM $args{schema}.bin WHERE crd_section=$args{item}{ID}");
        my ($count2) = $args{dbh}->selectrow_array("SELECT count(*) FROM $args{schema}.crd_sections WHERE parent=$args{item}{ID}");
        if ($count > 0) {
            $outputstring .= "<br>\n";
            my $csr = $args{dbh}->prepare("SELECT id,name FROM $args{schema}.bin WHERE crd_section=$args{item}{ID} ORDER BY name");
            my $status = $csr->execute;
            my $backColor = "#ffffff";
            $outputstring .= "<input type=hidden name=binid value=0>\n";
            $outputstring .= "<script language=javascript><!-- \n";
            $outputstring .= "function displayBin(id) {\n";
            $outputstring .= "   $form.binid.value = id;\n";
            $outputstring .= "   submitForm('bins', 'browse');\n";
            $outputstring .= "}\n";
            $outputstring .= "//-->\n";
            $outputstring .= "</script>\n";
            $outputstring .= "<table border=1 bordercolor=#d0d0d0 cellpadding=0 cellspacing=0 bgcolor=#ffffff><tr><td>\n";
            $outputstring .= "<table border=0 cellpadding=0 bgcolor=#ffffff>\n";
            $outputstring .= "<tr bgcolor=#a0e0c0><td><b>$count Bin" . (($count != 1) ? "s are" : " is") . " mapped to this section</b></td></tr>\n";
            while (my ($binID,$name) = $csr->fetchrow_array) {
                $backColor = (($backColor eq '#ffffff') ? '#f0f0f0' : '#ffffff');
                $outputstring .= "<tr bgcolor=$backColor><td><b><a href=javascript:displayBin($binID)>$name</a></b></td></td>\n";
            }
            $csr->finish;
            $outputstring .= "</table>\n";
            $outputstring .= "</td></tr></table><br>&nbsp;\n";
        } else {
            $outputstring .= "<b>No Bins are mapped to this section</b><br>&nbsp;\n";
        }
        $outputstring .="<input type=hidden name=bincount value=$count>\n";
        $outputstring .="<input type=hidden name=oldparent value=$args{item}{parent}>\n";
        $outputstring .= "<script language=javascript><!-- \n";
        $outputstring .= "function testForBins (what) {\n";
        $outputstring .= "    if (what.options[what.selectedIndex].value == 0 && document.$form.bincount.value > 0) {\n";
        $outputstring .= "        alert ('Parent Section can not be set to none when there are mapped bins');\n";
        $outputstring .= "        if (document.$form.oldparent.value != 0) {\n";
        $outputstring .= "            set_selected_option(what,document.$form.oldparent.value);\n";
        $outputstring .= "        } else {\n";
        $outputstring .= "            alert ('Warning! Selecting \"None\" for this section to not show up on the Final CRD report');\n";
        $outputstring .= "        }\n";
        $outputstring .= "    }\n";
        $outputstring .= "}\n";
        $outputstring .= "//-->\n";
        $outputstring .= "</script>\n";
        
        if ($count2 > 0) {
            $outputstring .= "<br><b>This section has subsections</b><br>&nbsp;\n";
        }
        if ($count == 0 && $count2 == 0) {
            $outputstring .= "<br><input type=button name=deleteButton value=Delete onClick=\"doDelete($args{item}{ID});\"><br>&nbsp;\n";
            $outputstring .= "</select></tr>\n";
            $outputstring .= "<script language=javascript><!-- \n";
            $outputstring .= "function doDelete (ID) {\n";
            $outputstring .= "    if (confirm('Do you wish to delete section $args{item}{section_number} $args{item}{section_name}')) {\n";
            $outputstring .= "        submitFormCGIResults('$form', 'delete1',0);\n";
            $outputstring .= "    } else {\n";
            $outputstring .= "        alert('Not Deleted');\n";
            $outputstring .= "    }\n";
            $outputstring .= "}\n";
            $outputstring .= "//-->\n";
            $outputstring .= "</script>\n";
        }
    }
    
    return ($outputstring);
}

###################################################################################################################################
sub buildDisplayTable {                                                                                                            #
###################################################################################################################################
    my %args = (
        update => 'F',
        @_,
    );
    my $outputstring = '';
    my @itemList = getItemList(@_);
    my %item;
    my $colspan = (($args{update} eq 'T') ? "5" : "4");
    my $parent;
    
    $outputstring .= "<table border=1 cellpadding=4 cellspacing=0>\n";
    $outputstring .= "<tr bgcolor=#c0ffff><td colspan=$colspan><b>Sections (" . ($#itemList + 1) . ")</b></td></tr>\n";
    $outputstring .= "<tr bgcolor=#f0f0f0>" . (($args{update} eq 'T') ? "<td><font size=-1>&nbsp;</font></td>" : "") . "<td valign=bottom><font size=-1><b>Number</b></font></td><td valign=bottom><font size=-1><b>Name</b></font></td><td align=center valign=bottom><font size=-1><b>Parent</b></font></td><td align=center valign=bottom><font size=-1><b>Bin Count</b></font></td></tr>\n";
    $outputstring .= "<tr><td colspan=$colspan height=4></td></tr>\n";
    
    if ($#itemList >= 0) {
        for (my $i=0; $i<= $#itemList;$i++) {
            $parent = (($itemList[$i]{parent} !=0) ?get_value($args{dbh},$args{schema},'crd_sections','section_number',"id = $itemList[$i]{parent}") : "None");
            $outputstring .= "<tr bgcolor=#ffffff>" . (($args{update} eq 'T') ? "<td align=center><font size=-1><a href=\"javascript:submitForm('$form','update1',$itemList[$i]{ID})\"><b>Edit</b></a></font></td>" : "") . "<td><font size=-1><b>$itemList[$i]{section_number}</b></font></td><td><font size=-1><b>$itemList[$i]{section_name}</b></font></td><td align=center><font size=-1><b>$parent</b></font></td>";
            my ($rows) = $args{dbh}->selectrow_array("SELECT count(*) FROM $args{schema}.bin WHERE crd_section = $itemList[$i]{ID}");
            $outputstring .= "<td align=center><font size=-1><b>$rows</b></font></td></tr>\n";
        }
    } else {
        $outputstring .= "<tr bgcolor=#ffffff><td align=center colspan=$colspan><b>No Items Found</b></td></tr>\n";
    }
    
    $outputstring .= "</table><br>&nbsp;\n";
    
    #if ($args{update} eq 'T') {
    #    $outputstring .= "<br><br><a href=\"javascript:submitForm('$form','add',0)\">Add</a>\n";
    #}
    
    return ($outputstring);
}

###################################################################################################################################
sub getItem {                                                                                                                     #
###################################################################################################################################
    my %args = (
        dbh => '',
        schema => '',
        ID => 0,
        @_,
    );
    my %item;
    my $counter = 0;
    my @values = $args{dbh}->selectrow_array("select id, section_number, section_name, NVL(parent,0) from $args{schema}.crd_sections WHERE id = $args{ID}");
    %item = (ID => $values[0], section_number => $values[1], section_name => $values[2], parent => $values[3]);
    return (%item);
}

###################################################################################################################################
sub getItemList {                                                                                                                 #
###################################################################################################################################
    my %args = (
        dbh => '',
        schema => '',
        @_,
    );
    my @itemList;
    my $counter = 0;
    my $sqlcode = "SELECT id, section_number, section_name, NVL(parent,0) FROM $args{schema}.crd_sections ORDER BY section_number,section_name";
    my $lookup = $args{dbh}->prepare($sqlcode);
    #print "\n<!-- $sqlcode -->\n\n";
    $lookup->execute;
    while (my @values = $lookup->fetchrow_array) {
        $itemList[$counter] = {ID => $values[0], section_number => $values[1], section_name => $values[2], parent => $values[3]};
        $counter++;
    }
    $lookup->finish;
    return (@itemList);
}

###################################################################################################################################
sub saveItem {                                                                                                                    #
###################################################################################################################################
    my %args = (
        dbh => '',
        schema => '',
        #item => {ID => 0, name => '', grouporder => 2},
        @_,
    );
    my $outputstring = '';
    my $sqlcode = '';
    
    $args{item}{section_name} =~ s/'/''/g;
    
    if ($args{item}{ID} == 0) {
        $sqlcode = "INSERT INTO $args{schema}.crd_sections (id, section_number, section_name, parent) VALUES ($schema.crd_sections_id.NEXTVAL,'$args{item}{section_number}','$args{item}{section_name}'," . (($args{item}{parent} != 0) ? $args{item}{parent} : "NULL") . ")";
        log_activity($args{dbh}, $args{schema}, $userid, "Insert new CRD section #$args{item}{section_number}");
    } else {
        $sqlcode = "UPDATE $args{schema}.crd_sections SET section_number='$args{item}{section_number}', section_name='$args{item}{section_name}', parent=" . (($args{item}{parent} != 0) ? $args{item}{parent} : "NULL") . " WHERE id=$args{item}{ID}";
        log_activity($args{dbh}, $args{schema}, $userid, "Update CRD section #$args{item}{section_number} (ID #$args{item}{ID})");
    }
    my $status = $args{dbh}->do($sqlcode);
    
    
    return($outputstring);
}

###################################################################################################################################
sub deleteItem {                                                                                                                  #
###################################################################################################################################
    my %args = (
        dbh => '',
        schema => '',
        #item => {ID => 0, name => '', grouporder => 2},
        @_,
    );
    my $outputstring = '';
    my $sqlcode = '';
    
    if ($args{item}{ID} != 0) {
        $sqlcode = "DELETE FROM $args{schema}.crd_sections WHERE id=$args{item}{ID}";
        my $status = $args{dbh}->do($sqlcode);
        log_activity($args{dbh}, $args{schema}, $userid, "Delete CRD section #$args{item}{section_number} (ID #$args{item}{ID})");
    }
    
    
    return($outputstring);
}

###################################################################################################################################
    
print $crdcgi->header('text/html');
print <<END_of_1;
<html>
<head>
<meta http-equiv=expires content='31 Dec 1997'>
<script src=$CRDJavaScriptPath/utilities.js></script>
<script src=$CRDJavaScriptPath/widgets.js></script>
<script language=javascript><!--

function process_$form (f) {
     var msg = "";
     if (f.command.value == 'update1' || f.command.value == 'add') {
         if (isblank(f.crdsectionnumber.value)) {
             msg += "Please Enter Section Number.\\n";
         }
         if (isblank(f.crdsectionname.value)) {
             msg += "Please Enter Section Name.\\n";
         }
     }
     if (msg != "") {
       alert (msg);
       return false;
     }
     return true;
}
   
function submitForm(script, command, id) {
    document.$form.command.value = command;
    document.$form.id.value = id;
    document.$form.action = '$path' + script + '.pl';
    document.$form.target = 'main';
    document.$form.submit();
}

function submitFormCGIResults(script, command, id) {
    document.$form.command.value = command;
    document.$form.id.value = id;
    document.$form.action = '$path' + script + '.pl';
    document.$form.target = 'cgiresults';
    document.$form.submit();
}

//-->
</script>
</head>

<body background=$CRDImagePath/background.gif text=$CRDFontColor link=#0000ff vlink=#0000ff alink=#0000ff topmargin=0 leftmargin=0>
<center>
END_of_1
my $title = &getTitle(command => $command);
print  &writeTitleBar(userName => $username, userID => $userid, schema => $schema, title => $title);
my @values;
my $sqlquery;
my $csr;
my $status = 0;
my $message;

my $id;
my $name;
my $coordinator;
my $nepareviewer;
my $parent;
my $techreviewpolicy;
my @techreviewers;


print "<form name=$form target=cgiresults onSubmit=\"return process_$form(this)\" action=$ENV{SCRIPT_NAME} method=post>\n";
print "<input type=hidden name=username value=$username>\n";
print "<input type=hidden name=userid value=$userid>\n";
print "<input type=hidden name=schema value=$schema>\n";
print "<input type=hidden name=id value=0>\n";
print "<input type=hidden name=command value=$command>\n";
print "<table border=0 width=750><tr><td align=center>\n";


if ($command eq 'browseTable') {
    eval {
        print buildDisplayTable(dbh => $dbh, schema => $schema);
    };
    if ($@) {
        $message = errorMessage($dbh,$username,$userid,$schema,"browse CRD sections.",$@);
        print doAlertBox( text => $message);
    }
}

if ($command eq 'browse') {
    eval {
        print buildDisplayTable(dbh => $dbh, schema => $schema);
    };
    if ($@) {
        $message = errorMessage($dbh,$username,$userid,$schema,"browse CRD sections.",$@);
        print doAlertBox( text => $message);
    }
}

if ($command eq 'update') {
    # get data for update -----------------------------------------------------------------------------------
    eval {
        print buildDisplayTable(dbh => $dbh, schema => $schema, update => 'T');
    };
    if ($@) {
        $message = errorMessage($dbh,$username,$userid,$schema,"load CRD Sections for update.",$@);
        print doAlertBox( text => $message);
    }
    
}

if ($command eq 'update1' || $command eq 'add') {
    # display update data in main screen -----------------------------------------------------------------------------------
    eval {
        my %item;
        my $saveType = (($command eq 'update1') ? 'Update' : 'New');
        if ($command eq 'update1') {
            %item = getItem(dbh => $dbh, schema => $schema, ID => $crdcgi->param("id"));
            print buildForm(dbh => $dbh, schema => $schema, formType => "$saveType", item => \%item);
        } else {
            print buildForm(dbh => $dbh, schema => $schema, formType => "$saveType");
        }
    };
    if ($@) {
        $message = errorMessage($dbh,$username,$userid,$schema,"$command.",$@);
        print doAlertBox( text => $message);
    }
}

if ($command eq 'update2' || $command eq 'add2') {
    # process update data -----------------------------------------------------------------------------------
    eval {
        my $ID = $crdcgi->param("crdsectionid");
        my $sectionnumber = $crdcgi->param("crdsectionnumber");
        my $sectionname = $crdcgi->param("crdsectionname");
        my $parent = $crdcgi->param("crdsectionparent");
        my $saveType = (($command eq 'update2') ? 'Update' : 'New');
            print "\n<!-- command = $command, saveType = $saveType -->\n\n";
        
        if (defined($sectionnumber) && $sectionnumber gt '   ' && defined($sectionname) && $sectionname gt '             ') {
            print saveItem(dbh => $dbh, schema => $schema, formType => "$saveType", item => {ID => $ID, section_number => $sectionnumber, section_name => $sectionname, parent => $parent});
            print "\n<!-- command = $command, saveType = $saveType -->\n\n";
            print "<script language=javascript><!--\n";
            print "   submitForm('$form','" . (($saveType eq 'Update') ? 'update' : 'add') . "',0);\n";
            print "//--></script>\n";
        } else {
            print "<script language=javascript><!--\n";
            print "   alert('Please enter both Section number and name.');\n";
            print "//--></script>\n";
        }
    };
    if ($@) {
        $message = errorMessage($dbh,$username,$userid,$schema,"$command.",$@);
        print doAlertBox( text => $message);
    }
}

if ($command eq 'delete1') {
    # process delete data -----------------------------------------------------------------------------------
    eval {
        my $ID = $crdcgi->param("crdsectionid");
        my $sectionnumber = $crdcgi->param("crdsectionnumber");
        my $sectionname = $crdcgi->param("crdsectionname");
        my $parent = $crdcgi->param("crdsectionparent");

        print deleteItem(dbh => $dbh, schema => $schema, item => {ID => $ID, section_number => $sectionnumber, section_name => $sectionname, parent => $parent});
        print "<script language=javascript><!--\n";
        print "   submitForm('$form','update',0);\n";
        print "//--></script>\n";
    };
    if ($@) {
        $message = errorMessage($dbh,$username,$userid,$schema,"$command.",$@);
        print doAlertBox( text => $message);
    }
}


#=============================================================================================================


db_disconnect($dbh);
print "</td></tr></table>\n";
print "</form>\n";
print "</center></font></body>\n</html>\n";
