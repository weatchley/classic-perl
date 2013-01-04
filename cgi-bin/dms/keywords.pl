#!/usr/local/bin/perl -w
#
# $Source: /data/dev/rcs/dms/perl/RCS/keywords.pl,v $
#
# $Revision: 1.3 $
#
# $Date: 2002/07/08 18:05:10 $
#
# $Author: atchleyb $
#
# $Locker:  $
#
# $Log: keywords.pl,v $
# Revision 1.3  2002/07/08 18:05:10  atchleyb
# updated to display a message when a new keyword is added
#
# Revision 1.2  2002/03/15 17:05:47  atchleyb
# fixed bugs related to rewrite from CRD sections script
#
# Revision 1.1  2002/03/13 17:46:52  atchleyb
# Initial revision
#
#
#
#

use integer;
use strict;
use DMS_Header qw(:Constants);
use UI_Widgets qw(:Functions);
use DB_Utilities_Lib qw(:Functions);
use DBI;
use DBD::Oracle qw(:ora_types);
use CGI qw(param);
use Tie::IxHash;

$| = 1;

my $dmscgi = new CGI;
my $userid = $dmscgi->param("userid");
my $username = $dmscgi->param("username");
my $schema = $dmscgi->param("schema");

&checkLogin ($username, $userid, $schema);

$ENV{SCRIPT_NAME} =~ m%(.*/)(.*)\..*$%;
my $path = $1;
my $form = $2;

my $command = $dmscgi->param("command");
my $dbh = db_connect();
#my $dbh = db_connect(server =>'ydoradev');

#$dbh->{LongTruncOk} = 1;   # specify whether to fetch whole text or truncated fraction 
#$dbh->{LongReadLen} = 10000000;


###################################################################################################################################
sub getTitle {
###################################################################################################################################
   my %args = (
      @_,
   );
   my $title = "";
   if (($args{command} eq "browse") || ($args{command} eq "browseTable")) {
      $title = "Browse Keywords";
   } elsif (($args{command} eq "update") || ($args{command} eq 'update1') || ($args{command} eq 'update2')) {
      $title = "Update Keywords";
   } elsif ($args{command} eq "add" || ($args{command} eq 'add2')) {
      $title = "Add Keywords";
   } elsif ($args{command} eq "delete" || ($args{command} eq 'delete1')) {
      $title = "Delete Keywords";
   }
   return ($title);
}

###################################################################################################################################
sub buildForm {                                                                                                                   #
###################################################################################################################################
    my %args = (
        formType => 'New',
        item => {ID => 0, keyword_name => '', parent => 0},
        @_,
    );
    my $outputstring = '';
    
    $outputstring .= "<input type=hidden name=dmskeywordid value=$args{item}{ID}>\n";
    $outputstring .= "<table border=0 align=center>\n";
    $outputstring .= "<tr><td valign=bottom><b>Keyword: &nbsp; </b><input type=text size=60 maxlength=100 name=dmskeywordname value=\"$args{item}{keyword_name}\"> &nbsp; </td></tr>\n";
    $outputstring .= "<tr><td align=center><br><input type=button name=dmskeywordsubmit value=Submit onClick=\"if(process_$form(document.$form)) {submitFormCGIResults('$form','". (($args{formType} eq 'Update') ? 'update2' : 'add2') . "',0);}\"><br>&nbsp;</td></tr>\n";
    $outputstring .= "</table>\n";
    if ($args{formType} ne 'New') {
    #    $outputstring .= "<br><input type=button name=deleteButton value=Delete onClick=\"doDelete($args{item}{ID});\"><br>&nbsp;\n";
    #    $outputstring .= "</select></tr>\n";
    #    $outputstring .= "<script language=javascript><!-- \n";
    #    $outputstring .= "function doDelete (ID) {\n";
    #    $outputstring .= "    if (confirm('Do you wish to delete keyword $args{item}{keyword_name}')) {\n";
    #    $outputstring .= "        submitFormCGIResults('$form', 'delete1',0);\n";
    #    $outputstring .= "    } else {\n";
    #    $outputstring .= "        alert('Not Deleted');\n";
    #    $outputstring .= "    }\n";
    #    $outputstring .= "}\n";
    #    $outputstring .= "//-->\n";
    #    $outputstring .= "</script>\n";
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
    my $colspan = (($args{update} eq 'T') ? "2" : "1");
    my $parent;
    
    $outputstring .= "<table border=1 cellpadding=4 cellspacing=0>\n";
    $outputstring .= "<tr bgcolor=#c0ffff><td colspan=$colspan><b>Keywords (" . ($#itemList + 1) . ")</b></td></tr>\n";
    $outputstring .= "<tr bgcolor=#f0f0f0>" . (($args{update} eq 'T') ? "<td><font size=-1>&nbsp;</font></td>" : "") . "<td valign=bottom><font size=-1><b>Keyword</b></font></td></tr>\n";
    $outputstring .= "<tr><td colspan=$colspan height=4></td></tr>\n";
    
    if ($#itemList >= 0) {
        for (my $i=0; $i<= $#itemList;$i++) {
            $outputstring .= "<tr bgcolor=#ffffff>" . (($args{update} eq 'T') ? "<td align=center><font size=-1><a href=\"javascript:submitForm('$form','update1',$itemList[$i]{ID})\"><b>Edit</b></a></font></td>" : "") . "<td><font size=-1><b>$itemList[$i]{keyword_name}</b></font></td>";
            $outputstring .= "</tr>\n";
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
    my @values = $args{dbh}->selectrow_array("select keywordid, keyword from $args{schema}.keywords WHERE keywordid = $args{ID}");
    %item = (ID => $values[0], keyword_name => $values[1]);
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
    my $sqlcode = "SELECT keywordid, keyword FROM $args{schema}.keywords ORDER BY keyword";
    my $lookup = $args{dbh}->prepare($sqlcode);
    #print "\n<!-- $sqlcode -->\n\n";
    $lookup->execute;
    while (my @values = $lookup->fetchrow_array) {
        $itemList[$counter] = {ID => $values[0], keyword_name => $values[1]};
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
    
    $args{item}{keyword_name} =~ s/'/''/g;
    
    if ($args{item}{ID} == 0) {
        $sqlcode = "INSERT INTO $args{schema}.keywords (keywordid, keyword) VALUES ($schema.keywords_id.NEXTVAL,'$args{item}{keyword_name}')";
        log_activity($args{dbh}, $args{schema}, $userid, "Insert new DMS keyword #$args{item}{keyword_name}");
    } else {
        $sqlcode = "UPDATE $args{schema}.keywords SET keyword='$args{item}{keyword_name}' WHERE keywordid=$args{item}{ID}";
        log_activity($args{dbh}, $args{schema}, $userid, "Update DMS keyword #$args{item}{keyword_name} (ID #$args{item}{ID})");
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
        $sqlcode = "DELETE FROM $args{schema}.keywords WHERE keywordid=$args{item}{ID}";
        my $status = $args{dbh}->do($sqlcode);
        log_activity($args{dbh}, $args{schema}, $userid, "Delete DMS keyword #$args{item}{keyword_name} (ID #$args{item}{ID})");
    }
    
    
    return($outputstring);
}

###################################################################################################################################
    
print $dmscgi->header('text/html');
print <<END_of_1;
<html>
<head>
<meta http-equiv=expires content='31 Dec 1997'>
<script src=$DMSJavaScriptPath/utilities.js></script>
<script src=$DMSJavaScriptPath/widgets.js></script>
<script language=javascript><!--

function process_$form (f) {
     var msg = "";
     if (f.command.value == 'update1' || f.command.value == 'add') {
         if (isblank(f.dmskeywordname.value)) {
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

<body background=$DMSImagePath/background.gif text=$DMSFontColor link=#0000ff vlink=#0000ff alink=#0000ff topmargin=0 leftmargin=0>
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
        $message = errorMessage($dbh,$username,$userid,$schema,"browse DMS keywords.",$@);
        print doAlertBox( text => $message);
    }
}

if ($command eq 'browse') {
    eval {
        print buildDisplayTable(dbh => $dbh, schema => $schema);
    };
    if ($@) {
        $message = errorMessage($dbh,$username,$userid,$schema,"browse DMS keywords.",$@);
        print doAlertBox( text => $message);
    }
}

if ($command eq 'update') {
    # get data for update -----------------------------------------------------------------------------------
    eval {
        print buildDisplayTable(dbh => $dbh, schema => $schema, update => 'T');
    };
    if ($@) {
        $message = errorMessage($dbh,$username,$userid,$schema,"load DMS Sections for update.",$@);
        print doAlertBox( text => $message);
    }
    
}

if ($command eq 'update1' || $command eq 'add') {
    # display update data in main screen -----------------------------------------------------------------------------------
    eval {
        my %item;
        my $saveType = (($command eq 'update1') ? 'Update' : 'New');
        if ($command eq 'update1') {
            %item = getItem(dbh => $dbh, schema => $schema, ID => $dmscgi->param("id"));
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
        my $ID = $dmscgi->param("dmskeywordid");
        my $keywordname = $dmscgi->param("dmskeywordname");
        my $saveType = (($command eq 'update2') ? 'Update' : 'New');
            print "\n<!-- command = $command, saveType = $saveType -->\n\n";
        
        if (defined($keywordname) && $keywordname gt '             ') {
            print saveItem(dbh => $dbh, schema => $schema, formType => "$saveType", item => {ID => $ID, keyword_name => $keywordname});
            print "\n<!-- command = $command, saveType = $saveType -->\n\n";
            print "<script language=javascript><!--\n";
            if ($saveType eq 'New') {
                my $tempVal = $keywordname;
                $tempVal =~ s/'/\\'/g;
                print "    alert('Keyword: \"", $tempVal, "\", added');\n";
            }
            print "   submitForm('$form','" . (($saveType eq 'Update') ? 'update' : 'add') . "',0);\n";
            print "//--></script>\n";
        } else {
            print "<script language=javascript><!--\n";
            print "   alert('Please enter name.');\n";
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
        my $ID = $dmscgi->param("dmskeywordid");
        my $keywordname = $dmscgi->param("dmskeywordname");

        print deleteItem(dbh => $dbh, schema => $schema, item => {ID => $ID, keyword_name => $keywordname});
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
