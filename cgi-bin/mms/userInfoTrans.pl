#!/usr/local/bin/perl -w

# User Info Trans
#
# $Source: /data/dev/rcs/mms/perl/RCS/userInfoTrans.pl,v $
#
# $Revision: 1.1 $
#
# $Date: 2004/12/07 19:01:55 $
#
# $Author: atchleyb $
#
# $Locker:  $
#
# $Log: userInfoTrans.pl,v $
# Revision 1.1  2004/12/07 19:01:55  atchleyb
# Initial revision
#
#
#
#
#
#

$| = 1;

use strict;
#use integer;
use SharedHeader qw(:Constants);
use DBShared qw(:Functions);
use DBPurchaseDocuments qw(:Functions);
use UI_Widgets qw(:Functions);
use UIShared qw(:Functions);
use CGI;

my $mycgi = new CGI;


$ENV{SCRIPT_NAME} =~ m%(.*/)(.*)\..*$%;
my $path = $1;
my $form = $2;

my $dbh;
$dbh = &db_connect();
my %settings = getInitialValues(dbh => $dbh);

my $schema = $settings{schema};
my $command = $settings{command};
my $username = $settings{username};
my $userid = $settings{userid};
my $title = $settings{title};
my $error = "";
#&checkLogin(cgi => $cgi);
#&checkLogin ($username, $userid, $schema);
my $errorstr = "";

#! test for invalid or timed out session
#&validateCurrentSession(dbh => $dbh, schema => $schema, userID => $userid, sessionID => $settings{sessionID});


###################################################################################################################################
###################################################################################################################################


###################################################################################################################################
sub getTitle {
###################################################################################################################################
   my %args = (
      @_,
   );
   my $title = "User Info Trans";
   if ($args{command} eq "view_errors") {
      $title = "Error Log";
   } elsif ($args{command} eq "view_activity") {
      $title = "Activity Log";
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
       type => (defined($mycgi->param("type"))) ? $mycgi->param("type") : "",
       projectID => (defined($mycgi->param("projectID"))) ? $mycgi->param("projectID") : "",
       logOption => (defined($mycgi->param("logOption"))) ? $mycgi->param("logOption") : "today",
       logactivity => (defined($mycgi->param("logactivity"))) ? $mycgi->param("logactivity") : "all",
       selecteduser => (defined($mycgi->param("selecteduser"))) ? $mycgi -> param ("selecteduser") : -1,
       schemain => (defined($mycgi->param("schemain"))) ? $mycgi->param("schemain") : "",
       schemaout => (defined($mycgi->param("schemaout"))) ? $mycgi->param("schemaout") : "",
    ));
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
    function doBrowse(script) {
      	$form.command.value = 'browse';
       	$form.action = '$path' + script + '.pl';
        $form.submit();
    }
    function submitForm3(script, command, type) {
        document.$form.command.value = command;
        document.$form.type.value = type;
        document.$form.action = '$path' + script + '.pl';
        document.$form.target = 'main';
        document.$form.submit();
    }


END_OF_BLOCK
    $output .= &doStandardHeader(dbh => $args{dbh}, schema => $args{schema}, title => $args{title}, displayTitle => $args{displayTitle}, 
              settings => \%settings, form => $form, path => $path, extraJS => $extraJS, includeJSUtilities => 'F', includeJSWidgets => 'F');
    
    $output .= "<input type=hidden name=type value=0>\n";
    $output .= "<input type=hidden name=project value=0>\n";
    $output .= "<input type=hidden name=projectID value=0>\n";
    #$output .= "<input type=hidden name=server value=$Server>\n";
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
    
    $output .= &doStandardFooter();

    return($output);
}




###################################################################################################################################
#
    print &doHeader(dbh => $dbh, title => $title, settings => \%settings, form => $form, path => $path);
    eval {
        print "<h1 align=center>User Info Trans</h1>\n";
        print "<h2 align=center>Working</h2>\n";
        my $schemain = $settings{schemain};
        my $schemaout = $settings{schemaout};
        print "<h3 align=center>Using schema in: $schemain</h3>\n";
        print "<h3 align=center>Using schema out: $schemaout</h3>\n";
        
        my $dateFormat = "MM/DD/YYYY-HH24:MI:SS";
        my $sqlcode = "SELECT id,username,firstname,lastname,organization,location,areacode,phonenumber,extension,";
        $sqlcode .= "password,email,isactive,accesstype,TO_CHAR(datepasswordexpires,'MM/DD/YYYY'),failedattempts,lastfailure,lockout,oldpassword1,";
        $sqlcode .= "oldpassword2,oldpassword3,oldpassword4,oldpassword5,oldpassword6 FROM $schemain.users ";
        $sqlcode .= " ORDER BY id";
        my $csr = $dbh->prepare($sqlcode);
        $csr->execute;
        $| = 1;
        my $count = 0;

        while (my ($id,$username,$firstname,$lastname,$organization,$location,$areacode,$phonenumber,$extension,
              $password,$email,$isactive,$accesstype,$datepasswordexpires,$failedattempts,$lastfailure,$lockout,
              $oldpassword1,$oldpassword2,$oldpassword3,$oldpassword4,$oldpassword5,$oldpassword6) = $csr->fetchrow_array) {
            my $sqlcode2 = "UPDATE $schemaout.users SET password='$password',datepasswordexpires=TO_DATE('$datepasswordexpires','MM/DD/YYYY'),";
            $sqlcode2 .= "oldpassword1='$oldpassword1',oldpassword2='$oldpassword2',oldpassword3='$oldpassword3',oldpassword4='$oldpassword4',";
            $sqlcode2 .= "oldpassword5='$oldpassword5',oldpassword6='$oldpassword6' WHERE id = $id";
#print STDERR "\n$sqlcode2\n";
            
            $dbh->do($sqlcode2);
            $count++;
        }
        $csr->finish;
        $dbh->commit;

        print "<br><h2 align=center>$count records updated.</h2>\n";
        print "<br><h2 align=center>Done</h2>\n";
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, 0, $schema, "User Info Trans in $form", $@));
    }
    print &doFooter;


&db_disconnect($dbh);
exit();
