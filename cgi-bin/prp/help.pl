#!/usr/local/bin/perl -w
#
# $Source: /data/dev/rcs/prp/perl/RCS/help.pl,v $
# $Revision: 1.1 $
# $Date: 2005/09/29 20:30:12 $
# $Author: naydenoa $
# $Locker:  $
#
# $Log: help.pl,v $
# Revision 1.1  2005/09/29 20:30:12  naydenoa
# Initial revision
#
#
#

$| = 1;

use strict;
use integer;
use SharedHeader qw(:Constants);
use DBShared qw(:Functions);
use UIShared qw(:Functions);
use UI_Widgets qw(:Functions);
use CGI;

$ENV{SCRIPT_NAME} =~ m%(.*/)(.*)\..*$%;
my $path = $1;
my $form = $2;

my $dbh;
$dbh = &db_connect();
my $mycgi = new CGI;
my %settings = getInitialValues(dbh => $dbh);

my $schema = $settings{schema};
my $command = $settings{command};
my $username = $settings{username};
my $userid = $settings{userid};
my $title = $settings{title};
my $error = "";
my $cgi = new CGI;
&checkLogin(cgi => $cgi);
my $errorstr = "";

######################
sub getInitialValues {  # routine to get initial CGI values and return in hash
######################
    my %args = (
        dbh => "",
        @_,
		);
    my %valueHash = (
       &getStandardValues, (
       approver => (defined ($mycgi -> param ("approver"))) ? $mycgi -> param ("approver") : "",
       approvername => (defined ($mycgi -> param ("approvername"))) ? $mycgi -> param ("approvername") : "",
       aqaprid => (defined ($mycgi -> param ("aqaprid"))) ? $mycgi -> param ("aqaprid") : 0,
       color => (defined ($mycgi -> param ("color"))) ? $mycgi -> param ("color") : 0,
       dateapproved => (defined ($mycgi -> param ("dateapproved"))) ? $mycgi -> param ("dateapproved") : "",
       dateapproved_day => (defined ($mycgi -> param ("dateapproved_day"))) ? $mycgi -> param ("dateapproved_day") : "",
       dateapproved_month => (defined ($mycgi -> param ("dateapproved_month"))) ? $mycgi -> param ("dateapproved_month") : "",
       dateapproved_year => (defined ($mycgi -> param ("dateapproved_year"))) ? $mycgi -> param ("dateapproved_year") : "",
       dateeffective => (defined ($mycgi -> param ("dateeffective"))) ? $mycgi -> param ("dateeffective") : "",
       dateeffective_day => (defined ($mycgi -> param ("dateeffective_day"))) ? $mycgi -> param ("dateeffective_day") : "",
       dateeffective_month => (defined ($mycgi -> param ("dateeffective_month"))) ? $mycgi -> param ("dateeffective_month") : "",
       dateeffective_year => (defined ($mycgi -> param ("dateeffective_year"))) ? $mycgi -> param ("dateeffective_year") : "",
       documentfile => (defined ($mycgi -> param ("documentfile"))) ? $mycgi -> param ("documentfile") : "",
       iscurrent => (defined ($mycgi -> param ("iscurrent"))) ? $mycgi -> param ("iscurrent") : "",
       isupdate => (defined ($mycgi -> param ("isupdate"))) ? $mycgi -> param ("isupdate") : 0,
       item => (defined ($mycgi -> param ("item"))) ? $mycgi -> param ("item") : "",
       justification => (defined ($mycgi -> param ("justification"))) ? $mycgi -> param ("justification") : "",
       nrcdescription => (defined ($mycgi -> param ("nrcdescription"))) ? $mycgi -> param ("nrcdescription") : "",
       nrcsource => (defined ($mycgi -> param ("nrcsource"))) ? $mycgi -> param ("nrcsource") : 0,
       parentsectionid => (defined ($mycgi -> param ("parentsectionid"))) ? $mycgi -> param ("parentsectionid") : "",
       position => (defined ($mycgi -> param ("position"))) ? $mycgi -> param ("position") : "",
       qardtocid => (defined ($mycgi -> param ("qardtocid"))) ? $mycgi -> param ("qardtocid") : "",
       qardtypeid => (defined ($mycgi -> param ("qardtypeid"))) ? $mycgi -> param ("qardtypeid") : 1,
       qrid => (defined ($mycgi -> param ("qrid"))) ? $mycgi -> param ("qrid") : 0,
       revid => (defined ($mycgi -> param ("revid"))) ? $mycgi -> param ("revid") : "",
       rid => (defined ($mycgi -> param ("rid"))) ? $mycgi -> param ("rid") : 0,
       rowid => (defined ($mycgi -> param ("rowid"))) ? $mycgi -> param ("rowid") : 0,
       sectionid => (defined ($mycgi -> param ("sectionid"))) ? $mycgi->param ("sectionid") : "",
       sectionstatusid => (defined ($mycgi -> param ("sectionstatusid"))) ? $mycgi -> param ("sectionstatusid") : "",
       sectiontext => (defined ($mycgi -> param ("sectiontext"))) ? $mycgi -> param ("sectiontext") : "",
       sectiontitle => (defined ($mycgi -> param ("sectiontitle"))) ? $mycgi -> param ("sectiontitle") : "",
       shortsectionid => (defined ($mycgi -> param ("shortsectionid"))) ? $mycgi -> param ("shortsectionid") : "",
       sid => (defined ($mycgi -> param ("sid"))) ? $mycgi -> param ("sid") : "",
       standarddescription => (defined ($mycgi -> param ("standarddescription"))) ? $mycgi -> param ("standarddescription") : "",
       status => (defined ($mycgi -> param ("status"))) ? $mycgi -> param ("status") : "",
       subid => (defined ($mycgi -> param ("subid"))) ? $mycgi -> param ("subid") : 0,
       tid => (defined ($mycgi -> param ("tid"))) ? $mycgi -> param ("tid") : 0,
       tocid => (defined ($mycgi -> param ("tocid"))) ? $mycgi -> param ("tocid") : "",
       toctitle => (defined ($mycgi -> param ("toctitle"))) ? $mycgi -> param ("toctitle") : "",
       what => (defined ($mycgi -> param ("what"))) ? $mycgi -> param ("what") : 0,
       istoc => (defined ($mycgi -> param ("istoc"))) ? $mycgi -> param ("istoc") : "F",
    ));
    $valueHash{title} = "Help!";

    return (%valueHash);
}

##############
sub doHeader {  # routine to generate html page headers
##############
    my %args = (
        dbh => '',
		schema => $ENV{SCHEMA},
        title => "$SYSType User Functions",
        displayTitle => 'T',
        width => 750,
        @_,
		);
    my $outstr = "";
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

    $outstr .= &doStandardHeader(dbh => $args{dbh}, schema => $args{schema}, title => $args{title}, displayTitle => $args{displayTitle},
              settings => \%settings, form => $form, path => $path, extraJS => $extraJS, includeJSUtilities => 'T', includeJSWidgets => 'T');

    $outstr .= "<input type=hidden name=type value=0>\n";
#    $outstr .= "<input type=hidden name=rid value=>\n";
    $outstr .= "<table border=0 width=$args{width} align=center><tr><td>\n";

    return($outstr);
}
##############
sub doFooter {  # routine to generate html page footers
##############
    my %args = (
        @_,
		);
    my $outstr = "";
    $outstr .= &doStandardFooter();
    return($outstr);
}



#! test for invalid or timed out session
&validateCurrentSession(dbh => $dbh, schema => $schema, userID => $userid, sessionID => $settings{sessionID});

#print &doHeader(dbh => $dbh, displayTitle => 'F', settings => \%settings, form => $form, path => $path);
eval {
    my ($mimetype, $image) = &getSingleRow (dbh => $dbh, schema => $schema, table => "manual", what => "imagecontenttype, document");
    my $outstr = "Content-type: $mimetype\n\n";
    $outstr .= $image;
    print $outstr;
};
if ($@) {
    print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Run Stuff Command in $form", $@));
}
#print &doFooter;


&db_disconnect($dbh);
exit();



