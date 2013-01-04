#!/usr/local/bin/newperl -w
#
# $Source: /data/dev/rcs/crd/perl/RCS/addressee.pl,v $
#
# $Revision: 1.6 $
#
# $Date: 2002/02/20 16:29:47 $
#
# $Author: atchleyb $
#
# $Locker:  $
#
# $Log: addressee.pl,v $
# Revision 1.6  2002/02/20 16:29:47  atchleyb
# removed depricated function use named parameters and changed the html header
#
# Revision 1.5  2001/11/02 22:32:00  atchleyb
# changed javascript submit functions to not reset values after submition
# changed alert box code to handle single quotes
#
# Revision 1.4  2001/06/28 20:21:46  atchleyb
# added activity logging for addressee add and update
#
# Revision 1.3  2001/03/30 17:42:56  atchleyb
# added message in browse/update to display if no items found
#
# Revision 1.2  2001/03/29 17:03:42  atchleyb
# changed titles to match old format
#
# Revision 1.1  2001/03/13 00:29:43  atchleyb
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
      $title = "browse_addressee";
   } elsif (($args{command} eq "update") || ($args{command} eq 'update1') || ($args{command} eq 'update2')) {
      $title = "update_addressee";
   } elsif ($args{command} eq "add" || ($args{command} eq 'add2')) {
      $title = "add_addressee";
   }
   return ($title);
}

###################################################################################################################################
sub buildForm {                                                                                                                   #
###################################################################################################################################
    my %args = (
        formType => 'New',
        item => {ID => 0, name => '', grouporder => 2},
        @_,
    );
    my $outputstring = '';
    
    $outputstring .= "<input type=hidden name=addresseeid value=$args{item}{ID}>\n";
    $outputstring .= "<table border=0 align=center>\n";
    $outputstring .= "<tr>" . (($args{formType} eq 'Update') ? "<td valign=bottom><b>ID: $args{item}{ID} &nbsp; </b></td>" : "") . "<td valign=bottom><b>Name: &nbsp; </b><input type=text size=25 maxlength=75 name=addresseename value=\"$args{item}{name}\"> &nbsp; </td>\n";
    $outputstring .= "<td valign=bottom><b>Order: &nbsp; </b><select name=addresseegrouporder><option value=1>1<option value=2>2<option value=3>3</select>\n";
    $outputstring .= "<script language=javascript><!-- \n";
    $outputstring .= "set_selected_option(document.$form.addresseegrouporder, $args{item}{grouporder});\n";
    $outputstring .= "//-->\n";
    $outputstring .= "</script>\n";
    $outputstring .= "</td></tr>\n";
    $outputstring .= "<tr><td colspan=" . (($args{formType} eq 'Update') ? "3" : 2) . " align=center><br><input type=button name=addresseesubmit value=Submit onClick=\"if(process_$form(document.$form)) {submitFormCGIResults('$form','". (($args{formType} eq 'Update') ? 'update2' : 'add2') . "',0);}\">\n";
    
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
    my $colspan = (($args{update} eq 'T') ? "4" : "3");
    
    $outputstring .= "<table border=1>\n";
    $outputstring .= "<tr bgcolor=#f0f0f0>" . (($args{update} eq 'T') ? "<td>&nbsp;</td>" : "") . "<td align=center>ID</td><td>Name</td><td align=center>Order</td></tr>\n";
    $outputstring .= "<tr><td colspan=$colspan height=4></td></tr>\n";
    
    if ($#itemList >= 0) {
        for (my $i=0; $i<= $#itemList;$i++) {
            $outputstring .= "<tr bgcolor=#ffffff>" . (($args{update} eq 'T') ? "<td align=center><a href=\"javascript:submitForm('$form','update1',$itemList[$i]{ID})\">Edit</a></td>" : "") . "<td align=center>$itemList[$i]{ID}</td><td>$itemList[$i]{name}</td><td align=center>$itemList[$i]{grouporder}</td></tr>\n";
        }
    } else {
        $outputstring .= "<tr bgcolor=#ffffff><td align=center colspan=$colspan><b>No Items Found</b></td></tr>\n";
    }
    
    $outputstring .= "</table>\n";
    
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
    my @values = $args{dbh}->selectrow_array("select id, name, grouporder from $args{schema}.addressee WHERE id = $args{ID}");
    %item = (ID => $values[0], name => $values[1], grouporder => $values[2]);
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
    my $lookup = $args{dbh}->prepare("select id, name, grouporder from $args{schema}.addressee ORDER BY grouporder,name");
    $lookup->execute;
    while (my @values = $lookup->fetchrow_array) {
        $itemList[$counter] = {ID => $values[0], name => $values[1], grouporder => $values[2]};
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
        userid => '',
        #item => {ID => 0, name => '', grouporder => 2},
        @_,
    );
    my $outputstring = '';
    my $sqlcode = '';
    
    if ($args{item}{ID} == 0) {
        $sqlcode = "INSERT INTO $args{schema}.addressee (id,name,grouporder) VALUES ($schema.addressee_id.NEXTVAL,'$args{item}{name}',$args{item}{grouporder})";
        log_activity($args{dbh},$args{schema},$args{userid}, "Added Addressee - $args{item}{name}.");
    } else {
        $sqlcode = "UPDATE $args{schema}.addressee SET name='$args{item}{name}', grouporder=$args{item}{grouporder} WHERE id=$args{item}{ID}";
        log_activity($args{dbh},$args{schema},$args{userid}, "Updated Addressee - $args{item}{name} (ID #$args{item}{ID}).");
    }
    my $status = $args{dbh}->do($sqlcode);
    my @rows = $args{dbh}->selectrow_array("SELECT count(*) FROM $args{schema}.addressee WHERE grouporder = 1");
    if ($rows[0] < 1) {
        $outputstring .= "<script language=javascript><!--\n";
        $outputstring .= "   alert(\"Warning! No Addressee's have been set to a grouporder of 1.\");\n";
        $outputstring .= "//--></script>\n";
    } elsif ($rows[0] > 1) {
        $outputstring .= "<script language=javascript><!--\n";
        $outputstring .= "   alert(\"Warning! $rows[0] Addressee's have been set to a grouporder of 1.\\nYou should only have one at a grouporder of 1\");\n";
        $outputstring .= "//--></script>\n";
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
         if (isblank(f.addresseename.value)) {
             msg = "Please Enter Addressee Name.\\n";
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
        $message = errorMessage($dbh,$username,$userid,$schema,"browse addressee.",$@);
        print doAlertBox( text => $message);
    }
}

if ($command eq 'browse') {
    eval {
        print buildDisplayTable(dbh => $dbh, schema => $schema);
    };
    if ($@) {
        $message = errorMessage($dbh,$username,$userid,$schema,"browse addressee.",$@);
        print doAlertBox( text => $message);
    }
}

if ($command eq 'update') {
    # get data for update -----------------------------------------------------------------------------------
    eval {
        print buildDisplayTable(dbh => $dbh, schema => $schema, update => 'T');
    };
    if ($@) {
        $message = errorMessage($dbh,$username,$userid,$schema,"load addressee \$addressee for update.",$@);
        print doAlertBox( text => $message);
    }
    
}

if ($command eq 'update1' || $command eq 'add') {
    # display update data in main screen -----------------------------------------------------------------------------------
    eval {
        my %item;
        my $saveType = (($command eq 'update2') ? 'Update' : 'New');
        if ($command eq 'update1') {
            %item = getItem(dbh => $dbh, schema => $schema, ID => $crdcgi->param("id"));
            print buildForm(dbh => $dbh, schema => $schema, formType => '$saveType', item => \%item);
        } else {
            print buildForm(dbh => $dbh, schema => $schema, formType => '$saveType');
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
        my $ID = $crdcgi->param("addresseeid");
        my $name = $crdcgi->param("addresseename");
        my $grouporder = $crdcgi->param("addresseegrouporder");
        my $saveType = (($command eq 'update2') ? 'Update' : 'New');
        
        if (defined($name) && $name gt '             ') {
            print saveItem(dbh => $dbh, schema => $schema, userid => $userid, formType => '$saveType', item => {ID => $ID, name => $name, grouporder => $grouporder});
            print "<script language=javascript><!--\n";
            print "   submitForm('$form','update',0);\n";
            print "//--></script>\n";
        } else {
            print "<script language=javascript><!--\n";
            print "   alert('Please enter Addressee name.');\n";
            print "//--></script>\n";
        }
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
