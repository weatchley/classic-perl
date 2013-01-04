#!/usr/local/bin/perl -w

# check characters
#
# $Source: /data/dev/rcs/plaqads/perl/RCS/characterCheckFix.pl,v $
#
# $Revision: 1.1 $
#
# $Date: 2004/08/10 15:26:31 $
#
# $Author: atchleyb $
#
# $Locker:  $
#
# $Log: characterCheckFix.pl,v $
# Revision 1.1  2004/08/10 15:26:31  atchleyb
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
use UI_Widgets qw(:Functions);
use UIShared qw(:Functions);
use DBD::Oracle qw(:ora_types);
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
   my $title = "Migrate Update - Check/Fix Characters";
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
sub getIDList {  # routine to create character map
###################################################################################################################################
    my %args = (
        @_,
    );
    my @list;
    my $i=0;
    my $sqlcode = "SELECT id, version FROM $args{schema}.extraction_versions";
    my $csr = $args{dbh}->prepare($sqlcode);
    $csr->execute;
    while (($list[$i][0], $list[$i][1]) = $csr->fetchrow_array) {
        $i++;
    }
    $csr->finish;
    
    return(@list);
}


###################################################################################################################################
sub setMapHash {  # routine to create character map hash
###################################################################################################################################
    my %args = (
        @_,
    );
    my %map;
    
    $map{1} = "*"; # bullet
    $map{19} = "-"; # long dash
    $map{20} = "-"; # long dash
    $map{24} = "'"; # apostrophe
    $map{25} = "'"; # apostrophe
    $map{28} = "\""; # double quote
    $map{29} = "\""; # double quote

    return(%map);
}




###################################################################################################################################
#
    print &doHeader(dbh => $dbh, title => $title, settings => \%settings, form => $form, path => $path);
    eval {
        print "<h1 align=center>Check/Fix Characters</h1>\n";
        print "<h2 align=center>Working</h2>\n";
        print "<h3 align=center>Using schema: $schema</h3>\n";
        
        $| = 1;
        my %charCounts;
        
        $dbh->{LongReadLen} = 100000000;
        $dbh->{LongTruncOk} = 0;
        
        my @idList = getIDList(dbh=>$dbh, schema=>$schema);
        my %mapHash = setMapHash;

        for (my $j=0; $j<$#idList; $j++) {
            my $sqlcode = "SELECT id, version, text FROM $schema.extraction_versions WHERE id=$idList[$j][0] AND version=$idList[$j][1]";
            my ($id, $version, $text) = $dbh->selectrow_array($sqlcode);
            my $found = 'F';
            for (my $i=0; $i<length($text); $i++) {
                my $c = substr($text, $i, 1);
                $charCounts{$c}[0] = ((defined($charCounts{$c}[0])) ? $charCounts{$c}[0] + 1 : 1);
                $charCounts{$c}[1][$id] = 1;
                if (defined($mapHash{ord($c)})) {$found = 'T';}
            }
            if ($found eq 'T') {
                foreach my $key2 (keys %mapHash) {
                    my $c = chr($key2);
                    $text =~ s/$c/$mapHash{$key2}/g;
                }
                my $sqlcode2 = "UPDATE $schema.extraction_versions SET text=:text WHERE id = $id AND version=$version";
                my $csr2 = $dbh->prepare($sqlcode2);
                $csr2 -> bind_param (":text", $text, {ora_type => ORA_CLOB, ora_field => 'text'});
                $csr2->execute;
            }
        }
        
        print "<table border=0>\n";
        foreach my $key (sort keys %charCounts) {
            print "<tr><td valign=top>\"$key\"</td><td valign=top> - &nbsp;</td><td valign=top>" . ord($key);
            print "</td><td valign=top> - &nbsp;</td><td valign=top>$charCounts{$key}[0]";
            my $test = ord($key);
            if (($test < 32 && $test > 18) || $test == 1) {
                print "<br>";
                my $arrayRef = $charCounts{$key}[1];
                my @ids = @$arrayRef;
                for (my $i=0; $i<$#ids; $i++) {
                    if (defined($ids[$i])) {print "$i, ";}
                }
            }
            print "</td><tr>\n";
        }
        print "</table>\n";

        print "<br><br>\n";
        print "<br><h2 align=center>Done</h2>\n";
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, 0, $schema, "Character check in $form", $@));
    }
    print &doFooter;


&db_disconnect($dbh);
exit();
