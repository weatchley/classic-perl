#!/usr/local/bin/newperl -w
#
# $Source: /usr/local/www/gov.ymp.intradev/rcs/crd/perl/RCS/final_crd.pl,v $
#
# $Revision: 1.46 $
#
# $Date: 2009/05/18 16:22:52 $
#
# $Author: atchleyb $
#
# $Locker:  $
#
# $Log: final_crd.pl,v $
# Revision 1.46  2009/05/18 16:22:52  atchleyb
# ACR0905_002 - Fixed Final CRD index issue
#
# Revision 1.45  2006/12/12 18:20:43  atchleyb
# updated for new environment
#
# Revision 1.44  2002/02/20 16:44:49  atchleyb
# removed depricated function use named parameters and changed the html header
#
# Revision 1.43  2002/02/05 22:37:06  atchleyb
# updated mapping for SR supplemental
#
# Revision 1.42  2002/02/05 00:21:15  atchleyb
# updated document mapping for SR
# removed redundant function call that made commentor index take longer.
#
# Revision 1.41  2002/02/01 23:44:09  atchleyb
# updated section mapping for SR supplimental section 20
#
# Revision 1.40  2002/01/11 22:20:39  atchleyb
# updated mapping for second SR comment period
#
# Revision 1.39  2001/12/21 01:09:08  atchleyb
# updated document to section mapping for SR
#
# Revision 1.38  2001/12/12 18:02:19  atchleyb
# updated document to section mappling
#
# Revision 1.37  2001/12/07 00:09:02  atchleyb
# added getDocumentList to handle mapping of documents to sections
# now using FinalCRDSectionSource from DocumentSpecific.pm to select source of data and some configuration
#
# Revision 1.36  2001/11/06 21:48:53  atchleyb
# fixed am pm problem with 12 in TOC and time run
#
# Revision 1.35  2001/11/02 23:38:10  atchleyb
# fixed misspelling in index page
#
# Revision 1.34  2001/11/02 18:42:54  atchleyb
# changed javascript submit functions to not reset values after submition
# changed alert box code to handle single quotes
# added new index to location by comment/scr number
#
# Revision 1.33  2001/10/25 22:07:10  atchleyb
# added new index
#
# Revision 1.32  2001/09/14 22:57:34  atchleyb
# replaced crd_id with uniqueid
# added code to insert uniqueid in records that don't have it
#
# Revision 1.31  2001/06/22 19:26:06  atchleyb
# added option to be able to run a report on only comments/responses, no scrs
#
# Revision 1.30  2001/06/21 21:43:10  atchleyb
# added code to alow for CRD ID numbers come come from the DB rathar then generating them
#
# Revision 1.29  2001/06/14 20:12:57  atchleyb
# removed hardcoded bin mapping and added code to get mapping from db
#
# Revision 1.28  2001/06/07 17:43:00  atchleyb
# bin-section mapping changed
#
# Revision 1.27  2001/05/24 20:14:05  atchleyb
# Made the commentor table at the top of each comment/SCR to be optional
# New mapping for DEIS
#
# Revision 1.26  2001/05/17 16:08:36  atchleyb
# modified to use &FirstReviewName from DocumentSpecific.pm instead of NEPA
#
# Revision 1.25  2001/05/16 21:01:07  atchleyb
# changed to use lastSubmittedText function (only makes a dif when the 'all' option is selected)
#
# Revision 1.24  2001/05/09 21:46:03  atchleyb
# changed text for title.htm file
#
# Revision 1.23  2001/05/08 22:18:49  atchleyb
# removed unneeded debug code
#
# Revision 1.22  2001/05/08 21:51:44  atchleyb
# changed date selection option to besince approved date
#
# Revision 1.21  2001/02/15 21:39:31  atchleyb
# changed display of run date/time
#
# Revision 1.20  2001/02/13 18:02:13  atchleyb
# changed the format of the destination folder to yyyy-mm-dd_hh-mm-ss
#
# Revision 1.19  2001/02/02 19:22:26  atchleyb
# made minor display change to the status page shown while the report is running
#
# Revision 1.18  2001/01/25 22:16:04  atchleyb
# fixed problem where too many spaces are converted into nonbreaking spaces in a row (caused formatting problems)
#
# Revision 1.17  2001/01/23 23:01:44  atchleyb
# Swapped order of comments/summary comments, SCR's are now first
#
# Revision 1.16  2001/01/23 22:43:54  atchleyb
# added option to generate a report of only SCR's
#
# Revision 1.15  2001/01/23 21:58:37  atchleyb
# removed approved test from summary comment responses
#
# Revision 1.14  2001/01/22 21:35:41  atchleyb
# fixed typo in chapter number
#
# Revision 1.13  2001/01/18 16:28:32  atchleyb
# removed debug code
#
# Revision 1.12  2001/01/17 22:41:14  atchleyb
# updated bin mapping
# added option to print comment/scr numbers
#
# Revision 1.11  2001/01/16 19:52:42  atchleyb
# updated font size on one of the commenter/document no's in the table above each comment
#
# Revision 1.10  2001/01/11 17:04:47  atchleyb
# updated the format of the toc page
#
# Revision 1.9  2001/01/10 22:36:58  atchleyb
# fixes formatting for chapter titles
#
# Revision 1.8  2001/01/10 20:51:15  atchleyb
# fixed selection page bug
#
# Revision 1.7  2001/01/10 20:47:26  atchleyb
# fixed alignment bug
#
# Revision 1.6  2001/01/10 19:20:43  atchleyb
# updated message on display while report is running
#
# Revision 1.5  2001/01/10 19:17:23  atchleyb
# changed title alignment
#
# Revision 1.4  2001/01/10 18:21:27  atchleyb
# updated bin mapping, changed font size for user table on comments, added option for only approved responses
#
# Revision 1.3  2000/12/07 23:41:37  atchleyb
# added code to handle multiple oracle servers
# Misc. changes
#
# Revision 1.2  2000/08/30 21:19:11  atchleyb
# Check point, all features are compleate, but the bin to chapter mapping needs work
#
# Revision 1.1  2000/06/08 23:54:54  atchleyb
# Initial revision
#
#
#
#
use integer;
use strict;
use CRD_Header qw(:Constants);
use UI_Widgets qw(:Functions);
use DB_Utilities_Lib qw(:Functions);
use DocumentSpecific qw(:Functions);
use Tie::IxHash;
use DBI;
use DBD::Oracle qw(:ora_types);
use CGI qw(param);
use Carp;

my $crdcgi = new CGI;
my $username = $crdcgi->param("username");
my $userid = $crdcgi->param("userid");
my $schema = $crdcgi->param("schema");
# Set server parameter
my $Server = $crdcgi->param("server");
if (!(defined($Server))) {$Server=$CRDServer;}

my $documentid = $crdcgi->param("id");
if (!(defined($documentid))) {$documentid='comment';}
my $command = $crdcgi->param("command");
if (!(defined($command))) {$command='menu';}
&checkLogin ($username, $userid, $schema);
$ENV{SCRIPT_NAME} =~ m%(.*/)(.*)\..*$%;
my $path = $1;
my $form = $2;
my $dbh;
my $errorstr = "";
my @chapters;
my $DisplayCommentNumbers = ((((defined($crdcgi->param("displaycommentnumber"))) ? $crdcgi->param("displaycommentnumber") : "F") eq "T") ? 1 : 0);

$| = 1;


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
sub getSectionTree {
###################################################################################################################################
    # generate a list of sections that have 'root_section' as a parent, the list is terminated with a 0
    my %args = (
        @_,
    );
    my $outputstring = '';
    
    my $sqlquery = "SELECT UNIQUE id FROM $args{'schema'}.crd_sections START WITH id = $args{'root_section'} CONNECT BY PRIOR id = parent";
    my $csr = $args{'dbh'}->prepare($sqlquery);
    my $status = $csr->execute;
    my @values;
    while (@values = $csr->fetchrow_array) {
        if ($values[0] != $args{root_section}) {
            $outputstring .= "$values[0],";
        }
    }
    $outputstring = "0," . $outputstring . "0";
    return ($outputstring);
    
}


###################################################################################################################################
sub getBinList {
###################################################################################################################################
    # generate a list of bins that are mapped to a section, the list is terminated with a 0
    my %args = (
        @_,
    );
    my $outputstring = '';
    
    my $sqlquery = "SELECT id FROM $args{'schema'}.bin WHERE crd_section = $args{'section'} ";
    my $csr = $args{'dbh'}->prepare($sqlquery);
    my $status = $csr->execute;
    my @values;
    while (@values = $csr->fetchrow_array) {
        $outputstring .= "$values[0],";
    }
    $outputstring = "0," . $outputstring . "0";
    return ($outputstring);
    
}


###################################################################################################################################
sub getDocumentList {
###################################################################################################################################
    # generate a list of documents that are mapped to a section, the list is terminated with a 0
    my %args = (
        section => 0,
        CRDPeriod => 1,
        @_,
    );
    my $outputstring = '';
    
    $args{CRDPeriod} = $args{CRDPeriod} + 1 - 1;
    
    if ($args{CRDPeriod} ==1) {
        if ($args{'section'} == 98) { # 1
            $outputstring .= "0";
        } elsif ($args{'section'} == 101) { # 2.1.1
            $outputstring .= "220016,0";
        } elsif ($args{'section'} == 103) { # 2.2.1
            $outputstring .= "220015,0";
        } elsif ($args{'section'} == 105) { # 2.3.1
            $outputstring .= "220007,220014,0";
        } elsif ($args{'section'} == 107) { # 2.4.1
            $outputstring .= "220001,220012,0";
        } elsif ($args{'section'} == 109) { # 2.5.1
            $outputstring .= "220004,220005,220011,0";
        } elsif ($args{'section'} == 110) { # 2.5.2
            $outputstring .= "220010,0";
        } elsif ($args{'section'} == 123) { # 2.5.3
            $outputstring .= "220009,220017,0";
        } elsif ($args{'section'} == 112) { # 2.6.1
            $outputstring .= "220013,0";
        } elsif ($args{'section'} == 114) { # 2.7.1
            $outputstring .= "220002,0";
        } elsif ($args{'section'} == 116) { # 2.8.1
            $outputstring .= "220008,0";
        } elsif ($args{'section'} == 118) { # 2.9.1
            $outputstring .= "220006,0";
        } elsif ($args{'section'} == 130) { # 2.10
            $outputstring .= "0";
        } elsif ($args{'section'} == 131) { # 2.10.1
            $outputstring .= "0";
        } elsif ($args{'section'} == 132) { # 2.11
            $outputstring .= "0";
        } elsif ($args{'section'} == 133) { # 2.11.1
            $outputstring .= "0";
        } elsif ($args{'section'} == 134) { # 2.12
            $outputstring .= "0";
        } elsif ($args{'section'} == 135) { # 2.12.1
            $outputstring .= "0";
        } elsif ($args{'section'} == 136) { # 2.13
            $outputstring .= "0";
        } elsif ($args{'section'} == 137) { # 2.13.1
            $outputstring .= "0";
        } elsif ($args{'section'} == 119) { # 3
            $outputstring .= "0";
        } elsif ($args{'section'} == 120) { # 3.1
            $outputstring .= "0";
        } elsif ($args{'section'} == 124) { # 3.1.1
            $outputstring .= "330032,0";
        } elsif ($args{'section'} == 125) { # 3.1.2
            $outputstring .= "330008,330064,330125,330007,330063,330113,330044,330006,330023,330024,330025,330033,330121,330067,330119,0";
        } elsif ($args{'section'} == 126) { # 3.1.3
            $outputstring .= "330028,0";
        } elsif ($args{'section'} == 121) { # 3.2
            $outputstring .= "0";
        } elsif ($args{'section'} == 127) { # 3.2.1
            $outputstring .= "330005,330004,330003,330012,330130,330133,0";
        } elsif ($args{'section'} == 128) { # 3.2.2
            $outputstring .= "330068,330118,330069,330117,330002,330009,330010,330091,330035,330020,330080,330055,330016,330014,330090,330131,330094,330017,330093,330114,330051,330057,330116,330087,330060,330056,330077,330065,330096,330120,330073,330085,330127,330126,330031,330045,330034,330083,330078,330038,330122,330047,330041,330123,330129,330128,0";
        } elsif ($args{'section'} == 129) { # 3.2.3
            $outputstring .= "330066,330072,330011,330061,330049,330050,330058,330079,330062,330048,330054,330115,330071,330050,0";
        } elsif ($args{'section'} == 122) { # 3.3
            $outputstring .= "330124,330076,330106,330109,330037,330111,330110,330092,330026,330108,330022,330029,330097,330112,330098,330105,330027,330101,330100,330070,330018,330099,330053,330104,330052,330043,330046,330132,330036,330103,330095,330042,330039,330019,330001,330013,330084,330102,330107,0";
        } elsif ($args{'section'} == 0) { # 0
            $outputstring .= "0";
        } else {
            $outputstring .= "0";
        }
    } elsif ($args{CRDPeriod} == 2) {
 print "\n<!-- Got to period 2 -->";
        if ($args{'section'} == 98) { # 1
            $outputstring .= "0";
        } elsif ($args{'section'} == 101) { # 2.1.1
            $outputstring .= "0";
        } elsif ($args{'section'} == 103) { # 2.2.1
            $outputstring .= "0";
        } elsif ($args{'section'} == 105) { # 2.3.1
            $outputstring .= "0";
        } elsif ($args{'section'} == 107) { # 2.4.1
            $outputstring .= "0";
        } elsif ($args{'section'} == 109) { # 2.5.1
            $outputstring .= "200001,0";
        } elsif ($args{'section'} == 110) { # 2.5.2
            $outputstring .= "0";
        } elsif ($args{'section'} == 123) { # 2.5.3
            $outputstring .= "0";
        } elsif ($args{'section'} == 112) { # 2.6.1
            $outputstring .= "0";
        } elsif ($args{'section'} == 114) { # 2.7.1
            $outputstring .= "0";
        } elsif ($args{'section'} == 116) { # 2.8.1
            $outputstring .= "0";
        } elsif ($args{'section'} == 118) { # 2.9.1
            $outputstring .= "0";
        } elsif ($args{'section'} == 130) { # 2.10
            $outputstring .= "0";
        } elsif ($args{'section'} == 131) { # 2.10.1
            $outputstring .= "200002,0";
        } elsif ($args{'section'} == 132) { # 2.11
            $outputstring .= "0";
        } elsif ($args{'section'} == 133) { # 2.11.1
            $outputstring .= "200005,0";
        } elsif ($args{'section'} == 134) { # 2.12
            $outputstring .= "0";
        } elsif ($args{'section'} == 135) { # 2.12.1
            $outputstring .= "200003,0";
        } elsif ($args{'section'} == 136) { # 2.13
            $outputstring .= "0";
        } elsif ($args{'section'} == 137) { # 2.13.1
            $outputstring .= "200004,0";
        } elsif ($args{'section'} == 119) { # 3
            $outputstring .= "0";
        } elsif ($args{'section'} == 120) { # 3.1
            $outputstring .= "0";
        } elsif ($args{'section'} == 124) { # 3.1.1
            $outputstring .= "0";
        } elsif ($args{'section'} == 125) { # 3.1.2
            $outputstring .= "300005,300011,0";
        } elsif ($args{'section'} == 126) { # 3.1.3
            $outputstring .= "0";
        } elsif ($args{'section'} == 121) { # 3.2
            $outputstring .= "0";
        } elsif ($args{'section'} == 127) { # 3.2.1
            $outputstring .= "300003,0";
        } elsif ($args{'section'} == 128) { # 3.2.2
            $outputstring .= "300006,300016,300017,300009,300008,300013,300014,300015,300019,0";
        } elsif ($args{'section'} == 129) { # 3.2.3
            $outputstring .= "300010,300007,0";
        } elsif ($args{'section'} == 122) { # 3.3
            $outputstring .= "300001,300004,300012,300002,0";
        } elsif ($args{'section'} == 0) { # 0
            $outputstring .= "0";
        } else {
            $outputstring .= "0";
        }
    } elsif ($args{CRDPeriod} == 0) {
        if ($args{'section'} == 98) { # 1
            $outputstring .= "0";
        } elsif ($args{'section'} == 101) { # 2.1.1
            $outputstring .= "220016,0";
        } elsif ($args{'section'} == 103) { # 2.2.1
            $outputstring .= "220015,0";
        } elsif ($args{'section'} == 105) { # 2.3.1
            $outputstring .= "220007,220014,0";
        } elsif ($args{'section'} == 107) { # 2.4.1
            $outputstring .= "220001,220012,0";
        } elsif ($args{'section'} == 109) { # 2.5.1
            $outputstring .= "220004,220005,220011,0";
            $outputstring .= ",200001,0";
        } elsif ($args{'section'} == 110) { # 2.5.2
            $outputstring .= "220010,0";
        } elsif ($args{'section'} == 123) { # 2.5.3
            $outputstring .= "220009,220017,0";
        } elsif ($args{'section'} == 112) { # 2.6.1
            $outputstring .= "220013,0";
        } elsif ($args{'section'} == 114) { # 2.7.1
            $outputstring .= "220002,0";
        } elsif ($args{'section'} == 116) { # 2.8.1
            $outputstring .= "220008,0";
        } elsif ($args{'section'} == 118) { # 2.9.1
            $outputstring .= "220006,0";
        } elsif ($args{'section'} == 130) { # 2.10
            $outputstring .= "0";
        } elsif ($args{'section'} == 131) { # 2.10.1
            $outputstring .= "200002,0";
        } elsif ($args{'section'} == 132) { # 2.11
            $outputstring .= "0";
        } elsif ($args{'section'} == 133) { # 2.11.1
            $outputstring .= "200005,0";
        } elsif ($args{'section'} == 134) { # 2.12
            $outputstring .= "0";
        } elsif ($args{'section'} == 135) { # 2.12.1
            $outputstring .= "200003,0";
        } elsif ($args{'section'} == 136) { # 2.13
            $outputstring .= "0";
        } elsif ($args{'section'} == 137) { # 2.13.1
            $outputstring .= "200004,0";
        } elsif ($args{'section'} == 119) { # 3
            $outputstring .= "0";
        } elsif ($args{'section'} == 120) { # 3.1
            $outputstring .= "0";
        } elsif ($args{'section'} == 124) { # 3.1.1
            $outputstring .= "330032,0";
        } elsif ($args{'section'} == 125) { # 3.1.2
            $outputstring .= "330008,330064,330125,330007,330063,330113,330044,330006,330023,330024,330025,330033,330121,330067,330119,0";
            $outputstring .= ",300005,300011,0";
        } elsif ($args{'section'} == 126) { # 3.1.3
            $outputstring .= "330028,0";
        } elsif ($args{'section'} == 121) { # 3.2
            $outputstring .= "0";
        } elsif ($args{'section'} == 127) { # 3.2.1
            $outputstring .= "330005,330004,330003,330012,330130,330133,0";
            $outputstring .= ",300003,0";
        } elsif ($args{'section'} == 128) { # 3.2.2
            $outputstring .= "330068,330118,330069,330117,330002,330009,330010,330091,330035,330020,330080,330055,330016,330014,330090,330131,330094,330017,330093,330114,330051,330057,330116,330087,330060,330056,330077,330065,330096,330120,330073,330085,330127,330126,330031,330045,330034,330083,330078,330038,330122,330047,330041,330123,330129,330128,0";
            $outputstring .= ",300006,300016,300017,300009,300008,300013,300014,300015,300019,0";
        } elsif ($args{'section'} == 129) { # 3.2.3
            $outputstring .= "330066,330072,330011,330061,330049,330050,330058,330079,330062,330048,330054,330115,330071,330050,0";
            $outputstring .= ",300010,300007,0";
        } elsif ($args{'section'} == 122) { # 3.3
            $outputstring .= "330124,330076,330106,330109,330037,330111,330110,330092,330026,330108,330022,330029,330097,330112,330098,330105,330027,330101,330100,330070,330018,330099,330053,330104,330052,330043,330046,330132,330036,330103,330095,330042,330039,330019,330001,330013,330084,330102,330107,0";
            $outputstring .= ",300001,300004,300012,300002,0";
        } elsif ($args{'section'} == 0) { # 0
            $outputstring .= "0";
        } else {
            $outputstring .= "0";
        }
    } else {
            $outputstring .= "0";
    }

print "\n<!-- CRDPeriod: $args{CRDPeriod}, Section: $args{'section'}, output: $outputstring -->\n";
    
    return ($outputstring);
    
}


###################################################################################################################################
sub buildChapters {
###################################################################################################################################
#
#### build chapter to bin table
#
    my %args = (
        @_,
    );
    my $rootSQL;
    my $rootcsr;
    my $rootID;
    my $rootNumber;
    my $rootName;
    my $leafSQL;
    my $leafcsr;
    my $leafID;
    my $leafNumber;
    my $leafName;
    my @values;
    my $status;
    my @chapters = ([]);
    my $chap = 0;
    my $index;
    
    $rootSQL = "SELECT id,section_number,section_name FROM $args{schema}.crd_sections WHERE parent IS NULL ORDER BY section_number";
    $rootcsr = $args{dbh}->prepare($rootSQL);
    $status = $rootcsr->execute;
    
    while (@values = $rootcsr->fetchrow_array) {
        ($rootID,$rootNumber,$rootName) = @values;
        $chap++;
        $chapters[$chap][0] = $rootName;
        $index = 0;
        $leafSQL = "SELECT id,section_number,section_name FROM $args{schema}.crd_sections WHERE id IN (" . getSectionTree(root_section=>$rootID,dbh=>$args{dbh},schema=>$args{schema}) . ") ORDER BY section_number";
#print "\n<!-- $rootID - $leafSQL -->\n\n";
        $leafcsr = $args{dbh}->prepare($leafSQL);
        $status = $leafcsr->execute;
        while (@values = $leafcsr->fetchrow_array) {
            ($leafID,$leafNumber,$leafName) = @values;
            $chapters[$chap][1][$index][0] = $leafNumber;
            $chapters[$chap][1][$index][1] = getBinList(dbh => $args{dbh}, schema => $args{schema}, section => $leafID);
            $chapters[$chap][1][$index][2] = $leafName;
            $chapters[$chap][1][$index][3] = $leafID;
            $index++;
        }
        $leafcsr->finish;
    }
    $rootcsr->finish;
    
    return (@chapters);
    
}


###################################################################################################################################
sub processError {
###################################################################################################################################
   my %args = (
      @_,
   );
   my $error = &errorMessage($dbh, $username, $userid, $schema, $args{activity}, $@);
   $error =  ('_' x 100) . "\n\n" . $error if ($errorstr ne "");
   $error =~ s/\n/\\n/g;
   $error =~ s/'/%27/g;
   $errorstr .= $error;
}


###################################################################################################################################
sub getReportDateTime {
###################################################################################################################################
    my @timedata = localtime(time);
    return(uc(get_date()) . " " . lpadzero($timedata[2],2) . ":" . lpadzero($timedata[1],2) . ":" . lpadzero($timedata[0],2));
}


###################################################################################################################################
sub getDuplicateDocuments {
###################################################################################################################################
    my %args = (
        @_,
    );
    my $outputstring = '';
    my $sqlquery;
    my $csr;
    my @values;
    my $status;
    
    $sqlquery = "SELECT id FROM $args{schema}.document WHERE dupsimstatus = 2 AND dupsimid = $args{id} ORDER BY id";
    $csr = $args{dbh}->prepare($sqlquery);
    $status = $csr->execute;
    while (@values = $csr->fetchrow_array) {
        $outputstring .= "<br>$CRDType" . lpadzero($values[0],6);
    }
    $csr->finish;
    
    return($outputstring);
}


###################################################################################################################################
sub getLocations {
###################################################################################################################################
    my %args = (
        @_,
    );
    my $outputstring = '';
    my $sqlquery;
    my $csr;
    my @values;
    my $status;
    my $isFirst = 'T';
    my $refvar = $args{locations};
    my %locations = %$refvar;
    my $loc;
    
    $sqlquery = "SELECT document,commentnum from $args{schema}.comments WHERE document = $args{document} ORDER by document,commentnum";
    $csr = $args{dbh}->prepare($sqlquery);
    $status = $csr->execute;
    while (@values = $csr->fetchrow_array) {
        $loc = lpadzero($values[0],6) . "-" . lpadzero($values[1],4);
        if (defined($locations{$loc})) {
            $outputstring .= (($isFirst eq 'T') ? '' : ', ');
            $isFirst = 'F';
            $outputstring .= $locations{$loc};
        }
    }
    $csr->finish;
    
    $outputstring =~ s/ \(/&nbsp;\(/g;
    
    return($outputstring);
}


###################################################################################################################################
sub getCommentor {
###################################################################################################################################
    my %args = (
        @_,
    );
    my $sqlquery;
    my $csr;
    my @values;
    my $status;
    
    $sqlquery = "SELECT doc.namestatus,cmtr.lastname,cmtr.firstname,cmtr.organization, cmtr.id ";
    $sqlquery .= "FROM $args{schema}.document doc,$args{schema}.commentor cmtr WHERE doc.commentor = cmtr.id(+) AND doc.id = $args{document}";
#print "\n<!-- 1 - $sqlquery -->\n\n";
    $csr = $args{dbh}->prepare($sqlquery);
    $status = $csr->execute;
    @values = $csr->fetchrow_array;
    #$values[1] = ((defined($values[1])) ? $values[1] : "");
    #$values[2] = ((defined($values[2])) ? $values[2] : "");
    #$values[3] = ((defined($values[3])) ? $values[3] : "");
    
    return (@values);
}


###################################################################################################################################
sub ReportSelectionPage {
###################################################################################################################################
    my %args = (
        @_,
    );
    my $outputstring = '';
    
    $outputstring .= "<center>\n";
    $outputstring .= "<table border=0 align=center>\n";
    $outputstring .= "<tr><td colspan=2 align=center><font size=+1><b>Report Selections</b></font></td></tr>\n";
    $outputstring .= "<tr><td><input type=radio name=finaltype value=all checked onClick=\"setEnabled($form.finaltype);\"></td><td>All <i>- This can take over an hour to run</i></td></tr>\n";
    $outputstring .= "<tr><td><input type=radio name=finaltype value=nepa onClick=\"setEnabled($form.finaltype);\"></td><td>Approved through " . &FirstReviewName . "</td></tr>\n";
    $outputstring .= "<tr><td><input type=radio name=finaltype value=bincoordinator onClick=\"setEnabled($form.finaltype);\"></td><td>Approved through Bin Coordinator</td></tr>\n";
    $outputstring .= "<tr><td><input type=radio name=finaltype value=approved onClick=\"setEnabled($form.finaltype);\"></td><td>Approved</td></tr>\n";
    $outputstring .= "<tr><td><input type=radio name=finaltype value=cronly onClick=\"setEnabled($form.finaltype);\"></td><td>Comments/Responses only</td></tr>\n";
    $outputstring .= "<tr><td><input type=radio name=finaltype value=scr onClick=\"setEnabled($form.finaltype);\"></td><td>SCR's only</td></tr>\n";
    $outputstring .= "<tr><td><input type=radio name=finaltype value=date onClick=\"setEnabled($form.finaltype);\"></td><td>Approved since: &nbsp;" . build_date_selection('startdate',$form,'today') . "</td></tr>\n";
    $outputstring .= "<tr><td><input type=checkbox name=showcommentnumber value='T'" . ((defined($crdcgi->param('showcommentnumber')) && $crdcgi->param('showcommentnumber') eq 'T') ? " checked" : "") . "></td><td>Show Comment/SCR Numbers</td></tr>\n";
    $outputstring .= "<tr><td><input type=checkbox name=showcommentors value='T'" . ((defined($crdcgi->param('showcommentors')) && $crdcgi->param('showcommentors') eq 'T') ? " checked" : "") . "></td><td>Show Commentor Tables</td></tr>\n";
    $outputstring .= "<tr><td><input type=radio name=crdidsource value='generate'></td><td>Generate CRD ID numbers</td></tr>\n";
    $outputstring .= "<tr><td><input type=radio name=crdidsource value='fetch' checked></td><td>Use CRD ID numbers from database</td></tr>\n";
    $outputstring .= "<tr><td></td><td>CRD Period: &nbsp; <select name=crdperiod size=1><option value=0 selected>All<option value=1>1<option value=2>2</select></td></tr>\n";
    if (defined($crdcgi->param('crdperiod'))) {
        $outputstring .= "<script language=JavaScript>\n";
        my $setval = $crdcgi->param('crdperiod');
        $outputstring .= "    set_selected_option(document.$form.crdperiod, $setval);\n";
        $outputstring .= "</script>\n";
    }
    $outputstring .= "<tr><td colspan=2 align=center><br><input type=button name=doreport value='Submit' onClick=\"checkFinalType();\">\n";
    $outputstring .= "</table>\n";
    $outputstring .= "</center>\n";
    $outputstring .= "<script language=JavaScript>\n";
    $outputstring .= "    function checkFinalType() {\n";
    $outputstring .= "        var errmsg = '';\n";
    $outputstring .= "        if ($form.finaltype[6].checked) {\n";
    $outputstring .= "            errmsg = validate_date($form.startdate_year.value, $form.startdate_month.value, $form.startdate_day.value, 0, 0, 0, 0, true, false, false);\n";
    $outputstring .= "        }\n";
    $outputstring .= "        if (errmsg == '') {\n";
    $outputstring .= "            submitForm('$form','finalreport',0);\n";
    $outputstring .= "        } else {\n";
    $outputstring .= "            alert(errmsg);\n";
    $outputstring .= "        }\n";
    $outputstring .= "    }\n";
    $outputstring .= "    function setEnabled(object) {\n";
    $outputstring .= "        var disabled = (object == 'all') ? false : eval(!object[6].checked);\n";
    $outputstring .= "        $form.startdate_month.disabled = disabled;\n";
    $outputstring .= "        $form.startdate_day.disabled = disabled;\n";
    $outputstring .= "        $form.startdate_year.disabled = disabled;\n";
    $outputstring .= "    }\n";
    $outputstring .= "    setEnabled($form.finaltype);\n";
    $outputstring .= "</script>\n";
    
    return($outputstring);
}


###################################################################################################################################
sub gen_report {
###################################################################################################################################
    my %args = (
        reportSelection => 'all',
        startDate => '',
        endDate=> '',
        showCommentors => 'F',
        CRDPeriod => 1,
#        crdidsource => 'generate',
        @_,
    );
    my $sqlquery = '';
    my $csr;
    my @values;
    my $sqlquery2 = '';
    my $csr2;
    my @values2;
    my $sqlquery3 = '';
    my $csr3;
    my @values3;
    my $status;
    my %locations;
    my @sectionLocations = ();
    my %indexLocation;
    my $message = '';
    my $outputstring = '';
    my $commentorBlock = '';
    my $column;
    my $loc;
    my $loc2;
    my $commentcount = 0;
    my $lastdoc = 0;
    my $lastdoc2 = 0;
    my @commentor;
    my @commentor2;
    my @commentor3;
    my $colcount=7;
    my $selection='';
    my $SCRSelection='';
    my $selectiontype = $crdcgi->param('selectedtype');
    my $selectiondate = $crdcgi->param('selecteddate');
    my $fontSize = 3;
    my $fontSize2 = 2;
    my $foldername = $args{'foldername'};
    my $PageStart = "<html>\n<head>\n<title>Final $CRDType Report</title>\n</head>\n\n<body background=$CRDImagePath/background.gif text=$CRDFontColor link=#0000ff vlink=#0000ff alink=#0000ff ";
    $PageStart .= "topmargin=0 leftmargin=0><center>\n<font face=$CRDFontFace color=$CRDFontColor>\n<font size=$fontSize>\n";
    my $PageEnd = "\n</center>\n</font></font></body>\n</html>\n";
    
    if ($selectiontype eq 'nepa') {
        $selection = " AND rv.status IN (8,9) ";
        $SCRSelection = "";
    } elsif ($selectiontype eq 'approved') {
        $selection = " AND rv.status IN (9) ";
        $SCRSelection = "";
    } elsif ($selectiontype eq 'bincoordinator') {
        $selection = " AND rv.status IN (7,8,9) ";
        $SCRSelection = "";
    } elsif ($selectiontype eq 'date') {
        #$selection = " AND TO_CHAR(rv.dateupdated,'YYYYMMDD') >= '$selectiondate' ";
        #$SCRSelection = " AND id IN (SELECT summarycomment from $args{schema}.summary_update WHERE TO_CHAR(updatedate,'YYYYMMDD') >= '$selectiondate') ";
        $selection = " AND TO_CHAR(rv.dateupdated,'YYYYMMDD') >= '$selectiondate' AND rv.status = 9 ";
        $SCRSelection = " AND 1=0 ";
    }
    print "\n<!-- Selectiontype: $selectiontype, Selection date: $selectiondate, Selection: $selection, SCRSelection: $SCRSelection -->\n\n";
    
    eval {
    
        $args{dbh}->do("UPDATE $args{schema}.summary_comment SET uniqueid=$args{schema}.crd_comment_scr_id.NEXTVAL WHERE uniqueid IS NULL");
        $args{dbh}->do("UPDATE $args{schema}.comments SET uniqueid=$args{schema}.crd_comment_scr_id.NEXTVAL WHERE uniqueid IS NULL");
        $args{dbh}->commit;
        
        $outputstring .= "<center><table border=0 width=670 align=center cellpadding=0 cellspacing=0>\n";
        #$outputstring .= "<tr><td align=center><font size=5>$CRDType Comment Response Document</font></td></tr>\n";
        #$outputstring .= "<tr><td><hr width=100%></td></tr>\n";
        if ($selectiontype eq 'date') {
            $outputstring .= "<tr><td align=center><font size=4>CRD Responses Approved on or after: " . uc(get_date(substr($selectiondate,4,2) . "/" . substr($selectiondate,6,2) . "/" . substr($selectiondate,0,4))) . "</font><br>&nbsp;</td></tr>";
        }
        $outputstring .= "<tr><td align=center><font size=4>CRD Run Started on $args{runstarttime}<br>\n";
        $outputstring .= "CRD Run Finished on <place end time here><br>&nbsp;</td></tr>\n";
        $outputstring .= "<tr><td><font size=4><ul>\n";
        $commentcount = 0;
    
        foreach my $chapternumber (1 .. $#chapters) {
            print "<!-- Keep Alive -- Chapter $chapternumber -->\n";
            if ($chapternumber > 1) {
                print FH1 $PageEnd;
                close FH1;
            }
            if (!(open (FH1, "| ./File_Utilities.pl --command=writeFile --fullFilePath=$CRDFullTempReportPath/final_crd/$foldername/ch" . lpadzero($chapternumber,2) . ".htm --protection=0777"))) {
                die "Unable to open file $CRDFullTempReportPath/$foldername/ch" . lpadzero($chapternumber,2) . ".htm\n";
            }
            $outputstring .= "<li><a href=\"ch" . lpadzero($chapternumber,2) . ".htm\">Section $chapternumber - $chapters[$chapternumber][0]</a><br><br></li>\n";
            print FH1 $PageStart;
            # chapter specific processing here
            print FH1 "<table border=0 width=670 align=center cellpadding=0 cellspacing=0><tr><td><center><font size=" . ($fontSize + 2) . "><b>$chapternumber. $chapters[$chapternumber][0]</b><br><br></font></center></td></tr></table>\n";
            my $aref = $chapters[$chapternumber][1];
            foreach my $subchapter (0 .. $#{$aref}) {
                # sub chapter specific processing here
                my ($CRDSource, $showCRDCommentors,$fromVal,$whereVal,$sortVal,$subFiles, $excludeVal, $SCRRange) = &FinalCRDSectionSource(schema => $args{schema}, section => $chapternumber, CRDPeriod => $args{CRDPeriod});

                if ($subFiles eq 'T') {
                    my $subchapterNumber = $chapters[$chapternumber][1][$subchapter][0];
                    $subchapterNumber =~ s/ /0/g;
                    my $subNumber = substr($subchapterNumber,(index($subchapterNumber,'.')));
                    $subNumber =~ s/\./-/g;
                    my $subCount = 0;
                    for (my $i=0; $i<=length($subchapterNumber); $i++) {
                        if (substr($subchapterNumber,$i,1) eq '.') {$subCount++;}
                    }
                    if ($subCount == 1) {
                        print FH1 $PageEnd;
                        close FH1;
                        if (!(open (FH1, "| ./File_Utilities.pl --command=writeFile --fullFilePath=$CRDFullTempReportPath/final_crd/$foldername/ch" . lpadzero($chapternumber,2) . $subNumber . ".htm --protection=0777"))) {
                            die "Unable to open file $CRDFullTempReportPath/$foldername/ch" . lpadzero($chapternumber,2) .  $subNumber . ".htm\n";
                        }
                        $outputstring .= "<li><a href=\"ch" . lpadzero($chapternumber,2) .  $subNumber . ".htm\">Section $chapters[$chapternumber][1][$subchapter][0] &nbsp; $chapters[$chapternumber][1][$subchapter][2]</a><br><br></li>\n";
                        print FH1 $PageStart;
                    }
                }

                if ($chapters[$chapternumber][1][$subchapter][0] =~ /.*\..*\..*/) {
                #if (1==2) {
                    print FH1 "<table border=0 width=670 align=center cellpadding=0 cellspacing=0><tr><td><font size=" . ($fontSize + 1) . "><b>$chapters[$chapternumber][1][$subchapter][0] &nbsp; $chapters[$chapternumber][1][$subchapter][2]</b><br></font></td></tr></table>\n";
                } else {
                    print FH1 "<center><font size=" . ($fontSize + 1) . "><b>$chapters[$chapternumber][1][$subchapter][0] &nbsp; $chapters[$chapternumber][1][$subchapter][2]</b><br></font></center>\n";
                }
                print FH1 "<table border=0 width=670 align=center>\n";
                

                # process summary comments
                if ($selectiontype ne "cronly") {
                    $sqlquery = "SELECT id,title,commenttext,responsetext,dateapproved" . (($args{CRDIDSource} eq 'fetch') ? ', uniqueid' : "") . " FROM $args{schema}.summary_comment WHERE bin IN ($chapters[$chapternumber][1][$subchapter][1]) $SCRSelection $SCRRange ";
                    $sqlquery .= "ORDER BY " . (($args{CRDIDSource} eq 'fetch') ? 'uniqueid, ' : "") . "title, id";
print "<!-- ($CRDSource, $showCRDCommentors,$fromVal,$whereVal,$sortVal,$subFiles, $excludeVal, $SCRRange) -->\n";
print "<!-- $sqlquery -->\n";
                    $csr = $args{dbh}->prepare($sqlquery);
                    $status = $csr->execute;
                    while (@values = $csr->fetchrow_array) {
                        $commentcount++;
                        if ($args{CRDIDSource} eq 'generate') {
                            $loc = "$chapters[$chapternumber][1][$subchapter][0] ($commentcount)";
                            my $temp = "$chapters[$chapternumber][1][$subchapter][0]                    ";
                            $loc2 = substr($temp,0,20) . " (" . lpadzero($commentcount,20) . ")";
                        } else {
                            $loc = "$chapters[$chapternumber][1][$subchapter][0] ($values[5])";
                            my $temp = "$chapters[$chapternumber][1][$subchapter][0]                    ";
                            $loc2 = substr($temp,0,20) . " (" . lpadzero($values[5],20) . ")";
                        }
                        print "<script language=JavaScript>\n";
                        print "    parent.main.$form.current.value='$loc';\n";
                        print "</script>\n";
                        print "<!-- Keep Alive, $loc -->\n";
                        print FH1 "<tr><td colspan=$colcount><font size=$fontSize><b>$loc</b></font></td></tr>\n";
                        #$locations{lpadzero($values[0],6) . "-" . lpadzero($values[1],4)} = $loc;
                        $locations{lpadzero($values[0],6) . "-SCR "} = $loc;
                        $indexLocation{("SCR" . lpadzero($values[0],4))} = $loc;
                        
                        $commentorBlock = '';
                        
                        #if ($args{showCommentors} eq 'T') {
                            $commentorBlock .= "<tr><td align=center vailing=bottom><br><br><font size=$fontSize><i>Commenter</i></font></td><td>" . nbspaces(2) . "</td><td align=center vailing=bottom><font size=$fontSize><i>Comment<br>Document<br>No.</i></font></td><td>" . nbspaces(5);
                            $commentorBlock .= "<td align=center vailing=bottom><font size=$fontSize><i>Commenter</i></font></td><td>" . nbspaces(2) . "</td><td align=center vailing=bottom><font size=$fontSize><i>Comment<br>Document<br>No.</i></font></td></tr>\n";
                            $commentorBlock .= "<tr><td colspan=3 width=48%><hr align=center></td><td>&nbsp;</td><td colspan=3 width=48%><hr align=center></td><tr>\n";
                            $column = 1;
                            # get summarized comments
                            $sqlquery2 = "SELECT com.document,com.commentnum,SYSDATE,SYSDATE,SYSDATE,SYSDATE ";
                            $sqlquery2 .= "FROM $args{schema}.comments com ";
                            $sqlquery2 .= "WHERE com.summary = $values[0] $excludeVal ";
                            $sqlquery2 .= "ORDER BY com.document,com.commentnum";
                            $csr2 = $args{dbh}->prepare($sqlquery2);
                            $status = $csr2->execute;
                            $lastdoc = 0;
                            while (@values2 = $csr2->fetchrow_array) {
                                if ($lastdoc != $values2[0]) {
                                    $lastdoc = $values2[0];
                                }
                                    @commentor2 = getCommentor('dbh' => $dbh, 'schema'=>$schema, 'document'=>$values2[0]);
                                    print "<!-- * $CRDType" . lpadzero($values2[0],6) . "-" . lpadzero($values2[1],4) . "-->\n";
                                    $locations{lpadzero($values2[0],6) . "-" . lpadzero($values2[1],4)} = $loc;
                                    $indexLocation{("$CRDType" . lpadzero($values2[0],6) . " / " . lpadzero($values2[1],4))} = $loc . "&nbsp;[SCR" . lpadzero($values[0],4) . "]";
                                    $sectionLocations[++$#sectionLocations] = [ ($loc,$values2[0],$values2[1],$loc2,@commentor2) ];
                                    $commentorBlock .= "<td valign=top><font size=$fontSize2>" . ((defined($commentor2[3])) ? "$commentor2[3]<br>&nbsp;&nbsp;" : "")  . (($commentor2[0] == 1) ? "$commentor2[1]" . ((defined($commentor2[2])) ? ", $commentor2[2]" : "") : get_value($args{dbh},$args{schema},"commentor_name_status","name", "id=$commentor2[0]")) . "</font></td>\n";
                                    $commentorBlock .= "<td>&nbsp;</td><td valign=top align=center><font size=$fontSize2>$CRDType" . lpadzero($values2[0],6) . getDuplicateDocuments('dbh' => $args{dbh}, 'schema' => $args{schema}, 'id' => $values2[0]) . "</font></td>\n";
                                    if ($column == 1) {
                                        $commentorBlock .= "<td>&nbsp;</td>\n";
                                        $column = 2;
                                    } else {
                                        $commentorBlock .= "</tr>\n";
                                        $column = 1;
                                    }
                                    # get duplicate comments
                                    $sqlquery3 = "SELECT com.document,com.commentnum,SYSDATE,SYSDATE,SYSDATE,SYSDATE ";
                                    $sqlquery3 .= "FROM $args{schema}.comments com ";
                                    $sqlquery3 .= "WHERE com.dupsimdocumentid = $values2[0] AND com.dupsimcommentid = $values2[1] AND NVL(com.summary,0) = 0 ";
                                    $sqlquery3 .= "AND com.document <> $values2[0] $excludeVal ";
                                    $sqlquery3 .= "ORDER BY com.document,com.commentnum";
                                    $csr3 = $args{dbh}->prepare($sqlquery3);
                                    $status = $csr3->execute;
                                    $lastdoc2 = 0;
                                    while (@values3 = $csr3->fetchrow_array) {
                                        if ($lastdoc != $values3[0] && $lastdoc2 != $values3[0]) {
                                            $lastdoc2 = $values3[0];
                                        }
                                            @commentor3 = getCommentor('dbh' => $dbh, 'schema'=>$schema, 'document'=>$values3[0]);
                                            print "<!-- ! $CRDType" . lpadzero($values3[0],6) . "-" . lpadzero($values3[1],4) . "-->\n";
                                            $locations{lpadzero($values3[0],6) . "-" . lpadzero($values3[1],4)} = $loc;
                                            $sectionLocations[++$#sectionLocations] = [ ($loc,$values3[0],$values3[1],$loc2,@commentor3) ];
                                            $commentorBlock .= "<td valign=top><font size=$fontSize2>" . ((defined($commentor3[3])) ? "$commentor3[3]<br>&nbsp;&nbsp;" : "") . (($commentor3[0] == 1) ? "$commentor3[1]" . ((defined($commentor3[2])) ? ", $commentor3[2]" : "") : get_value($args{dbh},$args{schema},"commentor_name_status","name", "id=$commentor3[0]")) . "</font></td>\n";
                                            $commentorBlock .= "<td>&nbsp;</td><td valign=top align=center><font size=$fontSize2>$CRDType" . lpadzero($values3[0],6) . getDuplicateDocuments('dbh' => $args{dbh}, 'schema' => $args{schema}, 'id' => $values3[0]) . "</font></td>\n";
                                            if ($column == 1) {
                                                $commentorBlock .= "<td>&nbsp;</td>\n";
                                                $column = 2;
                                            } else {
                                                $commentorBlock .= "</tr>\n";
                                                $column = 1;
                                            }
                                        #}
                                    }
                                    $csr3->finish;
                                #}
                            }
                            $csr2->finish;
                            if ($column == 2) {
                                $commentorBlock .= "<td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td></tr>\n";
                            }
                        #}
                        if (($args{showCommentors} eq 'T' && $showCRDCommentors eq 'default') || $showCRDCommentors eq 'true') {
                            print FH1 $commentorBlock;
                        }
                        
                        
                        $values[2] =~ s/\n/<br>/g;
                        $values[2] =~ s/  /&nbsp;&nbsp;/g;
                        $values[2] =~ s/&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;/&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;/g;
                        print FH1 "<tr><td colspan=$colcount><font size=$fontSize><br><u>Comment</u>" . (($DisplayCommentNumbers == 1) ? " - <i>SCR" . lpadzero($values[0],4) . " </i>" : "") . "<br>$values[1]<br>$values[2]</font></td></tr>\n";
                        
                        #if (defined($values[4])) {
                            $values[3] = ((defined($values[3])) ? $values[3] : "");
                            $values[3] =~ s/\n/<br>/g;
                            $values[3] =~ s/  /&nbsp;&nbsp;/g;
                            $values[3] =~ s/&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;/&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;/g;
                            print FH1 "<tr><td colspan=$colcount><font size=$fontSize><br><u>Response</u><br>$values[3]</font></td></tr>\n";
                        #} else {
                        #    print FH1 "<tr><td colspan=$colcount><font size=$fontSize><br><u>Response</u><br>In preparation</font></td></tr>\n";
                        #}
                        print FH1 "<tr><td colspan=$colcount><br><br></td></tr>\n";
                        
                        
                    }
                    $csr->finish;
                }
                
                # process comments
                if ($selectiontype ne "scr") {
                    my $selectSource;
                    if ($CRDSource eq 'bins') {
                        $selectSource = "com.bin IN ($chapters[$chapternumber][1][$subchapter][1])";
                    } elsif ($CRDSource eq 'bins-exclude') {
                        $selectSource = "com.bin IN ($chapters[$chapternumber][1][$subchapter][1]) AND (com.document < 220000 OR com.document > 339999)";
                    } else {
                        $selectSource = "com.document IN (" . &getDocumentList(section => $chapters[$chapternumber][1][$subchapter][3], CRDPeriod => $args{CRDPeriod}) . ")";
                    }
                    $sqlquery = "SELECT com.document,com.commentnum,com.text,SYSDATE,SYSDATE," . (($args{CRDIDSource} eq 'fetch') ? ' com.uniqueid' : "SYSDATE") . ",SYSDATE,rv.status,rv.originaltext,rv.lastsubmittedtext ";
                    $sqlquery .= "FROM $args{schema}.comments com,$args{schema}.response_view rv $fromVal ";
                    $sqlquery .= "WHERE (com.document=rv.document(+) AND com.commentnum=rv.commentnum(+)) ";
                    $sqlquery .= "AND ($selectSource AND com.dupsimstatus=1 AND com.summary IS NULL) $selection $whereVal $excludeVal ";
                    $sqlquery .= "ORDER BY $sortVal " . (($args{CRDIDSource} eq 'fetch') ? 'com.uniqueid, ' : "") . "com.document,com.commentnum";
                    $csr = $args{dbh}->prepare($sqlquery);
print "\n<!-- $sqlquery -->\n\n";
                    $status = $csr->execute;
                    while (@values = $csr->fetchrow_array) {
                        @commentor = getCommentor('dbh' => $dbh, 'schema'=>$schema, 'document'=>$values[0]);
                        $commentcount++;
                        if ($args{CRDIDSource} eq 'generate') {
                            $loc = "$chapters[$chapternumber][1][$subchapter][0] ($commentcount)";
                            my $temp = "$chapters[$chapternumber][1][$subchapter][0]                    ";
                            $loc2 = substr($temp,0,20) . " (" . lpadzero($commentcount,20) . ")";
                        } else {
                            $loc = "$chapters[$chapternumber][1][$subchapter][0] ($values[5])";
                            my $temp = "$chapters[$chapternumber][1][$subchapter][0]                    ";
                            $loc2 = substr($temp,0,20) . " (" . lpadzero($values[5],20) . ")";
                        }
                        print "<!-- Keep Alive, $loc -->\n";
                        print "<script language=JavaScript>\n";
                        print "    parent.main.$form.current.value='$loc';\n";
                        print "</script>\n";
                        print FH1 "<tr><td colspan=$colcount><font size=$fontSize><b>$loc</b></font></td></tr>\n";
                        $locations{lpadzero($values[0],6) . "-" . lpadzero($values[1],4)} = $loc;
                        $sectionLocations[++$#sectionLocations] = [ ($loc,$values[0],$values[1],$loc2,@commentor) ];
                        $indexLocation{("$CRDType" . lpadzero($values[0],6) . " / " . lpadzero($values[1],4))} = $loc;
                        
                        $commentorBlock = '';
                        
                        #if ($args{showCommentors} eq 'T') {
                            $commentorBlock .= "<tr><td align=center vailing=bottom><br><br><font size=$fontSize><i>Commenter</i></font></td><td>" . nbspaces(2) . "</td><td align=center vailing=bottom><font size=$fontSize><i>Comment<br>Document<br>No.</i></font></td><td>" . nbspaces(5);
                            $commentorBlock .= "<td align=center vailing=bottom><font size=$fontSize><i>Commenter</i></font></td><td>" . nbspaces(2) . "</td><td align=center vailing=bottom><font size=$fontSize><i>Comment<br>Document<br>No.</i></font></td></tr>\n";
                            $commentorBlock .= "<tr><td colspan=3 width=48%><hr align=center></td><td>&nbsp;</td><td colspan=3 width=48%><hr align=center></td><tr>\n";
                            $column = 2;
                            $commentorBlock .= "<tr><td valign=top><font size=$fontSize2>" . ((defined($commentor[3])) ? "$commentor[3]<br>&nbsp;&nbsp;" : "") . (($commentor[0] == 1) ? "$commentor[1]" . ((defined($commentor[2])) ? ", $commentor[2]" : "") : get_value($args{dbh},$args{schema},"commentor_name_status","name", "id=$commentor[0]")) . "</font></td>\n";
                            $commentorBlock .= "<td>&nbsp;</td><td valign=top align=center><font size=$fontSize2>$CRDType" . lpadzero($values[0],6) . getDuplicateDocuments('dbh' => $args{dbh}, 'schema' => $args{schema}, 'id' => $values[0]) . "</font></td><td>&nbsp;</td>\n";
                            $lastdoc = $values[0];
                            # get duplicate comments
                            $sqlquery2 = "SELECT com.document,com.commentnum,SYSDATE,SYSDATE,SYSDATE,SYSDATE ";
                            $sqlquery2 .= "FROM $args{schema}.comments com ";
                            $sqlquery2 .= "WHERE (com.bin IN ($chapters[$chapternumber][1][$subchapter][1]) AND com.dupsimstatus=2 AND com.dupsimdocumentid=$values[0] AND com.dupsimcommentid=$values[1] AND com.summary IS NULL) ";
                            $sqlquery2 .= "AND com.document <> $values[0] ";
                            $sqlquery2 .= "ORDER BY com.document,com.commentnum";
                            $csr2 = $args{dbh}->prepare($sqlquery2);
                            $status = $csr2->execute;
                            while (@values2 = $csr2->fetchrow_array) {
                                @commentor2 = getCommentor('dbh' => $dbh, 'schema'=>$schema, 'document'=>$values2[0]);
                                $locations{lpadzero($values2[0],6) . "-" . lpadzero($values2[1],4)} = $loc;
                                $sectionLocations[++$#sectionLocations] = [ ($loc,$values2[0],$values2[1],$loc2,@commentor2) ];
                                if ($lastdoc != $values2[0]) {
                                    $lastdoc = $values2[0];
                                    $commentorBlock .= "<td valign=top><font size=$fontSize2>" . ((defined($commentor2[3])) ? "$commentor2[3]<br>&nbsp;&nbsp;" : "") . (($commentor2[0] == 1) ? "$commentor2[1]" . ((defined($commentor2[2])) ? ", $commentor2[2]" : "") : get_value($args{dbh},$args{schema},"commentor_name_status","name", "id=$commentor2[0]")) . "</font></td>\n";
                                    $commentorBlock .= "<td>&nbsp;</td><td valign=top align=center><font size=$fontSize2>$CRDType" . lpadzero($values2[0],6) . getDuplicateDocuments('dbh' => $args{dbh}, 'schema' => $args{schema}, 'id' => $values2[0]) . "</font></td>\n";
                                    if ($column == 1) {
                                        $commentorBlock .= "<td>&nbsp;</td>\n";
                                        $column = 2;
                                    } else {
                                        $commentorBlock .= "</tr>\n";
                                        $column = 1;
                                    }
                                }
                            }
                            $csr2->finish;
                            if ($column == 2) {
                                $commentorBlock .= "<td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td></tr>\n";
                            }
                        #}
                        if (($args{showCommentors} eq 'T' && $showCRDCommentors eq 'default') || $showCRDCommentors eq 'true') {
                            print FH1 $commentorBlock;
                        }
                        
                        $values[2] =~ s/\n/<br>/g;
                        $values[2] =~ s/  /&nbsp;&nbsp;/g;
                        $values[2] =~ s/&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;/&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;/g;
                        print FH1 "<tr><td colspan=$colcount><font size=$fontSize><br><u>Comment</u>" . (($DisplayCommentNumbers == 1) ? " - <i>$CRDType" . lpadzero($values[0],6) . " / " . lpadzero($values[1],4) . " </i>" : "") . "<br>$values[2]</font></td></tr>\n";
                        
                        #if (defined($values[7]) && $values[7] == 9) {
                        if (defined($values[7])) {
                        print "\n\n<!-- $args{schema}, $values[0], $values[1] -->\n\n";
                            $values[9] = lastSubmittedText(dbh => $args{dbh}, schema => $args{schema}, documentID => $values[0], commentID => $values[1]);
                            $values[9] = ((defined($values[9])) ? $values[9] : "");
                            $values[9] =~ s/\n/<br>/g;
                            $values[9] =~ s/  /&nbsp;&nbsp;/g;
                            $values[9] =~ s/&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;/&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;/g;
                            print FH1 "<tr><td colspan=$colcount><font size=$fontSize><br><u>Response</u><br>$values[9]</font></td></tr>\n";
                        } else {
                            print FH1 "<tr><td colspan=$colcount><font size=$fontSize><br><u>Response</u><br>In preparation</font></td></tr>\n";
                        }
                        print FH1 "<tr><td colspan=$colcount><br><br></td></tr>\n";
                        
                        
                    }
                    $csr->finish;
                }
                
                print FH1 "</td></tr></table>\n";
                
            }
            
            
        }
        print FH1 $PageEnd;
        close FH1;
        
        print "<script language=JavaScript>\n";
        print "    parent.main.$form.current.value='Org Index';\n";
        print "</script>\n";

        if (!(open (FH1, "| ./File_Utilities.pl --command=writeFile --fullFilePath=$CRDFullTempReportPath/final_crd/$foldername/index1.htm --protection=0777"))) {
            die "Unable to open file $CRDFullTempReportPath/$foldername/index1.htm\n";
        }
        print FH1 $PageStart;

        my ($CRDSource, $showCRDCommentors,$fromVal,$whereVal,$sortVal,$subFiles, $excludeVal) = &FinalCRDSectionSource(schema => $args{schema}, section => 0, CRDPeriod => $args{CRDPeriod});

        $outputstring .= "<li><a href=\"index1.htm\">Table 1 - Index to Comments by Organizations</a><br><br></li>\n";
        # build Index by Organizations
        print FH1 "<br><br><center><font size=" . ($fontSize + 1) . "><b>Table 1</b><br></font></center>\n";
        print FH1 "<center><font size=" . ($fontSize + 1) . "><b>INDEX TO COMMENTS BY ORGANIZATIONS</b><br></font></center>\n";
        print FH1 "<table border=0 width=670 align=center>";
        print FH1 "<tr><td align=center valgin=bottom>&nbsp;</td>";
        print FH1 "<td align=left valgin=bottom width=50%><font size=$fontSize><b>Commenter</b></font></td><td align=center valgin=bottom>&nbsp;</td>";
        print FH1 "<td align=center valgin=bottom width=15%><font size=$fontSize><b>Comment<br>Document<br>No.</b></font></td><td align=center valgin=bottom>&nbsp;</td>";
        print FH1 "<td align=center valgin=bottom width=15%><font size=$fontSize><b>Location of<br>Comments/Responses&nbsp;in<br>this Part</b></font></td><td align=center valgin=bottom>&nbsp;</td></tr>\n";
        print FH1 "<tr><td colspan=7><hr width=100% align=center></td></tr>\n";
            
        $sqlquery = "SELECT com.organization, doc.id,com.id,com.lastname,com.firstname,com.middlename,doc.dupsimstatus,doc.dupsimid FROM $args{schema}.commentor com, $args{schema}.document doc WHERE com.id = doc.commentor AND com.organization IS NOT NULL $excludeVal ORDER BY com.organization,com.lastname,com.firstname,doc.id";
        $csr = $args{dbh}->prepare($sqlquery);
        $status = $csr->execute;
        
        my $lastOrg = '';
        my $lastCommentor = 0;
        while (@values = $csr->fetchrow_array) {
            if (defined($values[1])) {
                if ($values[6] eq 1) {
                    $loc = getLocations('dbh'=>$dbh,'schema'=>$schema,'document'=>$values[1], 'locations'=>\%locations);
                } else {
                    $loc = getLocations('dbh'=>$dbh,'schema'=>$schema,'document'=>$values[7], 'locations'=>\%locations);
                }
                if ($selectiontype eq 'all' || $loc gt "") {
                    if ($lastOrg ne $values[0]) {
                        print "<!-- Org: $lastOrg -->\n";
                        print FH1 "<tr><td>&nbsp;</td><td><font size=$fontSize>$values[0]</font></td><td colspan=5>&nbsp</td></tr>\n";
                        $lastOrg = $values[0];
                        $lastCommentor = 0;
                    }
                    print FH1 "<tr><td>&nbsp;</td><td valign=top><font size=$fontSize>" . nbspaces(3);
                    if ($lastCommentor != $values[2]) {
                       print FH1 $values[3] . ((defined($values[4])) ? ", $values[4]" : "") . ((defined($values[5])) ? " $values[5]" : "");
                       $lastCommentor = $values[2];
                    }
                    print FH1 "</font></td><td>&nbsp;</td><td valign=top align=center><font size=$fontSize>$CRDType" . lpadzero($values[1],6) . "</font></td>";
                    print FH1 "<td>&nbsp;</td><td valign=top align=center><font size=$fontSize>" . $loc . "</font></td><td>&nbsp;</td></tr>\n";
                }
            }
            
        }
        print FH1 "</table>\n";
        print FH1 $PageEnd;
        close FH1;
        
            
        print "<script language=JavaScript>\n";
        print "    parent.main.$form.current.value='Cmntr Index';\n";
        print "</script>\n";

        if (!(open (FH1, "| ./File_Utilities.pl --command=writeFile --fullFilePath=$CRDFullTempReportPath/final_crd/$foldername/index2.htm --protection=0777"))) {
            die "Unable to open file $CRDFullTempReportPath/$foldername/index2.htm\n";
        }
        print FH1 $PageStart;

        $outputstring .= "<li><a href=\"index2.htm\">Table 2 - Index to Comments by Individuals</a><br><br></li> \n";
        # build Index by Commentor
        print FH1 "<br><br><center><font size=" . ($fontSize + 1) . "><b>Table 2</b><br></font></center>\n";
        print FH1 "<center><font size=" . ($fontSize + 1) . "><b>INDEX TO COMMENTS BY INDIVIDUALS</b><br></font></center>\n";
        print FH1 "<table border=0 width=670 align=center>";
        print FH1 "<tr><td align=center valgin=bottom>&nbsp;</td>";
        print FH1 "<td align=left valgin=bottom width=25%><font size=$fontSize><b>Commenter</b></font></td><td align=center valgin=bottom>&nbsp;</td>";
        print FH1 "<td align=center valgin=bottom width=25%><font size=$fontSize><b>Organization</b></font></td><td>&nbsp;</td>";
        print FH1 "<td align=center valgin=bottom width=10%><font size=$fontSize><b>Comment<br>Document<br>No.</b></font></td><td align=center valgin=bottom>&nbsp;</td>";
        print FH1 "<td align=center valgin=bottom width=10%><font size=$fontSize><b>Location of<br>Comments/Responses&nbsp;in<br>this Part</b></font></td><td align=center valgin=bottom>&nbsp;</td></tr>\n";
        print FH1 "<tr><td colspan=9><hr width=100% align=center></td></tr>\n";
            
        $sqlquery = "SELECT com.organization, doc.id,com.id,com.lastname,com.firstname,com.middlename,doc.namestatus,doc.dupsimstatus,doc.dupsimid FROM $args{schema}.commentor com, $args{schema}.document doc WHERE com.id(+) = doc.commentor $excludeVal ORDER BY com.lastname,com.firstname,com.middlename,com.id,doc.namestatus,doc.id";
        $csr = $args{dbh}->prepare($sqlquery);
        $status = $csr->execute;
            
        $lastCommentor = 0;
        while (@values = $csr->fetchrow_array) {
            if ($values[6] != 1) {
                $values[2] = 0 - $values[6];
            }
            if (defined($values[1])) {
                #$loc = getLocations('dbh'=>$dbh,'schema'=>$schema,'document'=>$values[1], 'locations'=>\%locations);
                if ($values[7] eq 1) {
                    $loc = getLocations('dbh'=>$dbh,'schema'=>$schema,'document'=>$values[1], 'locations'=>\%locations);
                } else {
                    $loc = getLocations('dbh'=>$dbh,'schema'=>$schema,'document'=>$values[8], 'locations'=>\%locations);
                }
                if ($selectiontype eq 'all' || $loc gt "") {
                    print FH1 "<tr><td>&nbsp;</td><td valign=top><font size=$fontSize>" . nbspaces(3);
                    #if ($lastCommentor != $values[2] && $lastCommentor != -2 && $lastCommentor != -3) {
                    if ($lastCommentor != $values[2]) {
                        print "<!-- Cmntr: $values[2] -->\n";
                        if ($values[6] == 1) {
                            print FH1 $values[3] . ((defined($values[4])) ? ", $values[4]" : "") . ((defined($values[5])) ? " $values[5]" : "");
                            $lastCommentor = $values[2];
                            print FH1 "</font></td><td>&nbsp;</td><td valign=top><font size=$fontSize>" . ((defined($values[0])) ? $values[0] : "&nbsp;");
                        } else {
                            $lastCommentor = 0 - $values[6];
                            print FH1 get_value($args{dbh},$args{schema},'commentor_name_status','name',"id=$values[6]");
                            print FH1 "</font></td><td>&nbsp;</td><td>&nbsp;";
                        }
                    } else {
                        print FH1 "</font></td><td>&nbsp;</td><td>&nbsp;";
                    }
                    print FH1 "</td><td>&nbsp;</td><td valign=top align=center><font size=$fontSize>$CRDType" . lpadzero($values[1],6) . "</font></td>";
                    print FH1 "<td>&nbsp;</td><td valign=top align=center><font size=$fontSize>" . $loc . "</font></td><td>&nbsp;</td></tr>\n";
                }
            }
            
        }
        print FH1 "</table>\n";
            
        print "<script language=JavaScript>\n";
        print "    parent.main.$form.current.value='done';\n";
        print "</script>\n";
        
        print FH1 $PageEnd;
        close FH1;
        
            
        print "<script language=JavaScript>\n";
        print "    parent.main.$form.current.value='Loc Index';\n";
        print "</script>\n";

        if (!(open (FH1, "| ./File_Utilities.pl --command=writeFile --fullFilePath=$CRDFullTempReportPath/final_crd/$foldername/index3.htm --protection=0777"))) {
            die "Unable to open file $CRDFullTempReportPath/$foldername/index3.htm\n";
        }
        print FH1 $PageStart;

        $outputstring .= "<li><a href=\"index3.htm\">Table 3 - Index to Comments by Comment Number</a><br><br></li> \n";
        # build Index by comment number
        print FH1 "<br><br><center><font size=" . ($fontSize + 1) . "><b>Table 3</b><br></font></center>\n";
        print FH1 "<center><font size=" . ($fontSize + 1) . "><b>INDEX TO COMMENTS BY COMMENT NUMBER</b><br></font></center>\n";
        print FH1 "<table border=0 width=670 align=center>";
        print FH1 "<tr><td align=center valgin=bottom>&nbsp;</td>";
        print FH1 "<td align=center valgin=bottom width=20%><font size=$fontSize><b>Comment&nbsp;Location</b></font></td><td align=center valgin=bottom>&nbsp;</td>";
        print FH1 "<td align=left valgin=bottom width=45%><font size=$fontSize><b>Commenter</b></font></td><td valgin=bottom>&nbsp;</td>";
        print FH1 "<td align=center valgin=bottom width=20%><font size=$fontSize><b>Comment&nbsp;Document&nbsp;/<br>Comment&nbsp;No.</b></font></td><td valgin=bottom>&nbsp;</td></tr>\n";
        print FH1 "<tr><td colspan=7><hr width=100% align=center></td></tr>\n";

        my $lastLoc = '';
        $lastCommentor =0;
        my $lastStatus=1;
        my %keysForSort;
        my $temp;
        
        for (my $key=0; $key <= $#sectionLocations; $key++) {
            my ($loc,$documentID, $commentID, $loc2, $nameStatus, $lastName, $firstName, $organization, $commentorID) = 
                ($sectionLocations[$key][0],$sectionLocations[$key][1],$sectionLocations[$key][2],$sectionLocations[$key][3],$sectionLocations[$key][4],$sectionLocations[$key][5],$sectionLocations[$key][6],$sectionLocations[$key][7],$sectionLocations[$key][8]) ;
            if ($nameStatus == 1) {
                $temp = $loc2 . (substr(($lastName . "                         "),0,25)) . (substr((((defined($firstName)) ? $firstName : "") . "                         "),0,25)) . lpadzero($documentID,6) . lpadzero($commentID,4);
            } else {
                $temp = $loc2 . ("ZZZZZZZZZZZZZZZZZZZZZZZZZ") . ($nameStatus . "                        ") . lpadzero($documentID,6) . lpadzero($commentID,4);
            }
            print "<!-- ****** $temp ****** -->\n";
            $keysForSort{$temp} = $key;
        }
        #for (my $key=0; $key <= $#sectionLocations; $key++) {
        foreach my $skey (sort keys %keysForSort) {
            my $key = $keysForSort{$skey};
            #my ($nameStatus, $lastName, $firstName, $organization, $commentorID) = getCommentor(dbh => $args{dbh}, schema => $args{schema}, document => $sectionLocations[$key][1]);
            my ($nameStatus, $lastName, $firstName, $organization, $commentorID) = 
                ($sectionLocations[$key][4],$sectionLocations[$key][5],$sectionLocations[$key][6],$sectionLocations[$key][7],$sectionLocations[$key][8]) ;
            print FH1 "<tr><td>&nbsp;</td><td valign=top align=center><font size=$fontSize>";
            if ($lastLoc ne $sectionLocations[$key][0]) {
                $lastLoc = $sectionLocations[$key][0];
                $lastCommentor = 0;
                print FH1 $sectionLocations[$key][0];
            } else {
                print FH1 "&nbsp;";
            }
            print FH1 "</font></td><td>&nbsp;</td><td valign=top><font size=$fontSize>";
            if ($nameStatus == 1) {
                if ($lastCommentor ne $commentorID) {
                    print FH1 ((defined($organization) && $organization gt ' ') ? "$organization<br>&nbsp;" : "");
                    print FH1 $lastName . ((defined($firstName) && $firstName gt ' ') ? ", $firstName" : "");
                    $lastCommentor = $commentorID;
                } else {
                    print FH1 "&nbsp;";
                }
            } else {
                if ($lastStatus == 1 || $lastStatus != $nameStatus) {
                    print FH1 get_value($args{dbh},$args{schema}, 'commentor_name_status', 'name', "id=$nameStatus");
                } else {
                    print FH1 "&nbsp;";
                }
            }
            $lastStatus = $nameStatus;
            print FH1 "</font></td><td>&nbsp;</td><td valign=top align=center><font size=$fontSize>$CRDType" . lpadzero($sectionLocations[$key][1],6) . " / " . lpadzero($sectionLocations[$key][2],4) . "</font></td><td>&nbsp;</td></tr>\n";
        }
            
        print FH1 "</table>\n";
            
        print "<script language=JavaScript>\n";
        print "    parent.main.$form.current.value='done';\n";
        print "</script>\n";
        
        print FH1 $PageEnd;
        close FH1;
        
            
        print "<script language=JavaScript>\n";
        print "    parent.main.$form.current.value='Com/Loc2 Index';\n";
        print "</script>\n";

        if (!(open (FH1, "| ./File_Utilities.pl --command=writeFile --fullFilePath=$CRDFullTempReportPath/final_crd/$foldername/index4.htm --protection=0777"))) {
            die "Unable to open file $CRDFullTempReportPath/$foldername/index4.htm\n";
        }
        print FH1 $PageStart;

        $outputstring .= "<li><a href=\"index4.htm\">Table 4 - Index to Chapters by Comment Number</a><br><br></li> \n";
        # build Chapter Index by comment number
        print FH1 "<br><br><center><font size=" . ($fontSize + 1) . "><b>Table 4</b><br></font></center>\n";
        print FH1 "<center><font size=" . ($fontSize + 1) . "><b>INDEX TO CHAPTERS BY COMMENT NUMBER</b><br></font></center>\n";
        print FH1 "<table border=0 width=670 align=center>";
        print FH1 "<tr><td align=center valgin=bottom>&nbsp;</td>";
        print FH1 "<td align=center valgin=bottom width=45%><font size=$fontSize><b>Comment&nbsp;Document&nbsp;/<br>Comment&nbsp;No.</b></font></td><td valgin=bottom>&nbsp;</td>";
        print FH1 "<td align=center valgin=bottom width=45%><font size=$fontSize><b>Comment&nbsp;Location</b></font></td><td align=center valgin=bottom>&nbsp;</td>";
        print FH1 "</tr>\n";
        print FH1 "<tr><td colspan=5><hr width=100% align=center></td></tr>\n";

        
        foreach my $key (sort keys(%indexLocation)) {
            print FH1 "<tr>";
            print FH1 "<td>&nbsp;</td><td valign=top align=center><font size=$fontSize>$key</font></td>";
            print FH1 "<td>&nbsp;</td><td valign=top align=center><font size=$fontSize>$indexLocation{$key}</font></td>";
            print FH1 "<td>&nbsp;</td></tr>\n";
        }
        
            
        print FH1 "</table>\n";
            
        print "<script language=JavaScript>\n";
        print "    parent.main.$form.current.value='done';\n";
        print "</script>\n";
        
        print FH1 $PageEnd;
        close FH1;
        
        $outputstring .= "</ul></font></td></tr>\n";
        #$outputstring .= "<tr><td><hr width=100%></td></tr>\n";
        #$outputstring .= "<tr><td align=center><font size=4>As of: " . getReportDateTime() . "</font></td></tr>\n";
        my ($sec,$min,$hour,$day, $month, $year) = (localtime)[0,1,2,3,4,5];
        $year = $year + 1900;
        $month++;
        my $ampm = 'AM';
        if ($hour > 12) {
            $ampm = "PM";
            $hour = lpadzero(($hour-12),2);
        } elsif ($hour == 12) {
            $ampm = "PM";
        }
        my $runendtime = uc(get_date(lpadzero($month,2) . "/" . lpadzero($day,2) . "/" . $year)) . " " . lpadzero($hour,2) . ":" . lpadzero($min,2) . ":" . lpadzero($sec,2) . $ampm;
        $outputstring =~ s/<place end time here>/$runendtime/;
        $outputstring .= "</table>\n";


    };
    if ($@) {
        $message = errorMessage($dbh,$username,$userid,$schema,"creating the final CRD report.",$@);
        print doAlertBox( text => $message);
    }
    

    return ($outputstring);
}


###################################################################################################################################
###################################################################################################################################

#$dbh = &db_connect();
$dbh = &db_connect(server => 'ydoraprd.ymp.gov');
$dbh->{LongTruncOk} = 1;   # specify whether to fetch whole text or truncated fraction 
$dbh->{LongReadLen} = 10000000;

print $crdcgi->header('text/html');
@chapters = &buildChapters (dbh => $dbh, schema => $schema);
print <<END_OF_BLOCK;
<html>
<head>
   <script src=$CRDJavaScriptPath/utilities.js></script>
   <script src=$CRDJavaScriptPath/widgets.js></script>
   <script language=javascript><!--
      function report(script, report) {
         document.$form.command.value = 'report';         
         document.$form.action = '$path' + script + '.pl';
         document.$form.id.value = report;
         document.$form.submit();
      }
      function submitForm(script, command, id) {
          document.$form.command.value = command;
          document.$form.id.value = id;
          document.$form.action = '$path' + script + '.pl';
          document.$form.target = 'main';
          document.$form.submit();
      }
      function submitFormNewWindow(script, command, id) {
          var myDate = new Date();
          var winName = myDate.getTime();
          document.$form.command.value = command;
          document.$form.id.value = id;
          document.$form.action = '$path' + script + '.pl';
          document.$form.target = winName;
          var newwin = window.open("",winName);
          newwin.creator = self;
          document.$form.submit();
          //newwin.focus();
      }
      function submitFormCGIResults(script, command, id) {
          document.$form.command.value = command;
          document.$form.id.value = id;
          document.$form.action = '$path' + script + '.pl';
          document.$form.target = 'cgiresults';
          document.$form.submit();
      }
   --></script>
END_OF_BLOCK

print "</head>\n\n";
print "<body background=$CRDImagePath/background.gif text=$CRDFontColor link=#0000ff vlink=#0000ff alink=#0000ff topmargin=0 leftmargin=0><center>\n";
print "<font face=$CRDFontFace color=$CRDFontColor>\n";

print "<form name=$form action=$ENV{SCRIPT_NAME} method=post>\n";
print "<input type=hidden name=username value=$username>\n";
print "<input type=hidden name=userid value=$userid>\n";
print "<input type=hidden name=schema value=$schema>\n";
print "<input type=hidden name=server value=$Server>\n";
print "<input type=hidden name=command value=$command>\n";
print "<input type=hidden name=id value=$documentid>\n";

if ($command eq 'menu') {
    print "<br><table border=0 width=750>\n";
    print &writeTitleBar(userName => $username, userID => $userid, schema => $schema, title => "Final CRD Report");
    print ReportSelectionPage(userName => $username, userID => $userid, schema => $schema, dbh => $dbh);
} elsif ($command eq 'finalreport') {
    my @timedata = localtime(time);
    my ($sec,$min,$hour,$day, $month, $year) = (localtime)[0,1,2,3,4,5];
    $year = $year + 1900;
    $month++;
    my $foldername = "$year-" . lpadzero($month,2) . "-" . lpadzero($day,2) . "_" . lpadzero($hour,2) . "-" . lpadzero($min,2) . "-" . lpadzero($sec,2);
    my $ampm = 'AM';
    if ($hour > 12) {
        $ampm = "PM";
        $hour = lpadzero(($hour-12),2);
    }
    my $runstarttime = uc(get_date(lpadzero($month,2) . "/" . lpadzero($day,2) . "/" . $year)) . " " . lpadzero($hour,2) . ":" . lpadzero($min,2) . ":" . lpadzero($sec,2) . $ampm;
    my $selectedtype = $crdcgi->param('finaltype');
    my $selecteddate = $crdcgi->param('startdate_year') . lpadzero($crdcgi->param('startdate_month'),2) . lpadzero($crdcgi->param('startdate_day'),2);
    print "<br><table border=0 width=750>\n";
    print "<tr><td align=center>\n";
    print &writeTitleBar(userName => $username, userID => $userid, schema => $schema, title => "Final CRD Report");
    print ReportSelectionPage(userName => $username, userID => $userid, schema => $schema, dbh => $dbh);
    print "</td></tr><tr><td align=center><hr width=75%></td></tr>\n";
    print "<tr><td align=center>Selection Type: ";
    if ($selectedtype eq 'all') {
        print "All";
    } elsif ($selectedtype eq 'nepa') {
        print "Approved through " . &FirstReviewName;
    } elsif ($selectedtype eq 'approved') {
        print "Approved";
    } elsif ($selectedtype eq 'bincoordinator') {
        print "Approved through Bin Coordinator";
    } elsif ($selectedtype eq 'cronly') {
        print "Comments/Responses Only";
    } elsif ($selectedtype eq 'scr') {
        print "SCR";
    } elsif ($selectedtype eq 'date') {
        print "Approved since: " . $crdcgi->param('startdate_month') . "/" . $crdcgi->param('startdate_day') . "/" . $crdcgi->param('startdate_year');
    }
    print "</td></tr>\n";
    print "<tr><td>\n";
    print "<table border=0 align=center>\n" .
              "<tr><td align=center>Elapsed Time:</td><td>" . nbspaces(20) . "</td><td align=center>Current:</td><td>" . nbspaces(20) . "</td><td align=center>Status:</td></tr>\n" .
              "<tr><td align=center><input type=text size=8 name=clock readonly onClick=\"this.blur();\"></td><td> </td>\n" .
              "<td align=center><input type=text size=12 name=current readonly onClick=\"this.blur();\"></td><td> </td>\n" .
              "<td align=center><input type=text size=8 name=status readonly value='Working' onClick=\"this.blur();\"></td></tr>\n" .
          "</td></tr></table>\n";
    print "</td></tr>\n";
    print "<input type=hidden name=foldername value=\"$foldername\">\n";
    print "<input type=hidden name=runstarttime value=\"$runstarttime\">\n";
    print "<input type=hidden name=selectedtype value=$selectedtype>\n";
    print "<input type=hidden name=selecteddate value=$selecteddate>\n";
    print "<input type=hidden name=displaycommentnumber value=" . ((defined($crdcgi->param("showcommentnumber"))) ? $crdcgi->param("showcommentnumber") : "F") . ">\n";
    print "<input type=hidden name=displaycommentors value=" . ((defined($crdcgi->param("showcommentors"))) ? $crdcgi->param("showcommentors") : "F") . ">\n";
    print "<input type=hidden name=crdidsourceval value=" . $crdcgi->param('crdidsource') . ">\n";
    print "<input type=hidden name=crdperiod2 value=" . $crdcgi->param('crdperiod') . ">\n";
    print "" .
       "<script language=javascript><!--\n" .
       "\n" .
       "        var seconds = 0;\n" .
       "        var minutes = 0;\n" .
       "        var hours = 0;\n" .
       "        var timerID;\n" .
       "        var timerRunning = true;\n" .
       "        \n" .
       "        function displayTime() {\n" .
       "            var temp;\n" .
       "            if (seconds >= 59) {\n" .
       "                seconds = 0;\n" .
       "                if (minutes >= 59) {\n" .
       "                    minutes = 0;\n" .
       "                    hours++;\n" .
       "                } else {\n" .
       "                    minutes++;\n" .
       "                }\n" .
       "            } else {\n" .
       "                seconds++;\n" .
       "            }\n" .
       "            if (seconds < 10) {var ss = '0'} else {var ss = ''}\n" .
       "            if (minutes < 10) {var ms = '0'} else {var ms = ''}\n" .
       "            if (hours < 10) {var hs = '0'} else {var hs = ''}\n" .
       "            temp = hs + hours + ':' + ms + minutes + ':' + ss + seconds;\n" .
       "            document.$form.clock.value = temp;\n" .
       "            if (timerRunning) {\n" .
       "                timerID = setTimeout(\"displayTime()\", 1000);\n" .
       "            }\n" .
       "        }\n" .
       "\n" .
       "        function displayDocument(docpath) {\n" .
       "            var myDate = new Date();\n" .
       "            var winName = myDate.getTime();\n" .
       "            if (document.$form.status.value == 'Finished') {\n" .
       "                var newwin = window.open(docpath,winName);\n" .
       "            } else {\n" .
       "                alert('Report is not yet finished');\n" .
       "            }\n" .
       "        }\n" .
       "        displayTime();\n" .
       "        submitFormCGIResults('$form','genfinalreport','$foldername');\n" .
       "\n" .
       "//--></script>\n";
        print "<tr><td align=center><input type=button name=disprep value='Display Report' onClick=\"displayDocument('$CRDTempReportPath/final_crd/$foldername/toc.htm');\">\n";
    
} elsif ($command eq 'genfinalreport') {
    my $foldername = $crdcgi->param('foldername');
    if (!(open (FH0, "| ./File_Utilities.pl --command=mkdir --fullFilePath=$CRDFullTempReportPath/final_crd/$foldername --protection=0777"))) {
        print STDERR "\nError in directory creation: $CRDFullTempReportPath/final_crd/$foldername\n";
        die "Unable to create directory $CRDFullTempReportPath/$foldername\n";
    }
    close (FH0);
    if (open (FH0, "| ./File_Utilities.pl --command=writeFile --fullFilePath=$CRDFullTempReportPath/final_crd/$foldername/toc.htm --protection=0777")) {
        print FH0 "<html>\n";
        print FH0 "<head>\n";
        print FH0 "<title>Final $CRDType Report</title>\n";
        print FH0 "</head>\n\n";
        print FH0 "<body background=$CRDImagePath/background.gif text=$CRDFontColor link=#0000ff vlink=#0000ff alink=#0000ff topmargin=0 leftmargin=0><center>\n";
        print FH0 "<font face=$CRDFontFace color=$CRDFontColor>\n";
        print "\n\n<!-- crdidsource = '" . $crdcgi->param('crdidsourceval') . "' -->\n\n";
        print FH0 gen_report('schema' => $schema, 'dbh' => $dbh, 'foldername' => $foldername, 'runstarttime' => $crdcgi->param('runstarttime'), 'showCommentors' => $crdcgi->param('displaycommentors'), 'CRDIDSource' => $crdcgi->param('crdidsourceval'), 'CRDPeriod' => $crdcgi->param('crdperiod2'));
        print FH0 "\n</center>\n";
        print FH0 "</font></body>\n</html>\n";
        close (FH0);
        my $urllocation = "$CRDDocPath/$foldername";
        print "<script language=JavaScript>\n";
        print "    parent.main.timerRunning=false;\n";
        print "    parent.main.$form.current.value=' ';\n";
        print "    parent.main.$form.status.value='Finished';\n";
        print "    alert ('Report Finished');\n";
        print "</script>\n";
        
        my $selectiontype = $crdcgi->param('selectedtype');
        if ($selectiontype eq 'date' || $selectiontype eq 'cronly') {
            my $selectiondate = $crdcgi->param('selecteddate');
            if (open (FH0, "| ./File_Utilities.pl --command=writeFile --fullFilePath=$CRDFullTempReportPath/final_crd/$foldername/title.htm --protection=0777")) {
                if ($selectiontype eq 'date') {
                    print FH0 "Approved since: " . uc(get_date(substr($selectiondate,4,2) . "/" . substr($selectiondate,6,2) . "/" . substr($selectiondate,0,4)));
                }
                if ($selectiontype eq 'cronly') {
                    print FH0 "Comments/Responses Only (No SCR's)";
                }
                close (FH0);
            } else {
                print "Error opening file $CRDFullDocPath/$foldername/title.htm<br>\n";
            }
        }
        
    } else {
        print "Error opening file $CRDFullDocPath/$foldername/toc.htm<br>\n";
    }
} else {
    print "<table border=0 width=670><tr><td>\n";
    print "Command: $command";
    print "</td></tr>\n";
}

print "</table></form>\n";
print "\n</center>\n";
print "<script language=javascript>\n<!--\nvar mytext ='$errorstr';\nalert(unescape(mytext));\n//-->\n</script>\n" if ($errorstr);
print "</font></body>\n</html>\n";
&db_disconnect($dbh);
exit();
