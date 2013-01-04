#!/usr/local/bin/newperl -w
#
# $Source: /usr/local/www/gov.ymp.intradev/rcs/crd/perl/RCS/ad_hoc_reports.pl,v $
#
# $Revision: 1.49 $
#
# $Date: 2008/03/07 20:51:12 $
#
# $Author: atchleyb $
#
# $Locker:  $
#
# $Log: ad_hoc_reports.pl,v $
# Revision 1.49  2008/03/07 20:51:12  atchleyb
# CREQ00054 - updated to allow option of search filters for comment text, response text, document remarks, and comment text
#
# Revision 1.48  2002/02/20 16:26:19  atchleyb
# removed depricated function use named parameters and changed the html header
#
# Revision 1.47  2001/12/04 19:41:35  atchleyb
# fixed javascript form validation bug that allowed nonnumerics to be entered for document and comment numbers
#
# Revision 1.46  2001/11/30 17:31:59  atchleyb
# fixed bug in sql for technical reviewer item
#
# Revision 1.45  2001/11/27 17:37:19  atchleyb
# updated to not report duplicates of summerized comments when do not display summerized comments is selected
#
# Revision 1.44  2001/11/02 18:22:41  atchleyb
# changed javascript submit functions to not reset values after submition
# changed alert box code to handle single quotes
#
# Revision 1.43  2001/10/23 20:23:31  atchleyb
# added commentor ID to be printed after name
#
# Revision 1.42  2001/10/10 16:24:42  atchleyb
# changed logic on if statement that determined if evaluation_factor was set
#
# Revision 1.41  2001/10/09 16:48:46  atchleyb
# added new option to evaluation factor item
#
# Revision 1.40  2001/10/05 23:48:23  atchleyb
# added evaluation factor to comment document reports
#
# Revision 1.39  2001/09/21 21:34:07  atchleyb
# fixed bug in usesubbins in comments, it was defaulting to use when it should default to not use
#
# Revision 1.38  2001/08/09 15:54:40  atchleyb
# changed item for comments report from all documents >= number to a range of document ids
#
# Revision 1.37  2001/08/02 20:04:52  atchleyb
# added option to comments reports to only list documents over a given number SCR #17
#
# Revision 1.36  2001/05/24 19:56:51  atchleyb
# modified response status item to use a dual select so that multiple status's could be selected
#
# Revision 1.35  2001/05/17 16:03:34  atchleyb
# modified to use &FirstReviewName instead of NEPA
#
# Revision 1.34  2001/05/17 15:57:29  atchleyb
# updated to use RelatedCRDText fuction from DocumentSpecific.pm
#
# Revision 1.33  2001/05/16 23:11:09  atchleyb
# changed clear all selections function to clear the limit text check box
#
# Revision 1.32  2001/05/16 22:59:14  atchleyb
# changed the default for limit text to first line to not be checked
#
# Revision 1.31  2001/05/16 21:02:57  atchleyb
# changed to use the lastSubmittedText funciton
#
# Revision 1.30  2001/04/30 23:53:51  atchleyb
# added item for hasissues flag from comments
#
# Revision 1.29  2001/04/02 22:28:38  atchleyb
# replaced 'date response due' with 'date response last updated'
#
# Revision 1.28  2001/03/19 23:57:31  atchleyb
# added option on item 'summary' to allow selection of summarized or not summarized
#
# Revision 1.27  2001/03/14 23:28:39  atchleyb
# added an item for for 'wasrescanned' from document
#
# Revision 1.26  2000/12/07 23:15:55  atchleyb
# fixed parameter name for server
#
# Revision 1.25  2000/12/07 22:59:30  atchleyb
# added code to handle multiple oracle servers
#
# Revision 1.24  2000/11/02 20:56:58  atchleyb
# fixed a problem when ad_hoc_reports.pl is called from another script
#
# Revision 1.23  2000/10/13 20:22:40  atchleyb
# fixed incorectly labeled review text, it was labeled as comment
#
# Revision 1.22  2000/10/11 22:24:29  atchleyb
# added item for nepa reviewer
# added more debug code, will now print contents of item hash to error log
#
# Revision 1.21  2000/10/05 15:46:21  atchleyb
# Reverted to rev 1.18
# fixed javascript bug in date ranfe validation
#
# Revision 1.20  2000/10/04 21:27:56  atchleyb
# fixed javascript bug on date range checking
#
# Revision 1.19  2000/06/27 23:17:54  naydenoa
# added use of module Miscellaneous.pm
# deleted processError, isBinMember (never called?), now in Miscellaneous
# deleted getReportDateTime, getBinTree (in Miscellaneous)
#
# Revision 1.18  2000/06/21 23:00:11  atchleyb
# fixed sql bug in where clause for technical_reviewer
#
# Revision 1.17  2000/06/20 19:55:44  atchleyb
# removed all uses of table views
#
# Revision 1.16  2000/06/19 19:47:38  atchleyb
# changed display of SCR numbers to be padded to four digits.
#
# Revision 1.15  2000/05/18 17:15:04  atchleyb
# changed label of technical reviewer list to assigned technical reviewer
#
# Revision 1.14  2000/05/17 20:44:26  atchleyb
# fixed problem with technical reviewer text only getting first one
# added technical review to status line
#
# Revision 1.13  2000/05/03 22:57:15  atchleyb
# added item for technical review text and status
#
# Revision 1.12  2000/04/24 22:13:27  atchleyb
# added new report item - technical reviewer
# updated ui look
# added option to select commentor by fax area code
#
# Revision 1.11  2000/04/13 16:38:26  atchleyb
# modified javascript to have each report come up in its own window
#
# Revision 1.10  2000/04/11 23:47:10  atchleyb
# added added a finish to some cursors
#
# Revision 1.9  2000/04/07 19:54:45  atchleyb
# changed labels for called custom reports
#
# Revision 1.8  2000/04/04 22:22:21  atchleyb
# changed way script handels commentor only reports
# changed the way status is checked, do not check status in responsce version if dupsimstatus is set to duplicate
#
# Revision 1.7  2000/04/03 17:49:33  atchleyb
# changed selection screen into caller customizable
# made changes to allow commenor table to be selected by itself
#
# Revision 1.6  2000/03/24 23:09:13  atchleyb
# added section for enclosures
# added section for response status
# fixed bug on displaying duplicate comments
#
# Revision 1.5  2000/03/24 16:30:46  atchleyb
# fixed display of responses when only original text is available
# added features for using ad_hoc_reports from other scripts
#
# Revision 1.4  2000/03/08 22:15:56  atchleyb
# added feature to only display document information
#
# Revision 1.3  2000/02/22 19:58:04  atchleyb
# fixed bug in selecting by bin coordinator and response writer
#
# Revision 1.2  2000/02/11 22:32:05  atchleyb
# changed default sort category
# added form verification
#
# Revision 1.1  2000/02/11 17:05:06  atchleyb
# Initial revision
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
use Sections;
use DBI;
use DBD::Oracle qw(:ora_types);
use CGI qw(param);
use Carp;

my $crdcgi = new CGI;
my $username = $crdcgi->param("username");
my $userid = $crdcgi->param("userid");
my $schema = $crdcgi->param("schema");
my $Server = $crdcgi->param("server");
if (!(defined($Server))) {$Server=$CRDServer;}
my $documentid = $crdcgi->param("id");
if (!(defined($documentid))) {$documentid='comment';}
my $command = $crdcgi->param("command");
if (!(defined($command))) {$command='adhocsetup';}
&checkLogin ($username, $userid, $schema);
$ENV{SCRIPT_NAME} =~ m%(.*/)(.*)\..*$%;
my $path = $1;
my $form = $2;
my $pageNum = 1;
my $dbh;
my $errorstr = "";
my $underDevelopment = &nbspaces(3) . "<b><font size=2 color=#ff0000>(currently under development)</font></b>";
my $printHeaderHelp = "<table border=1 width=750 align=center><tr><td><font size=-1><b><i>To set report page headers and footers for printing, select Page Setup... from the File menu, remove the text from the Footer box and replace the text in the Header box with the following:</i> <br><center>&d &t &b&bPage &p of &P</center><i>Then click on OK.</i></b></font></td></tr></table>\n";
my %tables;
my %items;
my @joins;
my %fields;
my $refval;
my @temparray;
my $CRDRelatedText = RelatedCRDText;
my $CRDRelatedTextShort = RelatedCRDText(short => 'T');
#tie my %lookup_values, "Tie::IxHash";
#tie my %lookup_values2, "Tie::IxHash";

# tables description
# 'table id' => ['selected', [ field names ], 'table name', 'table alias']
%tables = (
    'bin' => ['F', ["id","name","coordinator","nepareviewer","techreviewpolicy"], 'bin', 'bin'],
    'commentor' => ['F', (["id","lastname","firstname","middlename","title","suffix","address","city","state", 
                    "country","postalcode","areacode","phonenumber","phoneextension","faxareacode","faxnumber",
                    "faxnumber","faxextension","email","organization","position","affiliation"]), 'commentor', 'cmntr'],
    'comments'  => ['F', (["document","commentnum","text","startpage","dateassigned","datedue","dateapproved","hascommitments", 
                    "changeimpact","changecontrolnum","createdby","datecreated","proofreadby","proofreaddate","bin",
                    "doereviewer","summary","dupsimstatus","dupsimdocumentid","dupsimcommentid","hasissues","summaryapproved"]), 'comments', 'com'],
    'comments_remark' => ['F', (["document","commentnum","remarker","dateentered","text"]), 'comments_remark', 'comr'],
    'document'  => ['F', (["id","documenttype","datereceived","enteredby1","entrydate1","enteredby2","entrydate2","proofreadby", 
                    "proofreaddate","dupsimstatus","dupsimid","hassrcomments","haslacomments","has960comments","hasenclosures",
                    "isillegible","commentsentered","pagecount","addressee","signercount","namestatus","commentor",
                    "wasrescanned","evaluationfactor"]), 'document', 'doc'],
    'document_remark' => ['F', (["document","remarker","dateentered","text"]), 'document_remark', 'docr'],
    'response_version' => ['F', (["document","commentnum","version","status","originaltext","lastsubmittedtext","enteredby","entrydate","proofreadby", 
                           "proofreaddate","responsewriter","techeditor","dateupdated","summary","dupsimstatus","dupsimdocumentid",
                           "dupsimcommentid"]), 'response_version', 'rv'],
    'technical_review' => ['F', (["document","commentnum","reviewer","version","text","dateupdated","status",]), 'technical_review', 'tr']
);

#
##################
#
# items description
# 'item id' => ['selected', 'sort by', 'sort code', [ required tables ], { parameter hash }, 'has selections', { forms }]
%items = (
    'cdidcid'           => ['F', 'F', 'doc.id,com.commentnum', ['document','comments'], {'document' => '', 'commentnum' => '', 'use_all_docs' => 'F'}, 'F', {'comment' => 'T','document' => 'F','commentor' => 'F'}],
    'docid'             => ['F', 'F', 'doc.id', ['document'], {'document' => '', 'startid' => '', 'endid' => '', 'use_all_docs' => 'F'}, 'F', {'comment' => 'F','document' => 'T','commentor' => 'F'}],
    'docidrange'        => ['F', 'F', 'doc.id', ['document'], {'document' => '', 'startid' => '', 'endid' => ''}, 'F', {'comment' => 'T','document' => 'F','commentor' => 'F'}],
    'doctype'           => ['F', 'F', 'doc.documenttype', ['document'], {'selection' => ''}, 'F', {'comment' => 'T','document' => 'T','commentor' => 'F'}],
    'binid'             => ['F', 'F', 'bin.name', ['bin', 'comments'], {'binid' => '', 'subBins' => 'F', 'coordinator' => 'F', 'nepa' => 'F'}, 'F', {'comment' => 'T','document' => 'F','commentor' => 'F'}],
    'bincoordinator'    => ['F', 'F', '', ['bin','comments'], {'userlist' => [], 'details' => ''}, 'F', {'comment' => 'T','document' => 'F','commentor' => 'F'}],
    'responsewriter'    => ['F', 'F', '', ['comments','response_version'], {'userlist' => [], 'details' => ''}, 'F', {'comment' => 'T','document' => 'F','commentor' => 'F'}],
    'technicalreviewer' => ['F', 'F', '', ['comments'], {'userlist' => [], 'details' => ''}, 'F', {'comment' => 'T','document' => 'F','commentor' => 'F'}],
    'nepareviewer'      => ['F', 'F', '', ['comments','bin'], {'userlist' => [], 'details' => ''}, 'F', {'comment' => 'T','document' => 'F','commentor' => 'F'}],
    'responsestatus'    => ['F', 'F', '', ['comments','response_version'], {'list' => []}, 'F', {'comment' => 'T','document' => 'F','commentor' => 'F'}],
    'commentor'         => ['F', 'F', 'cmntr.lastname,cmntr.firstname,cmntr.middlename', ['commentor','document'], {'commentor' => '', 'city' => '', 'state' => '', 'organization' => '', 'affiliation' => '', 'postalcode' => '', 'areacode' => '', 'faxareacode' => '', 'details' => 'F'}, 'F', {'comment' => 'T','document' => 'T','commentor' => 'F'}],
    'commentorname'     => ['F', 'F', 'cmntr.lastname,cmntr.firstname,cmntr.middlename', ['commentor'], {'commentor' => ''}, 'F', {'comment' => 'F','document' => 'F','commentor' => 'T'}],
    'commentoraddress'  => ['F', 'F', 'cmntr.city,cmntr.state', ['commentor'], {'city' => '', 'state' => '', 'postalcode' => ''}, 'F', {'comment' => 'F','document' => 'F','commentor' => 'T'}],
#    'commentoraddress'  => ['F', 'F', 'cmntr.city,cmntr.state', ['commentor'], {'city' => '', 'state' => '', 'postalcode' => []}, 'F', {'comment' => 'F','document' => 'F','commentor' => 'T'}],
    'commentororg'      => ['F', 'F', 'cmntr.organization', ['commentor'], {'organization' => ''}, 'F', {'comment' => 'F','document' => 'F','commentor' => 'T'}],
    'commentoraff'      => ['F', 'F', 'cmntr.affiliation', ['commentor'], {'affiliation' => ''}, 'F', {'comment' => 'F','document' => 'F','commentor' => 'T'}],
    'commentorphone'    => ['F', 'F', 'cmntr.areacode,cmntr.phonenumber,cmntr.phoneextension', ['commentor'], {'areacode' => '', 'faxareacode' => ''}, 'F', {'comment' => 'F','document' => 'F','commentor' => 'T'}],
    'commentoremail'    => ['F', 'F', '', ['commentor'], {}, 'F', {'comment' => 'F','document' => 'F','commentor' => 'T'}],
    'commentorposition' => ['F', 'F', '', ['commentor'], {}, 'F', {'comment' => 'F','document' => 'F','commentor' => 'T'}],
    'datereceived'      => ['F', 'F', 'doc.datereceived', ['document'], {'startdate' => '', enddate => ''}, 'F', {'comment' => 'T','document' => 'T','commentor' => 'F'}],
    'dateassigned'      => ['F', 'F', 'com.dateassigned', ['comments'], {'startdate' => '', enddate => ''}, 'F', {'comment' => 'T','document' => 'F','commentor' => 'F'}],
    'dateapproved'      => ['F', 'F', 'com.dateapproved', ['comments'], {'startdate' => '', enddate => ''}, 'F', {'comment' => 'T','document' => 'F','commentor' => 'F'}],
    'dateupdated'       => ['F', 'F', 'rv.dateupdated', ['comments','response_version'], {'startdate' => '', enddate => ''}, 'F', {'comment' => 'T','document' => 'F','commentor' => 'F'}],
    'addressee'         => ['F', 'F', 'doc.addressee', ['document'], {'id' => ''}, 'F', {'comment' => 'F','document' => 'T','commentor' => 'F'}],
    'evaluationfactor'  => ['F', 'F', 'doc.evaluationfactor', ['document'], {'addressee' => ''}, 'F', {'comment' => 'T','document' => 'T','commentor' => 'F'}],
    'srcomments'        => ['F', 'F', '', ['document'], {'selection' => ''}, 'F', {'comment' => 'T','document' => 'T','commentor' => 'F'}],
    'lacomments'        => ['F', 'F', '', ['document'], {'selection' => ''}, 'F', {'comment' => 'T','document' => 'T','commentor' => 'F'}],
    '960comments'       => ['F', 'F', '', ['document'], {'selection' => ''}, 'F', {'comment' => 'T','document' => 'T','commentor' => 'F'}],
    'wasrescanned'      => ['F', 'F', '', ['document'], {'selection' => ''}, 'F', {'comment' => 'T','document' => 'T','commentor' => 'F'}],
    'enclosures'        => ['F', 'F', '', ['document'], {'selection' => ''}, 'F', {'comment' => 'T','document' => 'T','commentor' => 'F'}],
    'changeimpact'      => ['F', 'F', '', ['comments'], {'selection' => ''}, 'F', {'comment' => 'T','document' => 'F','commentor' => 'F'}],
    'commitments'       => ['F', 'F', '', ['comments'], {'selection' => ''}, 'F', {'comment' => 'T','document' => 'F','commentor' => 'F'}],
    'hasissues'         => ['F', 'F', '', ['comments'], {'selection' => ''}, 'F', {'comment' => 'T','document' => 'F','commentor' => 'F'}],
    'commenttext'       => ['F', 'F', '', ['comments'], {'searchtext' => ''}, 'F', {'comment' => 'T','document' => 'F','commentor' => 'F'}],
    'response'          => ['F', 'F', '', ['comments', 'response_version'], {'searchtext' => ''}, 'F', {'comment' => 'T','document' => 'F','commentor' => 'F'}],
    'techreviewtext'    => ['F', 'F', '', ['comments'], {}, 'F', {'comment' => 'T','document' => 'F','commentor' => 'F'}],
    'docremarks'        => ['F', 'F', '', ['document', 'document_remark'], {'searchtext' => ''}, 'F', {'comment' => 'T','document' => 'T','commentor' => 'F'}],
    'comremarks'        => ['F', 'F', '', ['comments', 'comments_remark'], {'searchtext' => ''}, 'F', {'comment' => 'T','document' => 'F','commentor' => 'F'}],
    'page'              => ['F', 'F', '', ['comments'], {}, 'F', {'comment' => 'T','document' => 'F','commentor' => 'F'}],
    'summary'           => ['F', 'F', '', ['comments'], {'selection' => ''}, 'F', {'comment' => 'T','document' => 'F','commentor' => 'F'}],
    'dupcomment'        => ['F', 'F', '', ['comments'], {}, 'F', {'comment' => 'T','document' => 'F','commentor' => 'F'}]
);

# joins description
# ['table 1', 'table 2', 'sql join', 'optional order by']
@joins = (
    ['document','comments','doc.id = com.document', 'doc.id,com.commentnum'],
    ['bin','comments','bin.id(+) = com.bin', ''],
    ['commentor', 'document', 'doc.commentor = cmntr.id(+)', ''],
    ['document','document_remark', 'doc.id = docr.document(+)', ''],
    ['comments', 'comments_remark', "com.document||'-'||com.commentnum = comr.document||'-'||comr.commentnum", ''],
    ['response_version', 'comments', "com.document = rv.document(+) AND com.commentnum = rv.commentnum(+) AND rv.status NOT IN (10,11,12,13)", 'rv.version DESC']
);
#    ['technical_review', 'comments', "com.document = tr.document(+) AND com.commentnum = tr.commentnum(+) AND tr.status <> 4", 'tr.version DESC']

%fields = (
);


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


sub processError {
   my %args = (
      @_,
   );
   my $error = &errorMessage($dbh, $username, $userid, $schema, $args{activity}, $@);
   $error =  ('_' x 100) . "\n\n" . $error if ($errorstr ne "");
   $error =~ s/\n/\\n/g;
   $error =~ s/'/%27/g;
   $errorstr .= $error;
}


sub dumpItems {
    my $outputstring = '';
    
    $outputstring .= "*\n** Ad Hoc Report Item Keys ** ";
    
    foreach my $key (sort keys %items) {
      $outputstring .= "## $key - $items{$key}[0], $items{$key}[1], $items{$key}[5], parameters{ ";
      if ($items{$key}[5] eq 'T') {
          foreach my $key2 (sort keys %{ $items{$key}[4] }) {
              if (ref($items{$key}[4]{$key2}) eq 'ARRAY') {
                  $outputstring .= "$key2 => [@{ $items{$key}[4]{$key2} }], ";
              } elsif (ref($items{$key}[4]{$key2}) eq 'HASH') {
                  $outputstring .= "$key2 => {";
                  foreach my $key3 (sort keys %{ $items{$key}[4]{$key2} }) {
                      $outputstring .= "$key3 => $items{$key}[4]{$key2}{$key3}, ";
                  }
                  $outputstring .= "}, ";
              } else {
                  $outputstring .= "$key2 => $items{$key}[4]{$key2}, ";
              }
          }
          chop $outputstring;
          chop $outputstring;
      }
      $outputstring .= "} ";
    
    }
    $outputstring .= "\n*\n";
    
    return ($outputstring);
}


sub getReportDateTime {
    my @timedata = localtime(time);
    return(uc(get_date()) . " " . lpadzero($timedata[2],2) . ":" . lpadzero($timedata[1],2) . ":" . lpadzero($timedata[0],2));
}


# routine to generate a hash of lookup/values from a table
sub get_unique_values {
    my $dbh = $_[0];
    my $schema = $_[1];
    my $table = $_[2];
    my $lookups = $_[3];
    my $wherestatement='';      # optional
    if (defined($_[4])) {$wherestatement = $_[4];} # optional
    tie my %lookup_values, "Tie::IxHash";
    #%lookup_values = {};
    my @values;
    my $csr;
    my $sqlquery = "select UNIQUE $lookups from $schema.$table";
    if ($wherestatement gt " ") {
        $sqlquery .= " where $wherestatement";
    }
    $csr = $dbh->prepare($sqlquery);
    $csr->execute;
    while (@values = $csr->fetchrow_array) {
        $lookup_values{$values[0]} = $values[0];
    }
    $csr->finish;
    return (%lookup_values);
}


# routine to generate a hash of lookup/values from a table
sub get_unique_commentor_values {
    my $dbh = $_[0];
    my $schema = $_[1];
    my $lookup = $_[2];
    my $wherestatement='';      # optional
    if (defined($_[3])) {$wherestatement = $_[3];} # optional
    tie my %lookup_values, "Tie::IxHash";
    #%lookup_values = {};
    my @values;
    my $csr;
    #my $sqlquery = "SELECT UNIQUE cmtr.$lookup FROM $schema.commentor cmtr, $schema.document doc, $schema.comments com ";
    #$sqlquery .= "WHERE cmtr.id=doc.commentor AND doc.id=com.document ";
    my $sqlquery = "SELECT UNIQUE cmtr.$lookup FROM $schema.commentor cmtr, $schema.document doc ";
    $sqlquery .= "WHERE cmtr.id=doc.commentor ";
    if ($wherestatement gt " ") {
        $sqlquery .= " AND $wherestatement";
    }
    $csr = $dbh->prepare($sqlquery);
    $csr->execute;
    while (@values = $csr->fetchrow_array) {
        $lookup_values{$values[0]} = $values[0];
    }
    $csr->finish;
    return (%lookup_values);
}


sub getBinTree {
    # generate a list of bins that have 'root_bin' as a parent, the list is terminated with a 0
    my $hashref = $_[0];
    my %args = %$hashref;
    my $outputstring = '';
    
    my $sqlquery = "SELECT UNIQUE id FROM $args{'schema'}.bin START WITH id = $args{'root_bin'} CONNECT BY PRIOR id = parent";
    my $csr = $args{'dbh'}->prepare($sqlquery);
    my $status = $csr->execute;
    my @values;
    while (@values = $csr->fetchrow_array) {
        $outputstring .= "$values[0],";
    }
    $csr->finish;
    $outputstring = "0," . $outputstring . "0";
    return ($outputstring);
    
}


sub isBinMember {
    my %args = (
        run_date => getReportDateTime,
        dbh => '',
        schema => '',
        testUser => 0,
        binList => '0',
        @_,
    );
    my @row;
    my @values;
    my $bincount = 0;

    @row = $args{'dbh'}->selectrow_array("SELECT count(*) FROM $args{'schema'}.bin WHERE (coordinator=$args{'testUser'} OR nepareviewer=$args{'testUser'}) AND (id IN ($args{'binList'}))");
    @values = $args{'dbh'}->selectrow_array("SELECT UNIQUE count(*) FROM $args{'schema'}.default_tech_reviewer WHERE (reviewer = $args{'testUser'}) AND (bin IN ($args{'binList'})) AND (bin NOT IN (SELECT id FROM $args{'schema'}.bin WHERE coordinator=$args{'testUser'} OR nepareviewer=$args{'testUser'}))");

    $bincount = $row[0] + $values[0];
    
    return ((($bincount >= 1) ? 1 : 0));
}


# routinte to remove html tags from a string
sub htmlStrip {
    my $charString = $_[0];
    $charString =~ s/\<(\w|\s|=|-|\/)*\>/ /g;
    return ($charString);
}


#
##################
#

sub AdHocSelectionPage {
    my %args = (
        run_date => getReportDateTime,
        dbh => '',
        schema => '',
        type => 'comment',
        @_,
    );
    
    my $outputstring = '';
    my %items;
    my $refvar = $args{'items'};
    %items = %$refvar;
    tie my %lookup_values, "Tie::IxHash";
    tie my %lookup_values2, "Tie::IxHash";
    #%lookup_values = {};
    #%lookup_values2 = {};
    #%lookup_values = ();
    #%lookup_values2 = ();
    my $message ='';
    
    eval {
        $outputstring .= "<tr><td>\n$printHeaderHelp</td></tr>\n";
        $outputstring .= "<tr><td>\n";
        $outputstring .= "<br>Report Title: &nbsp <input type=text size=40 name=reporttitle><br><br>\n";
    
        $outputstring .= "<table border=1 cellpadding=10 width=750><tr>\n";
        $outputstring .= "<td valign=top align=center><b>Include<br>in<br>Report</b><br><font size=-1><br><a href=\"javascript:setIncludes(true);\">Select&nbspAll</a><br><br><a href=\"javascript:setIncludes(false);\">Clear All</a></font></td>\n";
        $outputstring .= "<td valign=top><b>Sort</b><br>\n";
        $outputstring .= "<input type=radio checked name=sortdirection value=assending>asc<br>\n";
        $outputstring .= "<input type=radio name=sortdirection value=desending>desc</td>\n";
        $outputstring .= "<td valign=top><b>Description/Qualifiers/Selection Criteria</b><br>\n";
        $outputstring .= "Comments will be selected if they match <input type=radio checked name=report_boolean value=all>all or\n";
        $outputstring .= "<input type=radio name=report_boolean value=any>any of the entered qualifiers.<br>\n";
        if ($args{type} ne 'commentor') {
            $outputstring .= "Limit text blocks to the first line. <input type=checkbox name=text_limit value='T'><br>\n";
        } else {
            $outputstring .= "<input type=hidden name=text_limit value='T'>\n";
        }
        $outputstring .= "<i>Entering values into the fields below will limit your report to comments that match the entered values,\n";
        $outputstring .= "even if 'Include in Report' is not selected for that field.\n";
        $outputstring .= "Too many qualified fields, when 'all' is selected above, may cause the resulting report to be empty.\n";
        $outputstring .= "<br><br><center><font size=-1><a href=\"javascript:clearForm();\">Clear all Selections</a></font></center></i></td></tr>\n";

#
##################
#

        if ($items{'cdidcid'}[6]{$args{type}} eq 'T') {
            $outputstring .= "<tr><td valign=top align=center><input type=checkbox checked readonly name=doc_selected value='T' onclick=\"document.$form.doc_selected.checked=true\"></td>\n";
            $outputstring .= "<td valign=top align=center><input type=radio checked name=sortorder value=doc_sort></td><td valign=top>\n";
            $outputstring .= "Comment Document ID: <b>$CRDType</b><input type=text size=6 maxlength=6 name=documentid> &nbsp\n";
            if ($args{type} =~ /comment|commentor/) {
                $outputstring .= "Comment ID: <input type=text size=4 maxlength=4 name=commentnum><br>\n";
                $outputstring .= "Include Documents with no Comments <input type=checkbox checked name=use_all_docs value='T'>" . nbspaces(6) . "\n";
            }
            #if ($args{type} =~ /document/) {
            #    $outputstring .= "<input type=hidden name=use_all_docs value='T'>\n";
            #    $outputstring .= "<input type=hidden name=use_only_docs value='T'>\n";
            #}
            $outputstring .= "</td></tr>\n";
        }

        if ($items{'docid'}[6]{$args{type}} eq 'T') {
            $outputstring .= "<tr><td valign=top align=center><input type=checkbox checked readonly name=doc_selected value='T' onclick=\"document.$form.doc_selected.checked=true\"></td>\n";
            $outputstring .= "<td valign=top align=center><input type=radio checked name=sortorder value=doc_sort></td><td valign=top>\n";
            $outputstring .= "Documents Between &nbsp; <b>$CRDType</b> <input type=text size=6 maxlength=6 name=startingdocid>" . nbspaces(3);
            $outputstring .= "and &nbsp; <b>$CRDType</b> <input type=text size=6 maxlength=6 name=endingdocid>\n";
            #if ($args{type} =~ /document/) {
                $outputstring .= "<input type=hidden name=use_all_docs value='T'>\n";
                $outputstring .= "<input type=hidden name=use_only_docs value='T'>\n";
            #}
            $outputstring .= "</td></tr>\n";
        }

        if ($items{'docidrange'}[6]{$args{type}} eq 'T') {
            #$outputstring .= "<tr><td valign=top align=center><input type=checkbox checked readonly name=docidrange_selected value='T'></td>\n";
            #$outputstring .= "<td valign=top align=center><input type=radio checked name=sortorder value=docidrange></td><td valign=top>\n";
            $outputstring .= "<tr><td valign=top align=center>&nbsp;</td>\n";
            $outputstring .= "<td valign=top align=center>&nbsp;</td><td valign=top>\n";
            $outputstring .= "Documents Starting with <b>$CRDType</b> <input type=text size=6 maxlength=6 name=mindocid>";
            $outputstring .= " &nbsp;and/or Ending with <b>$CRDType</b> <input type=text size=6 maxlength=6 name=maxdocid>";
            $outputstring .= "</td></tr>\n";
        }

        if ($items{'doctype'}[6]{$args{type}} eq 'T') {
            $outputstring .= "<tr><td valign=top align=center><input type=checkbox checked name=doctype_selected value='T'></td>\n";
            $outputstring .= "<td valign=top align=center><input type=radio name=sortorder value=doctype_sort></td><td valign=top>\n";
            $outputstring .= "Document Type:<br>";
            %lookup_values = get_lookup_values($args{'dbh'},$args{'schema'},'document_type','id','name', '1=1 ORDER BY name');
            $outputstring .= build_drop_box ("doctype", \%lookup_values, '0', 'InitialBlank', 0) . "<br>\n";
            $outputstring .= "</td></tr>\n";
        }

        if ($items{'binid'}[6]{$args{type}} eq 'T') {
            $outputstring .= "<tr><td valign=top align=center><input type=checkbox checked readonly name=bin_selected value='T'></td><td valign=top align=center>\n";
            $outputstring .= "<input type=radio name=sortorder value=bin_sort></td><td valign=top>\n";
            $outputstring .= "Bin:<br>";
            %lookup_values = get_lookup_values($args{'dbh'},$args{'schema'},'bin','id','name', '1=1 ORDER BY name');
            $outputstring .= build_drop_box ("binid", \%lookup_values, '0', 'InitialBlank', 0) . "<br>\n";
            $outputstring .= "<i>Include Sub-Bins </i><input type=checkbox checked name=usesubbins value='T'> &nbsp; &nbsp; \n";
            $outputstring .= "</td></tr>\n";
        }

        if ($items{'bincoordinator'}[6]{$args{type}} eq 'T') {
            $outputstring .= "<tr><td valign=top align=center><input type=checkbox checked name=bincoordinator_selected value='T'></td>\n";
            $outputstring .= "<td valign=top align=center>&nbsp;<!--<input type=radio name=sortorder value=bincoordinator_sort>--></td><td valign=top>\n";
            $outputstring .= "Bin Coordinator:<br>\n";
            %lookup_values = get_lookup_values($args{'dbh'},$args{'schema'},'users','id',"firstname || ' ' || lastname", "id<1000 AND id IN (SELECT coordinator from $args{'schema'}.bin WHERE id IN (SELECT bin FROM $args{'schema'}.comments)) ORDER BY lastname, firstname");
            $outputstring .= build_dual_select ('bincoordinator', $form, \%lookup_values, \%lookup_values2, '<b>Available</b>', '<b>Selected</b>', 0);
            $outputstring .= "Include detail information for each user. <input type=checkbox name=bincoordinator_detail value='T'><br>\n";
            $outputstring .= "<i>Report will include data for any of the Bin Coordinator(s) selected.</i>\n";
            $outputstring .= "</td></tr>\n";
        }

        if ($items{'responsewriter'}[6]{$args{type}} eq 'T') {
            $outputstring .= "<tr><td valign=top align=center><input type=checkbox checked name=responsewriter_selected value='T'></td>\n";
            $outputstring .= "<td valign=top align=center>&nbsp;<!--<input type=radio name=sortorder value=responsewriter_sort>--></td><td valign=top>\n";
            $outputstring .= "Response Writer:<br>\n";
            %lookup_values = get_lookup_values($args{'dbh'},$args{'schema'},'users','id',"firstname || ' ' || lastname", "id<1000 AND id IN (SELECT responsewriter from $args{'schema'}.response_version) ORDER BY lastname, firstname");
            $outputstring .= build_dual_select ('responsewriter', $form, \%lookup_values, \%lookup_values2, '<b>Available</b>', '<b>Selected</b>', 0);
            $outputstring .= "Include detail information for each user. <input type=checkbox name=responsewriter_detail value='T'><br>\n";
            $outputstring .= "<i>Report will include data for any of the Response Writer(s) selected.</i>\n";
            $outputstring .= "</td></tr>\n";
        }
    
        if ($items{'technicalreviewer'}[6]{$args{type}} eq 'T') {
            $outputstring .= "<tr><td valign=top align=center><input type=checkbox checked name=technicalreviewer_selected value='T'></td>\n";
            $outputstring .= "<td valign=top align=center>&nbsp;<!--<input type=radio name=sortorder value=technicalreviewer_sort>--></td><td valign=top>\n";
            $outputstring .= "Technical Reviewer:<br>\n";
            %lookup_values = get_lookup_values($args{'dbh'},$args{'schema'},'users','id',"firstname || ' ' || lastname", "id<1000 AND id IN (SELECT reviewer from $args{'schema'}.technical_reviewer) ORDER BY lastname, firstname");
            $outputstring .= build_dual_select ('technicalreviewer', $form, \%lookup_values, \%lookup_values2, '<b>Available</b>', '<b>Selected</b>', 0);
            $outputstring .= "Include detail information for each user. <input type=checkbox name=technicalreviewer_detail value='T'><br>\n";
            $outputstring .= "<i>Report will include data for any of the Technical Reviewer(s) selected.</i>\n";
            $outputstring .= "</td></tr>\n";
        }
    
        if ($items{'nepareviewer'}[6]{$args{type}} eq 'T') {
            $outputstring .= "<tr><td valign=top align=center><input type=checkbox checked name=nepareviewer_selected value='T'></td>\n";
            $outputstring .= "<td valign=top align=center>&nbsp;<!--<input type=radio name=sortorder value=nepareviewer_sort>--></td><td valign=top>\n";
            $outputstring .= &FirstReviewName . " Reviewer:<br>\n";
            %lookup_values = get_lookup_values($args{'dbh'},$args{'schema'},'users','id',"firstname || ' ' || lastname", "id<1000 AND id IN (SELECT userid from $args{'schema'}.user_privilege WHERE privilege=6) ORDER BY lastname, firstname");
            $outputstring .= build_dual_select ('nepareviewer', $form, \%lookup_values, \%lookup_values2, '<b>Available</b>', '<b>Selected</b>', 0);
            $outputstring .= "Include detail information for each user. <input type=checkbox name=nepareviewer_detail value='T'><br>\n";
            $outputstring .= "<i>Report will include data for any of the " . &FirstReviewName . " Reviewer(s) selected.</i>\n";
            $outputstring .= "</td></tr>\n";
        }
    
        if ($items{'responsestatus'}[6]{$args{type}} eq 'T') {
            $outputstring .= "<tr><td valign=top align=center><input type=checkbox checked name=responsestatus_selected value='T'></td>\n";
            $outputstring .= "<td valign=top align=center>&nbsp</td><td valign=top>\n";
            $outputstring .= "Response Status<br>\n";
            %lookup_values = get_lookup_values($args{'dbh'},$args{'schema'},'response_status','id','name', 'id < 10 ORDER BY id');
            $outputstring .= build_dual_select ('responsestatus', $form, \%lookup_values, \%lookup_values2, '<b>Available</b>', '<b>Selected</b>', 0);
            $outputstring .= "</td></tr>\n";
        }

        if ($items{'summary'}[6]{$args{type}} eq 'T') {
            $outputstring .= "<tr><td valign=top align=center><input type=checkbox checked name=scr_indicator_selected value='T'></td>\n";
            $outputstring .= "<td valign=top align=center>&nbsp</td><td valign=top>\n";
            $outputstring .= "Summary Comment Indicator<br>\n";
            $outputstring .= "<select name=scr_indicator size=1>\n";
            $outputstring .= "<option value=' ' selected> </option>\n";
            $outputstring .= "<option value='with'>Only show comments that were Summarized</option>\n";
            $outputstring .= "<option value='without'>Only show comments were not Summarized</option>\n";
            #$outputstring .= "<option value='both'>Show all comments</option>\n";
            $outputstring .= "</select>\n";
            $outputstring .= "</td></tr>\n";
        }

        if ($items{'commentor'}[6]{$args{type}} eq 'T') {
            $outputstring .= "<tr><td valign=top align=center><input type=checkbox checked name=commentor_selected value='T'></td><td valign=top align=center>\n";
            $outputstring .= "<input type=radio name=sortorder value=commentor_sort></td><td valign=top>\n";
            $outputstring .= "<table border=0>\n";
            $outputstring .= "<tr><td>Commentor: </td><td>";
            %lookup_values = get_lookup_values($args{'dbh'},$args{'schema'},'commentor', 'id', "title || ' ' || firstname || ' ' || lastname || ' ' || suffix", "id IN (SELECT commentor FROM $args{'schema'}.document) ORDER BY lastname,firstname");
            $outputstring .= build_drop_box ("commentorid", \%lookup_values, '0', 'InitialBlank', 0) . "\n";
            $outputstring .= "</td></tr>\n";
            $outputstring .= "<tr><td>City: </td><td>";
            %lookup_values = get_unique_commentor_values($args{'dbh'},$args{'schema'},'city', '1=1 ORDER BY city');
            $outputstring .= build_drop_box ("cityid", \%lookup_values, '0', 'InitialBlank', 0) . "\n";
            $outputstring .= nbspaces(4) . "State: ";
            %lookup_values = get_unique_commentor_values($args{'dbh'},$args{'schema'},'state', '1=1 ORDER BY state');
            $outputstring .= build_drop_box ("stateid", \%lookup_values, '0', 'InitialBlank', 0) . "\n";
            $outputstring .= "</td></tr>\n";
            $outputstring .= "<tr><td>Organization: </td><td>";
            %lookup_values = get_unique_commentor_values($args{'dbh'},$args{'schema'},'organization', '1=1 ORDER BY organization');
            $outputstring .= build_drop_box ("organization", \%lookup_values, '0', 'InitialBlank', 0) . "\n";
            $outputstring .= "</td></tr>\n";
            $outputstring .= "<tr><td>Affiliation: </td><td>";
            %lookup_values = get_lookup_values($args{'dbh'},$args{'schema'}, 'commentor_affiliation','id', 'name', "id IN (SELECT affiliation FROM $args{'schema'}.commentor)  ORDER BY name");
            $outputstring .= build_drop_box ("affiliationid", \%lookup_values, '0', 'InitialBlank', 0) . "<br>\n";
            $outputstring .= "</td></tr>\n";
            $outputstring .= "<tr><td>Postal Code: </td><td>";
            %lookup_values = get_unique_commentor_values($args{'dbh'},$args{'schema'},'postalcode', '1=1 ORDER BY postalcode');
            $outputstring .= build_drop_box ("postalcode", \%lookup_values, '0', 'InitialBlank', 0) . "\n";
            #$outputstring .= "<select multiple name=postalcode size=3>\n";
            #foreach my $key (keys %lookup_values) {
            #    $outputstring .= "<option value=$key>$lookup_values{$key}</option>\n";
            #}
            #$outputstring .= "</select>\n";
            $outputstring .= "</td></tr>\n";
            $outputstring .= "<tr><td colspan=2>Area Code: ";
            %lookup_values = get_unique_commentor_values($args{'dbh'},$args{'schema'},'areacode', '1=1 ORDER BY areacode');
            $outputstring .= build_drop_box ("areacode", \%lookup_values, '0', 'InitialBlank', 0) . "\n";
            $outputstring .= nbspaces(4) . "FAX Area Code: ";
            %lookup_values = get_unique_commentor_values($args{'dbh'},$args{'schema'},'faxareacode', '1=1 ORDER BY faxareacode');
            $outputstring .= build_drop_box ("faxareacode", \%lookup_values, '0', 'InitialBlank', 0) . "\n";
            $outputstring .= "</td></tr>\n";
            $outputstring .= "<tr><td colspan=2>Include detail information for each commentor. <input type=checkbox checked name=commentordetail value='T'></td></tr>\n";
            $outputstring .= "</table>\n";
            $outputstring .= "</td></tr>\n";
        }
        
        if ($items{'commentorname'}[6]{$args{type}} eq 'T') {
            $outputstring .= "<tr><td valign=top align=center><input type=checkbox checked readonly name=commentorname_selected value='T' onclick=\"document.$form.commentorname_selected.checked=true\"></td><td valign=top align=center>\n";
            $outputstring .= "<input type=radio name=sortorder value=commentorname_sort></td><td valign=top>\n";
            $outputstring .= "Commentor:" . nbspaces(5);
            %lookup_values = get_lookup_values($args{'dbh'},$args{'schema'},'commentor', 'id', "title || ' ' || firstname || ' ' || lastname || ' ' || suffix", "id IN (SELECT commentor FROM $args{'schema'}.document) ORDER BY lastname,firstname");
            $outputstring .= build_drop_box ("commentorid", \%lookup_values, '0', 'InitialBlank', 0) . "\n";
            $outputstring .= "</td></tr>\n";
        }
        
        if ($items{'commentoraddress'}[6]{$args{type}} eq 'T') {
            $outputstring .= "<tr><td valign=top align=center><input type=checkbox checked name=commentoraddress_selected value='T'></td><td valign=top align=center>\n";
            $outputstring .= "<input type=radio name=sortorder value=commentoraddress_sort></td><td valign=top>\n";
            $outputstring .= "<table border=0>\n";
            $outputstring .= "<tr><td>Address: </td><td>&nbsp;";
            $outputstring .= "</td></tr>\n";
            $outputstring .= "<tr><td>City: </td><td>";
            %lookup_values = get_unique_commentor_values($args{'dbh'},$args{'schema'},'city', '1=1 ORDER BY city');
            $outputstring .= build_drop_box ("cityid", \%lookup_values, '0', 'InitialBlank', 0) . "\n";
            $outputstring .= nbspaces(4) . "State: ";
            %lookup_values = get_unique_commentor_values($args{'dbh'},$args{'schema'},'state', '1=1 ORDER BY state');
            $outputstring .= build_drop_box ("stateid", \%lookup_values, '0', 'InitialBlank', 0) . "\n";
            $outputstring .= "</td></tr>\n";
            $outputstring .= "<tr><td>Postal Code: </td><td>";
            %lookup_values = get_unique_commentor_values($args{'dbh'},$args{'schema'},'postalcode', '1=1 ORDER BY postalcode');
            $outputstring .= build_drop_box ("postalcode", \%lookup_values, '0', 'InitialBlank', 0) . "\n";
            #$outputstring .= "<select multiple name=postalcode size=3>\n";
            #foreach my $key (keys %lookup_values) {
            #    $outputstring .= "<option value=$key>$lookup_values{$key}</option>\n";
            #}
            #$outputstring .= "</select>\n";
            $outputstring .= "</td></tr>\n";
            #$outputstring .= "<tr><td colspan=2><i>Report will include data for any of the Postal Code(s) selected.</td></tr></i>\n";
            $outputstring .= "</table>\n";
            $outputstring .= "</td></tr>\n";
        }
        
        if ($items{'commentororg'}[6]{$args{type}} eq 'T') {
            $outputstring .= "<tr><td valign=top align=center><input type=checkbox checked name=commentororg_selected value='T'></td><td valign=top align=center>\n";
            $outputstring .= "<input type=radio name=sortorder value=commentororg_sort></td><td valign=top>\n";
            $outputstring .= "<table border=0>\n";
            $outputstring .= "<tr><td>Organization: </td><td>";
            %lookup_values = get_unique_commentor_values($args{'dbh'},$args{'schema'},'organization', '1=1 ORDER BY organization');
            $outputstring .= build_drop_box ("organization", \%lookup_values, '0', 'InitialBlank', 0) . "\n";
            $outputstring .= "</td></tr>\n";
            $outputstring .= "</table>\n";
            $outputstring .= "</td></tr>\n";
        }
        
        if ($items{'commentoraff'}[6]{$args{type}} eq 'T') {
            $outputstring .= "<tr><td valign=top align=center><input type=checkbox checked name=commentoraff_selected value='T'></td><td valign=top align=center>\n";
            $outputstring .= "<input type=radio name=sortorder value=commentoraff_sort></td><td valign=top>\n";
            $outputstring .= "<table border=0>\n";
            $outputstring .= "<tr><td>Affiliation: </td><td>";
            %lookup_values = get_lookup_values($args{'dbh'},$args{'schema'}, 'commentor_affiliation','id', 'name', "id IN (SELECT affiliation FROM $args{'schema'}.commentor)  ORDER BY name");
            $outputstring .= build_drop_box ("affiliationid", \%lookup_values, '0', 'InitialBlank', 0) . "\n";
            $outputstring .= "</td></tr>\n";
            $outputstring .= "</table>\n";
            $outputstring .= "</td></tr>\n";
        }
        
        if ($items{'commentorphone'}[6]{$args{type}} eq 'T') {
            $outputstring .= "<tr><td valign=top align=center><input type=checkbox checked name=commentorphone_selected value='T'></td><td valign=top align=center>\n";
            $outputstring .= "<input type=radio name=sortorder value=commentorphone_sort></td><td valign=top>\n";
            $outputstring .= "<table border=0>\n";
            $outputstring .= "<tr><td>Area Code: ";
            %lookup_values = get_unique_commentor_values($args{'dbh'},$args{'schema'},'areacode', '1=1 ORDER BY areacode');
            $outputstring .= build_drop_box ("areacode", \%lookup_values, '0', 'InitialBlank', 0) . "\n";
            $outputstring .= nbspaces(4) . "FAX Area Code: ";
            %lookup_values = get_unique_commentor_values($args{'dbh'},$args{'schema'},'faxareacode', '1=1 ORDER BY faxareacode');
            $outputstring .= build_drop_box ("faxareacode", \%lookup_values, '0', 'InitialBlank', 0) . "\n";
            $outputstring .= "</td></tr>\n";
            $outputstring .= "</table>\n";
            $outputstring .= "</td></tr>\n";
        }
        
        if ($items{'commentoremail'}[6]{$args{type}} eq 'T') {
            $outputstring .= "<tr><td valign=top align=center><input type=checkbox checked name=commentoremail_selected value='T'></td><td valign=top align=center>\n";
            $outputstring .= "&nbsp</td><td valign=top>\n";
            $outputstring .= "<table border=0>\n";
            $outputstring .= "<tr><td>Email address</td><td>";
            $outputstring .= "</table>\n";
            $outputstring .= "</td></tr>\n";
        }
        
        if ($items{'commentorposition'}[6]{$args{type}} eq 'T') {
            $outputstring .= "<tr><td valign=top align=center><input type=checkbox checked name=commentorposition_selected value='T'></td><td valign=top align=center>\n";
            $outputstring .= "&nbsp</td><td valign=top>\n";
            $outputstring .= "<table border=0>\n";
            $outputstring .= "<tr><td>Position</td><td>";
            $outputstring .= "</table>\n";
            $outputstring .= "</td></tr>\n";
        }
        
        if ($items{'datereceived'}[6]{$args{type}} eq 'T') {
            $outputstring .= "<tr><td valign=top align=center><input type=checkbox checked name=date_received_selected value='T'></td>\n";
            $outputstring .= "<td valign=top align=center><input type=radio name=sortorder value=date_received_sort></td><td valign=top>\n";
            $outputstring .= "Date Document Received:\n";
            $outputstring .= "<table border=0><tr><td>&nbsp &nbsp &nbsp &nbsp &nbsp &nbsp </td><td>\n";
            $outputstring .= "Starting &nbsp\n";
            $outputstring .= "</td><td>" . build_date_selection('date_received_start',"$form",'') . "\n";
            $outputstring .= "</td></tr><tr><td>&nbsp </td><td>\n";
            $outputstring .= "Ending &nbsp&nbsp\n";
            $outputstring .= "</td><td>" . build_date_selection('date_received_end',"$form",'') . "\n";
            $outputstring .= "</td></tr></table>\n";
            $outputstring .= "</td></tr>\n";
        }
        
        if ($items{'dateassigned'}[6]{$args{type}} eq 'T') {
            $outputstring .= "<tr><td valign=top align=center><input type=checkbox checked name=date_assigned_selected value='T'></td>\n";
            $outputstring .= "<td valign=top align=center><input type=radio name=sortorder value=date_assigned_sort></td><td valign=top>\n";
            $outputstring .= "Date Assigned:\n";
            $outputstring .= "<table border=0><tr><td>&nbsp &nbsp &nbsp &nbsp &nbsp &nbsp </td><td>\n";
            $outputstring .= "Starting &nbsp\n";
            $outputstring .= "</td><td>" . build_date_selection('date_assigned_start',"$form",'') . "\n";
            $outputstring .= "</td></tr><tr><td>&nbsp </td><td>\n";
            $outputstring .= "Ending &nbsp&nbsp\n";
            $outputstring .= "</td><td>" . build_date_selection('date_assigned_end',"$form",'') . "\n";
            $outputstring .= "</td></tr></table>\n";
            $outputstring .= "</td></tr>\n";
        }
        
        if ($items{'dateapproved'}[6]{$args{type}} eq 'T') {
            $outputstring .= "<tr><td valign=top align=center><input type=checkbox checked name=date_approved_selected value='T'></td>\n";
            $outputstring .= "<td valign=top align=center><input type=radio name=sortorder value=date_approved_sort></td><td valign=top>\n";
            $outputstring .= "Date of Approval:\n";
            $outputstring .= "<table border=0><tr><td>&nbsp &nbsp &nbsp &nbsp &nbsp &nbsp </td><td>\n";
            $outputstring .= "Starting &nbsp\n";
            $outputstring .= "</td><td>" . build_date_selection('date_approved_start',"$form",'') . "\n";
            $outputstring .= "</td></tr><tr><td>&nbsp </td><td>\n";
            $outputstring .= "Ending &nbsp&nbsp\n";
            $outputstring .= "</td><td>" . build_date_selection('date_approved_end',"$form",'') . "\n";
            $outputstring .= "</td></tr></table>\n";
            $outputstring .= "</td></tr>\n";
        }
        
        if ($items{'dateupdated'}[6]{$args{type}} eq 'T') {
            $outputstring .= "<tr><td valign=top align=center><input type=checkbox checked name=date_updated_selected value='T'></td>\n";
            $outputstring .= "<td valign=top align=center><input type=radio name=sortorder value=date_updated_sort></td><td valign=top>\n";
            $outputstring .= "Date Response Last Updated:\n";
            $outputstring .= "<table border=0><tr><td>&nbsp &nbsp &nbsp &nbsp &nbsp &nbsp </td><td>\n";
            $outputstring .= "Starting &nbsp\n";
            $outputstring .= "</td><td>" . build_date_selection('date_updated_start',"$form",'') . "\n";
            $outputstring .= "</td></tr><tr><td>&nbsp </td><td>\n";
            $outputstring .= "Ending &nbsp&nbsp\n";
            $outputstring .= "</td><td>" . build_date_selection('date_updated_end',"$form",'') . "\n";
            $outputstring .= "</td></tr></table>\n";
            $outputstring .= "</td></tr>\n";
        }
    
        if ($items{'addressee'}[6]{$args{type}} eq 'T') {
            $outputstring .= "<tr><td valign=top align=center><input type=checkbox checked name=addressee_selected value='T'></td>\n";
            $outputstring .= "<td valign=top align=center><input type=radio name=sortorder value=addressee_sort></td><td valign=top>\n";
            $outputstring .= "Addressee: ";
            %lookup_values = get_unique_values($args{'dbh'},$args{'schema'}, 'document','addressee', '1=1 ORDER BY addressee');
            $outputstring .= build_drop_box ("addressee", \%lookup_values, '0', 'InitialBlank', 0) . "\n";
            $outputstring .= "</td></tr>\n";
        }
    
        if ($items{'evaluationfactor'}[6]{$args{type}} eq 'T') {
            $outputstring .= "<tr><td valign=top align=center><input type=checkbox checked name=evaluationfactor_selected value='T'></td>\n";
            $outputstring .= "<td valign=top align=center><input type=radio name=sortorder value=evaluationfactor_sort></td><td valign=top>\n";
            $outputstring .= "Evaluation Factor: ";
            %lookup_values = ('-1' => 'None Assigned', get_lookup_values($args{dbh}, $args{schema}, 'evaluation_factor', 'id', 'name', '1=1 ORDER BY name'));
            $outputstring .= build_drop_box ("evaluationfactor", \%lookup_values, '0', 'InitialBlank', 0) . "\n";
            $outputstring .= "</td></tr>\n";
        }
    
        if ($items{'srcomments'}[6]{$args{type}} eq 'T') {
            $outputstring .= "<tr><td valign=top align=center><input type=checkbox checked name=hassrcomments_selected value='T'></td>\n";
            $outputstring .= "<td valign=top align=center>&nbsp</td><td valign=top>\n";
            $outputstring .= "$CRDRelatedTextShort Comments Indicator<br>\n";
            $outputstring .= "<select name=hassrcomments size=1>\n";
            $outputstring .= "<option value=' ' selected> </option>\n";
            $outputstring .= "<option value='with'>Only show documents with $CRDRelatedTextShort comments</option>\n";
            $outputstring .= "<option value='without'>Only show documents with out $CRDRelatedTextShort comments</option>\n";
            #$outputstring .= "<option value='both'>Show all documents</option>\n";
            $outputstring .= "</select>\n";
            $outputstring .= "</td></tr>\n";
        }
    
        if ($items{'lacomments'}[6]{$args{type}} eq 'T') {
            $outputstring .= "<tr><td valign=top align=center><input type=checkbox checked name=haslacomments_selected value='T'></td>\n";
            $outputstring .= "<td valign=top align=center>&nbsp</td><td valign=top>\n";
            $outputstring .= "LA Comments Indicator<br>\n";
            $outputstring .= "<select name=haslacomments size=1>\n";
            $outputstring .= "<option value=' ' selected> </option>\n";
            $outputstring .= "<option value='with'>Only show documents with LA comments</option>\n";
            $outputstring .= "<option value='without'>Only show documents with out LA comments</option>\n";
            #$outputstring .= "<option value='both'>Show all documents</option>\n";
            $outputstring .= "</select>\n";
            $outputstring .= "</td></tr>\n";
        }
    
        if ($items{'960comments'}[6]{$args{type}} eq 'T') {
            $outputstring .= "<tr><td valign=top align=center><input type=checkbox checked name=has960comments_selected value='T'></td>\n";
            $outputstring .= "<td valign=top align=center>&nbsp</td><td valign=top>\n";
            $outputstring .= "960/963 Comments Indicator<br>\n";
            $outputstring .= "<select name=has960comments size=1>\n";
            $outputstring .= "<option value=' ' selected> </option>\n";
            $outputstring .= "<option value='with'>Only show documents with 960/963 comments</option>\n";
            $outputstring .= "<option value='without'>Only show documents with out 960/963 comments</option>\n";
            #$outputstring .= "<option value='both'>Show all documents</option>\n";
            $outputstring .= "</select>\n";
            $outputstring .= "</td></tr>\n";
        }
    
        if ($items{'wasrescanned'}[6]{$args{type}} eq 'T') {
            $outputstring .= "<tr><td valign=top align=center><input type=checkbox checked name=wasrescanned_selected value='T'></td>\n";
            $outputstring .= "<td valign=top align=center>&nbsp</td><td valign=top>\n";
            $outputstring .= "Rescanned, Remarked, & Appended Indicator<br>\n";
            $outputstring .= "<select name=wasrescanned size=1>\n";
            $outputstring .= "<option value=' ' selected> </option>\n";
            $outputstring .= "<option value='with'>Only show documents that were Rescanned, Remarked, & Appended</option>\n";
            $outputstring .= "<option value='without'>Only show documents that were not Rescanned, Remarked, & Appended</option>\n";
            #$outputstring .= "<option value='both'>Show all documents</option>\n";
            $outputstring .= "</select>\n";
            $outputstring .= "</td></tr>\n";
        }
    
        if ($items{'enclosures'}[6]{$args{type}} eq 'T') {
            $outputstring .= "<tr><td valign=top align=center><input type=checkbox checked name=hasenclosures_selected value='T'></td>\n";
            $outputstring .= "<td valign=top align=center>&nbsp</td><td valign=top>\n";
            $outputstring .= "Enclosures Indicator<br>\n";
            $outputstring .= "<select name=hasenclosures size=1>\n";
            $outputstring .= "<option value=' ' selected> </option>\n";
            $outputstring .= "<option value='with'>Only show documents with enclosures</option>\n";
            $outputstring .= "<option value='without'>Only show documents with out enclosures</option>\n";
            #$outputstring .= "<option value='both'>Show all documents</option>\n";
            $outputstring .= "</select>\n";
            $outputstring .= "</td></tr>\n";
        }
    
        if ($items{'changeimpact'}[6]{$args{type}} eq 'T') {
            $outputstring .= "<tr><td valign=top align=center><input type=checkbox checked name=changeimpact_selected value='T'></td>\n";
            $outputstring .= "<td valign=top align=center>&nbsp</tr><td valign=top>\n";
            $outputstring .= "$CRDType Change Indicator<br>\n";
            %lookup_values = get_lookup_values($args{'dbh'},$args{'schema'},'document_change_impact', 'id', 'name', '1=1 ORDER BY id');
            $outputstring .= build_drop_box ("changeimpact", \%lookup_values, '0', 'InitialBlank', 0) . "</td></tr>\n";
            $outputstring .= "</td></tr>\n";
        }
    
        if ($items{'commitments'}[6]{$args{type}} eq 'T') {
            $outputstring .= "<tr><td valign=top align=center><input type=checkbox checked name=commitments_selected value='T'></td>\n";
            $outputstring .= "<td valign=top align=center>&nbsp</td><td valign=top>\n";
            $outputstring .= "Commitments Indicator<br>\n";
            $outputstring .= "<select name=commitments size=1>\n";
            $outputstring .= "<option value=' ' selected> </option>\n";
            $outputstring .= "<option value='with'>Only show comments with commitments</option>\n";
            $outputstring .= "<option value='without'>Only show comments with out commitments</option>\n";
            #$outputstring .= "<option value='both'>Show all comments</option>\n";
            $outputstring .= "</select>\n";
            $outputstring .= "</td></tr>\n";
        }
    
        if ($items{'hasissues'}[6]{$args{type}} eq 'T') {
            $outputstring .= "<tr><td valign=top align=center><input type=checkbox checked name=hasissues_selected value='T'></td>\n";
            $outputstring .= "<td valign=top align=center>&nbsp</td><td valign=top>\n";
            $outputstring .= "Has Potential Issuses Indicator<br>\n";
            $outputstring .= "<select name=hasissues size=1>\n";
            $outputstring .= "<option value=' ' selected> </option>\n";
            $outputstring .= "<option value='with'>Only show comments that have potential issues</option>\n";
            $outputstring .= "<option value='without'>Only show comments that do not have potential issues</option>\n";
            #$outputstring .= "<option value='both'>Show all comments</option>\n";
            $outputstring .= "</select>\n";
            $outputstring .= "</td></tr>\n";
        }
    
        if ($items{'commenttext'}[6]{$args{type}} eq 'T') {
            $outputstring .= "<tr><td valign=top align=center><input type=checkbox checked name=comments_selected value='T'></td>\n";
            $outputstring .= "<td valign=top align=center>&nbsp</td><td valign=top>\n";
            $outputstring .= "Comment Text\n";
            $outputstring .= "<br><input type=text name=commentsearchtext size=60 maxlength=60>\n";
            $outputstring .= "</td></tr>\n";
        }
    
        if ($items{'response'}[6]{$args{type}} eq 'T') {
            $outputstring .= "<tr><td valign=top align=center><input type=checkbox checked name=response_selected value='T'></td>\n";
            $outputstring .= "<td valign=top align=center>&nbsp</td><td valign=top>\n";
            $outputstring .= "Response\n";
            $outputstring .= "<br><input type=text name=responsesearchtext size=60 maxlength=60>\n";
            $outputstring .= "</td></tr>\n";
        }
    
        if ($items{'techreviewtext'}[6]{$args{type}} eq 'T') {
            $outputstring .= "<tr><td valign=top align=center><input type=checkbox checked name=techreviewtext_selected value='T'></td>\n";
            $outputstring .= "<td valign=top align=center>&nbsp</td><td valign=top>\n";
            $outputstring .= "Technical Review Text\n";
            $outputstring .= "</td></tr>\n";
        }
    
        if ($items{'docremarks'}[6]{$args{type}} eq 'T') {
            $outputstring .= "<tr><td valign=top align=center><input type=checkbox checked name=doc_remarks_selected value='T'></td>\n";
            $outputstring .= "<td valign=top align=center>&nbsp</td><td valign=top>\n";
            $outputstring .= "Document Remarks\n";
            $outputstring .= "<br><input type=text name=docremarkssearchtext size=60 maxlength=60>\n";
            $outputstring .= "</td></tr>\n";
        }

        if ($items{'comremarks'}[6]{$args{type}} eq 'T') {
            $outputstring .= "<tr><td valign=top align=center><input type=checkbox checked name=com_remarks_selected value='T'></td>\n";
            $outputstring .= "<td valign=top align=center>&nbsp</td><td valign=top>\n";
            $outputstring .= "Comment Remarks\n";
            $outputstring .= "<br><input type=text name=comremarkssearchtext size=60 maxlength=60>\n";
            $outputstring .= "</td></tr>\n";
        }

        if ($items{'page'}[6]{$args{type}} eq 'T') {
            $outputstring .= "<tr><td valign=top align=center><input type=checkbox checked name=start_page_selected value='T'></td>\n";
            $outputstring .= "<td valign=top align=center>&nbsp</td><td valign=top>\n";
            $outputstring .= "Page of Comment Document that this Comment starts on\n";
            $outputstring .= "</td></tr>\n";
        }

        if ($items{'dupcomment'}[6]{$args{type}} eq 'T') {
            $outputstring .= "<tr><td valign=top align=center><input type=checkbox checked name=dup_comment_selected value='T'></td>\n";
            $outputstring .= "<td valign=top align=center>&nbsp</td><td valign=top>\n";
            $outputstring .= "Duplicate Comment Indicator\n";
            $outputstring .= "</td></tr>\n";
        }

        
        $outputstring .= "</table>\n";
    
        $outputstring .= "<br><center><input type=button name=ad_hoc_submit value=Submit onClick=\"processFormSubmit();\"></center><br>\n";
        $outputstring .= "<tr><td>\n$printHeaderHelp<br></td></tr>\n";

#
##################
#
        
        $outputstring .= "<script language=javascript><!--\n";
        $outputstring .= "\n";
        $outputstring .= "    document.$form.sortorder[0].checked=true;\n\n";
        $outputstring .= "    function setIncludes(isChecked) {\n";
        if ($items{'doctype'}[6]{$args{type}} eq 'T')           {$outputstring .= "        document.$form.doctype_selected.checked = isChecked;\n";}
        if ($items{'binid'}[6]{$args{type}} eq 'T')             {$outputstring .= "        document.$form.bin_selected.checked = isChecked;\n";}
        if ($items{'bincoordinator'}[6]{$args{type}} eq 'T')    {$outputstring .= "        document.$form.bincoordinator_selected.checked = isChecked;\n";}
        if ($items{'responsewriter'}[6]{$args{type}} eq 'T')    {$outputstring .= "        document.$form.responsewriter_selected.checked = isChecked;\n";}
        if ($items{'technicalreviewer'}[6]{$args{type}} eq 'T') {$outputstring .= "        document.$form.technicalreviewer_selected.checked = isChecked;\n";}
        if ($items{'nepareviewer'}[6]{$args{type}} eq 'T')      {$outputstring .= "        document.$form.nepareviewer_selected.checked = isChecked;\n";}
        if ($items{'responsestatus'}[6]{$args{type}} eq 'T')    {$outputstring .= "        document.$form.responsestatus_selected.checked = isChecked;\n";}
        if ($items{'commentor'}[6]{$args{type}} eq 'T')         {$outputstring .= "        document.$form.commentor_selected.checked = isChecked;\n";}
        if ($items{'commentorname'}[6]{$args{type}} eq 'T')     {$outputstring .= "        document.$form.commentorname_selected.checked = true;\n";}
        if ($items{'commentoraddress'}[6]{$args{type}} eq 'T')  {$outputstring .= "        document.$form.commentoraddress_selected.checked = isChecked;\n";}
        if ($items{'commentororg'}[6]{$args{type}} eq 'T')      {$outputstring .= "        document.$form.commentororg_selected.checked = isChecked;\n";}
        if ($items{'commentoraff'}[6]{$args{type}} eq 'T')      {$outputstring .= "        document.$form.commentoraff_selected.checked = isChecked;\n";}
        if ($items{'commentorphone'}[6]{$args{type}} eq 'T')    {$outputstring .= "        document.$form.commentorphone_selected.checked = isChecked;\n";}
        if ($items{'commentoremail'}[6]{$args{type}} eq 'T')    {$outputstring .= "        document.$form.commentoremail_selected.checked = isChecked;\n";}
        if ($items{'commentorposition'}[6]{$args{type}} eq 'T') {$outputstring .= "        document.$form.commentorposition_selected.checked = isChecked;\n";}
        if ($items{'datereceived'}[6]{$args{type}} eq 'T')      {$outputstring .= "        document.$form.date_received_selected.checked = isChecked;\n";}
        if ($items{'dateassigned'}[6]{$args{type}} eq 'T')      {$outputstring .= "        document.$form.date_assigned_selected.checked = isChecked;\n";}
        if ($items{'dateapproved'}[6]{$args{type}} eq 'T')      {$outputstring .= "        document.$form.date_approved_selected.checked = isChecked;\n";}
        if ($items{'dateupdated'}[6]{$args{type}} eq 'T')       {$outputstring .= "        document.$form.date_updated_selected.checked = isChecked;\n";}
        if ($items{'addressee'}[6]{$args{type}} eq 'T')         {$outputstring .= "        document.$form.addressee_selected.checked = isChecked;\n";}
        if ($items{'evaluationfactor'}[6]{$args{type}} eq 'T')  {$outputstring .= "        document.$form.evaluationfactor_selected.checked = isChecked;\n";}
        if ($items{'srcomments'}[6]{$args{type}} eq 'T')        {$outputstring .= "        document.$form.hassrcomments_selected.checked = isChecked;\n";}
        if ($items{'lacomments'}[6]{$args{type}} eq 'T')        {$outputstring .= "        document.$form.haslacomments_selected.checked = isChecked;\n";}
        if ($items{'960comments'}[6]{$args{type}} eq 'T')       {$outputstring .= "        document.$form.has960comments_selected.checked = isChecked;\n";}
        if ($items{'wasrescanned'}[6]{$args{type}} eq 'T')      {$outputstring .= "        document.$form.wasrescanned_selected.checked = isChecked;\n";}
        if ($items{'enclosures'}[6]{$args{type}} eq 'T')        {$outputstring .= "        document.$form.hasenclosures_selected.checked = isChecked;\n";}
        if ($items{'changeimpact'}[6]{$args{type}} eq 'T')      {$outputstring .= "        document.$form.changeimpact_selected.checked = isChecked;\n";}
        if ($items{'commitments'}[6]{$args{type}} eq 'T')       {$outputstring .= "        document.$form.commitments_selected.checked = isChecked;\n";}
        if ($items{'hasissues'}[6]{$args{type}} eq 'T')         {$outputstring .= "        document.$form.hasissues_selected.checked = isChecked;\n";}
        if ($items{'commenttext'}[6]{$args{type}} eq 'T')       {$outputstring .= "        document.$form.comments_selected.checked = isChecked;\n";}
        if ($items{'response'}[6]{$args{type}} eq 'T')          {$outputstring .= "        document.$form.response_selected.checked = isChecked;\n";}
        if ($items{'techreviewtext'}[6]{$args{type}} eq 'T')    {$outputstring .= "        document.$form.techreviewtext_selected.checked = isChecked;\n";}
        if ($items{'docremarks'}[6]{$args{type}} eq 'T')        {$outputstring .= "        document.$form.doc_remarks_selected.checked = isChecked;\n";}
        if ($items{'comremarks'}[6]{$args{type}} eq 'T')        {$outputstring .= "        document.$form.com_remarks_selected.checked = isChecked;\n";}
        if ($items{'page'}[6]{$args{type}} eq 'T')              {$outputstring .= "        document.$form.start_page_selected.checked = isChecked;\n";}
        if ($items{'summary'}[6]{$args{type}} eq 'T')           {$outputstring .= "        document.$form.scr_indicator_selected.checked = isChecked;\n";}
        if ($items{'dupcomment'}[6]{$args{type}} eq 'T')        {$outputstring .= "        document.$form.dup_comment_selected.checked = isChecked;\n";}
        $outputstring .= "    }\n";
        $outputstring .= "    setIncludes(false);\n\n";

#
##################
#

        $outputstring .= "    function clearForm() {\n";
        $outputstring .= "        document.$form.reporttitle.value = '';\n";
        $outputstring .= "        document.$form.sortdirection[0].checked = true;\n";
        $outputstring .= "        document.$form.sortorder[0].checked = true;\n";
        $outputstring .= "        document.$form.report_boolean[0].checked = true;\n";
        $outputstring .= "        document.$form.text_limit.checked = false;\n";
        if ($items{'cdidcid'}[6]{$args{type}} eq 'T') {
            $outputstring .= "        document.$form.documentid.value = '';\n";
            $outputstring .= "        document.$form.commentnum.value = '';\n";
            $outputstring .= "        document.$form.use_all_docs.checked = true;\n";
        }
        if ($items{'docid'}[6]{$args{type}} eq 'T') {
            $outputstring .= "        document.$form.startingdocid.value = '';\n";
            $outputstring .= "        document.$form.endingdocid.value = '';\n";
        }
        if ($items{'docidrange'}[6]{$args{type}} eq 'T') {
            $outputstring .= "        document.$form.mindocid.value = '';\n";
            $outputstring .= "        document.$form.maxdocid.value = '';\n";
        }
        if ($items{'doctype'}[6]{$args{type}} eq 'T') {
            $outputstring .= "        set_selected_option(document.$form.doctype,'0');\n";
        }
        if ($items{'binid'}[6]{$args{type}} eq 'T') {
            $outputstring .= "        set_selected_option(document.$form.binid,'0');\n";
            $outputstring .= "        document.$form.usesubbins.checked = true;\n";
        }
        if ($items{'bincoordinator'}[6]{$args{type}} eq 'T') {
            $outputstring .= "for (index=document.$form.bincoordinator.length-2; index >= 0 ;index--) {\n";
            $outputstring .= "    document.$form.bincoordinator.options[index].selected = true;\n";
            $outputstring .= "    process_dual_select_option(document.$form.bincoordinator.options,document.$form.availbincoordinator.options,'move');\n";
            $outputstring .= "}\n";
            $outputstring .= "        document.$form.bincoordinator_detail.checked = false;\n";
        }
        if ($items{'responsewriter'}[6]{$args{type}} eq 'T') {
            $outputstring .= "for (index=document.$form.responsewriter.length-2; index >= 0 ;index--) {\n";
            $outputstring .= "    document.$form.responsewriter.options[index].selected = true;\n";
            $outputstring .= "    process_dual_select_option(document.$form.responsewriter.options,document.$form.availresponsewriter.options,'move');\n";
            $outputstring .= "}\n";
            $outputstring .= "        document.$form.responsewriter_detail.checked = false;\n";
        }
        if ($items{'technicalreviewer'}[6]{$args{type}} eq 'T') {
            $outputstring .= "for (index=document.$form.technicalreviewer.length-2; index >= 0 ;index--) {\n";
            $outputstring .= "    document.$form.technicalreviewer.options[index].selected = true;\n";
            $outputstring .= "    process_dual_select_option(document.$form.technicalreviewer.options,document.$form.availtechnicalreviewer.options,'move');\n";
            $outputstring .= "}\n";
            $outputstring .= "        document.$form.responsewriter_detail.checked = false;\n";
        }
        if ($items{'nepareviewer'}[6]{$args{type}} eq 'T') {
            $outputstring .= "for (index=document.$form.nepareviewer.length-2; index >= 0 ;index--) {\n";
            $outputstring .= "    document.$form.nepareviewer.options[index].selected = true;\n";
            $outputstring .= "    process_dual_select_option(document.$form.nepareviewer.options,document.$form.availnepareviewer.options,'move');\n";
            $outputstring .= "}\n";
            $outputstring .= "        document.$form.nepareviewer_detail.checked = false;\n";
        }
        if ($items{'responsestatus'}[6]{$args{type}} eq 'T') {
            $outputstring .= "for (index=document.$form.responsestatus.length-2; index >= 0 ;index--) {\n";
            $outputstring .= "    document.$form.responsestatus.options[index].selected = true;\n";
            $outputstring .= "    process_dual_select_option(document.$form.responsestatus.options,document.$form.availresponsestatus.options,'move');\n";
            $outputstring .= "}\n";
        }
        if ($items{'commentor'}[6]{$args{type}} eq 'T') {
            $outputstring .= "        set_selected_option(document.$form.commentorid,'0');\n";
            $outputstring .= "        set_selected_option(document.$form.cityid,'0');\n";
            $outputstring .= "        set_selected_option(document.$form.stateid,'0');\n";
            $outputstring .= "        set_selected_option(document.$form.organization,'0');\n";
            $outputstring .= "        set_selected_option(document.$form.affiliationid,'0');\n";
            #$outputstring .= "        for (index=document.$form.postalcode.length-1; index >= 0 ;index--) {\n";
            #$outputstring .= "            document.$form.postalcode.options[index].selected = false;\n";
            #$outputstring .= "        }\n";
            $outputstring .= "        set_selected_option(document.$form.postalcode,'0');\n";
            $outputstring .= "        set_selected_option(document.$form.areacode,'0');\n";
            $outputstring .= "        set_selected_option(document.$form.faxareacode,'0');\n";
            $outputstring .= "        document.$form.commentordetail.checked = true;\n";
        }
        if ($items{'commentorname'}[6]{$args{type}} eq 'T') {
            $outputstring .= "        set_selected_option(document.$form.commentorid,'0');\n";
        }
        if ($items{'commentoraddress'}[6]{$args{type}} eq 'T') {
            $outputstring .= "        set_selected_option(document.$form.cityid,'0');\n";
            $outputstring .= "        set_selected_option(document.$form.stateid,'0');\n";
            #$outputstring .= "        for (index=document.$form.postalcode.length-1; index >= 0 ;index--) {\n";
            #$outputstring .= "            document.$form.postalcode.options[index].selected = false;\n";
            #$outputstring .= "        }\n";
            $outputstring .= "        set_selected_option(document.$form.postalcode,'0');\n";
        }
        if ($items{'commentororg'}[6]{$args{type}} eq 'T') {
            $outputstring .= "        set_selected_option(document.$form.organization,'0');\n";
        }
        if ($items{'commentoraff'}[6]{$args{type}} eq 'T') {
            $outputstring .= "        set_selected_option(document.$form.affiliationid,'0');\n";
        }
        if ($items{'commentorphone'}[6]{$args{type}} eq 'T') {
            $outputstring .= "        set_selected_option(document.$form.areacode,'0');\n";
            $outputstring .= "        set_selected_option(document.$form.faxareacode,'0');\n";
        }
        if ($items{'datereceived'}[6]{$args{type}} eq 'T') {
            $outputstring .= "        set_selected_option(document.$form.date_received_start_month,'');\n";
            $outputstring .= "        set_selected_option(document.$form.date_received_start_day,'');\n";
            $outputstring .= "        set_selected_option(document.$form.date_received_start_year,'');\n";
            $outputstring .= "        set_selected_option(document.$form.date_received_end_month,'');\n";
            $outputstring .= "        set_selected_option(document.$form.date_received_end_day,'');\n";
            $outputstring .= "        set_selected_option(document.$form.date_received_end_year,'');\n";
        }
        if ($items{'dateassigned'}[6]{$args{type}} eq 'T') {
            $outputstring .= "        set_selected_option(document.$form.date_assigned_start_month,'');\n";
            $outputstring .= "        set_selected_option(document.$form.date_assigned_start_day,'');\n";
            $outputstring .= "        set_selected_option(document.$form.date_assigned_start_year,'');\n";
            $outputstring .= "        set_selected_option(document.$form.date_assigned_end_month,'');\n";
            $outputstring .= "        set_selected_option(document.$form.date_assigned_end_day,'');\n";
            $outputstring .= "        set_selected_option(document.$form.date_assigned_end_year,'');\n";
        }
        if ($items{'dateapproved'}[6]{$args{type}} eq 'T') {
            $outputstring .= "        set_selected_option(document.$form.date_approved_start_month,'');\n";
            $outputstring .= "        set_selected_option(document.$form.date_approved_start_day,'');\n";
            $outputstring .= "        set_selected_option(document.$form.date_approved_start_year,'');\n";
            $outputstring .= "        set_selected_option(document.$form.date_approved_end_month,'');\n";
            $outputstring .= "        set_selected_option(document.$form.date_approved_end_day,'');\n";
            $outputstring .= "        set_selected_option(document.$form.date_approved_end_year,'');\n";
        }
        if ($items{'dateupdated'}[6]{$args{type}} eq 'T') {
            $outputstring .= "        set_selected_option(document.$form.date_updated_start_month,'');\n";
            $outputstring .= "        set_selected_option(document.$form.date_updated_start_day,'');\n";
            $outputstring .= "        set_selected_option(document.$form.date_updated_start_year,'');\n";
            $outputstring .= "        set_selected_option(document.$form.date_updated_end_month,'');\n";
            $outputstring .= "        set_selected_option(document.$form.date_updated_end_day,'');\n";
            $outputstring .= "        set_selected_option(document.$form.date_updated_end_year,'');\n";
        }
        if ($items{'addressee'}[6]{$args{type}} eq 'T') {
            $outputstring .= "        set_selected_option(document.$form.addressee,'0');\n";
        }
        if ($items{'evaluationfactor'}[6]{$args{type}} eq 'T') {
            $outputstring .= "        set_selected_option(document.$form.evaluationfactor,'0');\n";
        }
        if ($items{'srcomments'}[6]{$args{type}} eq 'T') {
            $outputstring .= "        set_selected_option(document.$form.hassrcomments,' ');\n";
        }
        if ($items{'lacomments'}[6]{$args{type}} eq 'T') {
            $outputstring .= "        set_selected_option(document.$form.haslacomments,' ');\n";
        }
        if ($items{'960comments'}[6]{$args{type}} eq 'T') {
            $outputstring .= "        set_selected_option(document.$form.has960comments,' ');\n";
        }
        if ($items{'wasrescanned'}[6]{$args{type}} eq 'T') {
            $outputstring .= "        set_selected_option(document.$form.wasrescanned,' ');\n";
        }
        if ($items{'enclosures'}[6]{$args{type}} eq 'T') {
            $outputstring .= "        set_selected_option(document.$form.hasenclosures,' ');\n";
        }
        if ($items{'changeimpact'}[6]{$args{type}} eq 'T') {
            $outputstring .= "        set_selected_option(document.$form.changeimpact,'0');\n";
        }
        if ($items{'commitments'}[6]{$args{type}} eq 'T') {
            $outputstring .= "        set_selected_option(document.$form.commitments,' ');\n";
        }
        if ($items{'hasissues'}[6]{$args{type}} eq 'T') {
            $outputstring .= "        set_selected_option(document.$form.hasissues,' ');\n";
        }
        if ($items{'summary'}[6]{$args{type}} eq 'T') {
            $outputstring .= "        set_selected_option(document.$form.scr_indicator,' ');\n";
        }
        $outputstring .= "    }\n";
        $outputstring .= "//--></script>\n";
    };
    if ($@) {
        $message = errorMessage($dbh,$username,$userid,$schema,"creating an ad hoc selection page.",$@);
        print doAlertBox( text => $message);
    }
    

    return ($outputstring);
}


#
##################
#

sub AdHocReportPage {
    my %args = (
        run_date => getReportDateTime,
        dbh => '',
        schema => '',
        command => '',
        reporttitle => '',
        report_boolean => '',
        sortdirection => '',
        text_limit => '',
        @_,
    );
    
    my $outputstring = '';
    tie my %lookup_values, "Tie::IxHash";
    #%lookup_values = {};
    my $refvar;
    my %tables;
    my %items;
    my @joins;
    my %fields = ();
    my $fieldcount = 0;
    my $sqlquery_select = 'SELECT ';
    my $sqlquery_from = ' FROM ';
    my $sqlquery_where = ' WHERE ';
    my $sqlquery_order = ' ORDER BY ';
    my $sqlquery;
    my $sqlquery2;
    my $csr;
    my $csr2;
    my $status;
    my $sortdirection = '';
    my $key = '';
    my $key2 = '';
    my @values = ();
    my @values2 =();
    my @row = ();
    my $message = '';
    my $report_boolean = (($args{'report_boolean'} eq 'all') ? 'AND' : 'OR');
    my $hasSelections = 'F';
    my $count = 0;
    my $itemcount = 0;
    my $reporttitle = ((defined($crdcgi->param('reporttitle'))) ? $crdcgi->param('reporttitle') : '');
    my $excludeTable = ((defined($crdcgi->param('excludetable'))) ? $crdcgi->param('excludetable') : "");
    
    $reporttitle =~ s/\"/\'/g;
    
    
    $refvar = $args{'tables'};
    %tables = %$refvar;
    $refvar = $args{'items'};
    %items = %$refvar;
    $refvar = $args{'joins'};
    @joins = @$refvar;
    
    # determine tables used
    foreach $key (keys %items) {
        if ($items{$key}[0] eq 'T' || $items{$key}[1] eq 'T' || $items{$key}[5] eq 'T') {
            for ($key2=0; $key2 <= $#{ $items{$key}[3] }; $key2++) {
                $tables{$items{$key}[3][$key2]}[0] = 'T';
            }
        }
    }
    # exclude table specified by user (if any)
    if ($excludeTable gt '') {
    
    #$outputstring .= "\n\n<!-- Got Here 1 - $excludeTable -->\n\n";
        $tables{$excludeTable}[0] = 'F';
    }
    
    # build sql select
    $count=0;
    if ($args{'command'} eq 'adhoctest') {
        $sqlquery_select .= "count(*)";
    } else {
        foreach $key (keys %tables) {
            if ($tables{$key}[0] eq 'T') {
                for $key2 (0 .. $#{ $tables{$key}[1] }) {
                    $fields{$tables{$key}[3] . "_" . $tables{$key}[1][$key2]} = $count;
                    $count++;
                    $sqlquery_select .= "$tables{$key}[3].$tables{$key}[1][$key2], ";
                }
            }
        }
        chop($sqlquery_select);
        chop($sqlquery_select);
    }
    
    # build sql from
    foreach $key (keys %tables) {
        if ($tables{$key}[0] eq 'T') {
            $sqlquery_from .= $args{'schema'} . '.' . $tables{$key}[2] . ' ' . $tables{$key}[3] . ', ';
        }
    }
    chop($sqlquery_from);
    chop($sqlquery_from);
    
    # build sql order
    $sortdirection = (($args{'sortdirection'} eq 'desc') ? ' DESC' : '');
    if ($args{'command'} eq 'adhocreport') {
        foreach $key (keys %items) {
            if ($items{$key}[1] eq 'T') {
                $items{$key}[2] =~ s/,/$sortdirection,/g;
                $sqlquery_order .= $items{$key}[2] . $sortdirection . ', ';
            }
        }
        chop($sqlquery_order);
        chop($sqlquery_order);
    } else {
        $sqlquery_order .= "1";
    }
    
    # build sql where
    if ($items{'cdidcid'}[4]{'use_all_docs'} eq 'T') {
        $joins[0][2] .= '(+)';
    }
    $sqlquery_where .= "(";
    for ($key=0; $key <= $#joins; $key++) {
        if ($tables{$joins[$key][0]}[0] eq 'T' && $tables{$joins[$key][1]}[0] eq 'T') {
            $sqlquery_where .= $joins[$key][2] . ' AND ';
            # append required sorts to $sqlquery_order
            if ($args{'command'} eq 'adhocreport' && $joins[$key][3] ne '') {
                $joins[$key][3] =~ s/,/$sortdirection,/g;
                $sqlquery_order .= ', ' . $joins[$key][3];
            }
        }
    }
    if ($sqlquery_where gt '(') {
        for ($key2=0; $key2<4; $key2++) {
            chop($sqlquery_where);
        }
    } else {
        $sqlquery_where .= "1=1";
    }
    $sqlquery_where .= ")";
    foreach $key (keys %items) {
        if ($items{$key}[5] eq 'T') {
            $hasSelections = 'T';
        }
    }
    if (defined($crdcgi->param('extra_where_info')) && $crdcgi->param('extra_where_info') gt '') { $hasSelections = 'T';}

#
##################
#
    
    if ($hasSelections eq 'T') {
        $sqlquery_where .= " AND (";
        #
        $count = 0;
        if ($items{'cdidcid'}[5] eq 'T') {
            $sqlquery_where .= "(doc.id = $items{'cdidcid'}[4]{'document'}";
            if ($items{'cdidcid'}[4]{'commentnum'} gt '') {
                $sqlquery_where .= " AND com.commentnum = $items{'cdidcid'}[4]{'commentnum'}";
            }
            $sqlquery_where .= ")";
            $count++;
        }
        if ($items{'docid'}[5] eq 'T') {
            $sqlquery_where .= "(doc.id BETWEEN $items{'docid'}[4]{'startid'} AND $items{'docid'}[4]{'endid'})";
            $count++;
        }
        if ($items{'docidrange'}[5] eq 'T') {
            if ($count > 0) {$sqlquery_where .= " $report_boolean";}
            if ($items{'docidrange'}[4]{'startid'} gt '0' && $items{'docidrange'}[4]{'endid'} gt '0') {
                $sqlquery_where .= "(doc.id >= $items{'docidrange'}[4]{'startid'} AND doc.id <= $items{'docidrange'}[4]{'endid'})";
            } elsif ($items{'docidrange'}[4]{'startid'} gt '0') {
                $sqlquery_where .= "(doc.id >= $items{'docidrange'}[4]{'startid'})";
            } elsif ($items{'docidrange'}[4]{'endid'} gt '0') {
                $sqlquery_where .= "(doc.id <= $items{'docidrange'}[4]{'endid'})";
            }
            $count++;
        }
        if ($items{'doctype'}[5] eq 'T') {
            if ($count > 0) {$sqlquery_where .= " $report_boolean";}
            $sqlquery_where .= "(doc.documenttype = $items{'doctype'}[4]{'selection'})";
            $count++;
        }
        if ($items{'binid'}[5] eq 'T') {
            if ($count > 0) {$sqlquery_where .= " $report_boolean";}
            if ($items{'binid'}[4]{'subBins'} eq 'F') {
                $sqlquery_where .= " (com.bin = $items{'binid'}[4]{'binid'})";
            } else {
                $args{'root_bin'} = $items{'binid'}[4]{'binid'};
                $sqlquery_where .= " (com.bin IN (" . getBinTree(\%args) . "))";
            }
            $count++;
        }
        if ($items{'bincoordinator'}[5] eq 'T') {
            if ($count > 0) {$sqlquery_where .= " $report_boolean";}
            $sqlquery_where .= " (bin.coordinator IN (";
            for ($key=0; $key <= $#{ $items{'bincoordinator'}[4]{'userlist'} }; $key++) {
                $sqlquery_where .= " $items{'bincoordinator'}[4]{'userlist'}[$key],";
            }
            $sqlquery_where .= " 0";
            $sqlquery_where .= ")";
            $sqlquery_where .= ")";
            $count++;
        }
        if ($items{'responsewriter'}[5] eq 'T') {
            if ($count > 0) {$sqlquery_where .= " $report_boolean";}
            $sqlquery_where .= " (rv.responsewriter IN (";
            for ($key=0; $key <= $#{ $items{'responsewriter'}[4]{'userlist'} }; $key++) {
                $sqlquery_where .= " $items{'responsewriter'}[4]{'userlist'}[$key],";
            }
            $sqlquery_where .= " 0";
            $sqlquery_where .= ")";
            $sqlquery_where .= ")";
            $count++;
        }
        if ($items{'technicalreviewer'}[5] eq 'T') {
            if ($count > 0) {$sqlquery_where .= " $report_boolean";}
            $sqlquery_where .= " ((com.document,com.commentnum) IN (SELECT document,commentnum FROM $schema.technical_reviewer WHERE reviewer IN (";
            for ($key=0; $key <= $#{ $items{'technicalreviewer'}[4]{'userlist'} }; $key++) {
                $sqlquery_where .= " $items{'technicalreviewer'}[4]{'userlist'}[$key],";
            }
            $sqlquery_where .= " 0";
            $sqlquery_where .= ")";
            ###$sqlquery_where .= " AND status < 4";
            $sqlquery_where .= "))";
            $count++;
        }
        if ($items{'nepareviewer'}[5] eq 'T' && $documentid ne "commentor" && $documentid ne "document") {
            if ($count > 0) {$sqlquery_where .= " $report_boolean";}
            $sqlquery_where .= " ((bin.nepareviewer) IN (";
            for ($key=0; $key <= $#{ $items{'nepareviewer'}[4]{'userlist'} }; $key++) {
                $sqlquery_where .= " $items{'nepareviewer'}[4]{'userlist'}[$key],";
            }
            $sqlquery_where .= " 0";
            $sqlquery_where .= ")";
            $sqlquery_where .= ")";
            $count++;
        }
        if ($items{'responsestatus'}[5] eq 'T') {
            if ($count > 0) {$sqlquery_where .= " $report_boolean";}
            $sqlquery_where .= " ((rv.status) IN (";
            for ($key=0; $key <= $#{ $items{'responsestatus'}[4]{'list'} }; $key++) {
                $sqlquery_where .= " $items{'responsestatus'}[4]{'list'}[$key],";
            }
            $sqlquery_where .= " 0";
            $sqlquery_where .= ")";
            $sqlquery_where .= ")";
            $count++;
        }
        if ($items{'commentor'}[5] eq 'T') {
            if ($count > 0) {$sqlquery_where .= " $report_boolean";}
            my $count2 = 0;
            if ($items{'commentor'}[4]{'commentor'} gt '') {
                #$sqlquery_where .= " cmntr.id = $items{'commentor'}[4]{'commentor'}";
                $sqlquery_where .= " doc.commentor = $items{'commentor'}[4]{'commentor'}";
                $count2++;
            }
            if ($items{'commentor'}[4]{'city'} gt '') {
                if ($count2 > 0) {$sqlquery_where .= " $report_boolean";}
                $sqlquery_where .= " cmntr.city = '$items{'commentor'}[4]{'city'}'";
                $count2++;
            }
            if ($items{'commentor'}[4]{'state'} gt '') {
                if ($count2 > 0) {$sqlquery_where .= " $report_boolean";}
                $sqlquery_where .= " cmntr.state = '$items{'commentor'}[4]{'state'}'";
                $count2++;
            }
            if ($items{'commentor'}[4]{'organization'} gt '') {
                if ($count2 > 0) {$sqlquery_where .= " $report_boolean";}
                my $quotedstring = $args{dbh}->quote($items{'commentor'}[4]{'organization'});
                $sqlquery_where .= " cmntr.organization = $quotedstring";
                $count2++;
            }
            if ($items{'commentor'}[4]{'affiliation'} gt '') {
                if ($count2 > 0) {$sqlquery_where .= " $report_boolean";}
                $sqlquery_where .= " cmntr.affiliation = $items{'commentor'}[4]{'affiliation'}";
                $count2++;
            }
            if ($items{'commentor'}[4]{'postalcode'} gt '') {
                if ($count2 > 0) {$sqlquery_where .= " $report_boolean";}
                $sqlquery_where .= " cmntr.postalcode = '" . $items{'commentor'}[4]{'postalcode'} . "'";
                #my $count3 = 0;
                #my @postalcodes = @{ $items{'commentor'}[4]{'postalcode'} };
                #for my $key (0 .. $#postalcodes) {
                #    if ($count3 > 0) {$sqlquery_where .= " OR ";}
                #    $sqlquery_where .= " cmntr.postalcode = '" . $postalcodes[$key] . "'";
                #    $count3++;
                #}
                $count2++;
            }
            if ($items{'commentor'}[4]{'areacode'} gt '') {
                if ($count2 > 0) {$sqlquery_where .= " $report_boolean";}
                $sqlquery_where .= " cmntr.areacode = '" . $items{'commentor'}[4]{'areacode'} . "'";
                $count2++;
            }
            if ($items{'commentor'}[4]{'faxareacode'} gt '') {
                if ($count2 > 0) {$sqlquery_where .= " $report_boolean";}
                $sqlquery_where .= " cmntr.faxareacode = '" . $items{'commentor'}[4]{'faxareacode'} . "'";
                $count2++;
            }
            $count++;
        }
        if ($items{'commentorname'}[5] eq 'T') {
            if ($count > 0) {$sqlquery_where .= " $report_boolean";}
            if ($items{'commentorname'}[4]{'commentor'} gt '') {
                #$sqlquery_where .= " doc.commentor = $items{'commentorname'}[4]{'commentor'}";
                $sqlquery_where .= " cmntr.id = $items{'commentorname'}[4]{'commentor'}";
            }
            $count++;
        }
        if ($items{'commentoraddress'}[5] eq 'T') {
            if ($count > 0) {$sqlquery_where .= " $report_boolean";}
            my $count2 = 0;
            if ($items{'commentoraddress'}[4]{'city'} gt '') {
                if ($count2 > 0) {$sqlquery_where .= " $report_boolean";}
                $sqlquery_where .= " cmntr.city = '$items{'commentoraddress'}[4]{'city'}'";
                $count2++;
            }
            if ($items{'commentoraddress'}[4]{'state'} gt '') {
                if ($count2 > 0) {$sqlquery_where .= " $report_boolean";}
                $sqlquery_where .= " cmntr.state = '$items{'commentoraddress'}[4]{'state'}'";
                $count2++;
            }
            if ($items{'commentoraddress'}[4]{'postalcode'} gt '') {
                if ($count2 > 0) {$sqlquery_where .= " $report_boolean";}
                $sqlquery_where .= " cmntr.postalcode = '" . $items{'commentoraddress'}[4]{'postalcode'} . "'";
                #my $count3 = 0;
                #my @postalcodes = @{ $items{'commentoraddress'}[4]{'postalcode'} };
                #for my $key (0 .. $#postalcodes) {
                #    if ($count3 > 0) {$sqlquery_where .= " OR ";}
                #    $sqlquery_where .= " cmntr.postalcode = '" . $postalcodes[$key] . "'";
                #    $count3++;
                #}
                $count2++;
            }
            $count++;
        }
        if ($items{'commentororg'}[5] eq 'T') {
            if ($count > 0) {$sqlquery_where .= " $report_boolean";}
            if ($items{'commentororg'}[4]{'organization'} gt '') {
                my $quotedstring = $args{dbh}->quote($items{'commentororg'}[4]{'organization'});
                $sqlquery_where .= " cmntr.organization = $quotedstring";
            }
            $count++;
        }
        if ($items{'commentoraff'}[5] eq 'T') {
            if ($count > 0) {$sqlquery_where .= " $report_boolean";}
            if ($items{'commentoraff'}[4]{'affiliation'} gt '') {
                $sqlquery_where .= " cmntr.affiliation = $items{'commentoraff'}[4]{'affiliation'}";
            }
            $count++;
        }
        if ($items{'commentorphone'}[5] eq 'T') {
            if ($count > 0) {$sqlquery_where .= " $report_boolean";}
            my $count2 = 0;
            if ($items{'commentorphone'}[4]{'areacode'} gt '') {
                if ($count2 > 0) {$sqlquery_where .= " $report_boolean";}
                $sqlquery_where .= " cmntr.areacode = '" . $items{'commentorphone'}[4]{'areacode'} . "'";
                $count2++;
            }
            if ($items{'commentorphone'}[4]{'faxareacode'} gt '') {
                if ($count2 > 0) {$sqlquery_where .= " $report_boolean";}
                $sqlquery_where .= " cmntr.faxareacode = '" . $items{'commentorphone'}[4]{'faxareacode'} . "'";
                $count2++;
            }
            $count++;
        }
        if ($items{'datereceived'}[5] eq 'T') {
            if ($count > 0) {$sqlquery_where .= " $report_boolean";}
            $sqlquery_where .= " (TO_CHAR(doc.datereceived,'YYYY-MM-DD') BETWEEN '$items{'datereceived'}[4]{'startdate'}' AND '$items{'datereceived'}[4]{'enddate'}')";
            
            $count++;
        }
        if ($items{'dateassigned'}[5] eq 'T') {
            if ($count > 0) {$sqlquery_where .= " $report_boolean";}
            $sqlquery_where .= " (TO_CHAR(com.dateassigned,'YYYY-MM-DD') BETWEEN '$items{'dateassigned'}[4]{'startdate'}' AND '$items{'dateassigned'}[4]{'enddate'}')";
            
            $count++;
        }
        if ($items{'dateapproved'}[5] eq 'T') {
            if ($count > 0) {$sqlquery_where .= " $report_boolean";}
            $sqlquery_where .= " (TO_CHAR(com.dateapproved,'YYYY-MM-DD') BETWEEN '$items{'dateapproved'}[4]{'startdate'}' AND '$items{'dateapproved'}[4]{'enddate'}')";
            
            $count++;
        }
        if ($items{'dateupdated'}[5] eq 'T') {
            if ($count > 0) {$sqlquery_where .= " $report_boolean";}
            $sqlquery_where .= " (TO_CHAR(rv.dateupdated,'YYYY-MM-DD') BETWEEN '$items{'dateupdated'}[4]{'startdate'}' AND '$items{'dateupdated'}[4]{'enddate'}')";
            
            $count++;
        }
        if ($items{'addressee'}[5] eq 'T') {
            if ($count > 0) {$sqlquery_where .= " $report_boolean";}
            $sqlquery_where .= " doc.addressee = '$items{'addressee'}[4]{'addressee'}'";
            
            $count++;
        }
        if ($items{'evaluationfactor'}[5] eq 'T') {
            if ($count > 0) {$sqlquery_where .= " $report_boolean";}
            if ($items{'evaluationfactor'}[4]{'id'} != -1) {
                $sqlquery_where .= " doc.evaluationfactor = '$items{'evaluationfactor'}[4]{'id'}'";
            } else {
                $sqlquery_where .= " doc.evaluationfactor IS NULL";
            }
            $count++;
            
        }
        if ($items{'srcomments'}[5] eq 'T') {
            if ($items{'srcomments'}[4]{'selection'} ne 'both') {
                if ($count > 0) {$sqlquery_where .= " $report_boolean";}
                if ($items{'srcomments'}[4]{'selection'} eq 'with') {
                    $sqlquery_where .= " doc.hassrcomments = 'T'";
                } else {
                    $sqlquery_where .= " doc.hassrcomments = 'F'";
                }
                $count++;
            }
        }
        if ($items{'lacomments'}[5] eq 'T') {
            if ($items{'lacomments'}[4]{'selection'} ne 'both') {
                if ($count > 0) {$sqlquery_where .= " $report_boolean";}
                if ($items{'lacomments'}[4]{'selection'} eq 'with') {
                    $sqlquery_where .= " doc.haslacomments = 'T'";
                } else {
                    $sqlquery_where .= " doc.haslacomments = 'F'";
                }
                $count++;
            }
        }
        if ($items{'960comments'}[5] eq 'T') {
            if ($items{'960comments'}[4]{'selection'} ne 'both') {
                if ($count > 0) {$sqlquery_where .= " $report_boolean";}
                if ($items{'960comments'}[4]{'selection'} eq 'with') {
                    $sqlquery_where .= " doc.has960comments = 'T'";
                } else {
                    $sqlquery_where .= " doc.has960comments = 'F'";
                }
                $count++;
            }
        }
        if ($items{'summary'}[5] eq 'T') {
            if ($items{'summary'}[4]{'selection'} ne 'both') {
                if ($count > 0) {$sqlquery_where .= " $report_boolean";}
                if ($items{'summary'}[4]{'selection'} eq 'with') {
                    $sqlquery_where .= " com.summary > 0";
                } else {
                    #$sqlquery_where .= "  com.summary IS NULL AND ((com.document,com.commentnum) NOT IN (SELECT document,commentnum FROM $args{schema}.comments WHERE dupsimdocumentid IS NOT NULL))";
                    $sqlquery_where .= "  com.summary IS NULL";
                }
                $count++;
            }
        }
        if ($items{'wasrescanned'}[5] eq 'T') {
            if ($items{'wasrescanned'}[4]{'selection'} ne 'both') {
                if ($count > 0) {$sqlquery_where .= " $report_boolean";}
                if ($items{'wasrescanned'}[4]{'selection'} eq 'with') {
                    $sqlquery_where .= " doc.wasrescanned = 'T'";
                } else {
                    $sqlquery_where .= " doc.wasrescanned = 'F'";
                }
                $count++;
            }
        }
        if ($items{'enclosures'}[5] eq 'T') {
            if ($items{'enclosures'}[4]{'selection'} ne 'both') {
                if ($count > 0) {$sqlquery_where .= " $report_boolean";}
                if ($items{'enclosures'}[4]{'selection'} eq 'with') {
                    $sqlquery_where .= " doc.hasenclosures = 'T'";
                } else {
                    $sqlquery_where .= " doc.hasenclosures = 'F'";
                }
                $count++;
            }
        }
        if ($items{'changeimpact'}[5] eq 'T') {
            if ($count > 0) {$sqlquery_where .= " $report_boolean";}
            $sqlquery_where .= " com.changeimpact = $items{'changeimpact'}[4]{'selection'}";
            $count++;
        }
        if ($items{'commitments'}[5] eq 'T') {
            if ($items{'commitments'}[4]{'selection'} ne 'both') {
                if ($count > 0) {$sqlquery_where .= " $report_boolean";}
                if ($items{'commitments'}[4]{'selection'} eq 'with') {
                    $sqlquery_where .= " com.hascommitments = 'T'";
                } else {
                    $sqlquery_where .= " com.hascommitments = 'F'";
                }
                $count++;
            }
        }
        if ($items{'hasissues'}[5] eq 'T') {
            if ($items{'hasissues'}[4]{'selection'} ne 'both') {
                if ($count > 0) {$sqlquery_where .= " $report_boolean";}
                if ($items{'hasissues'}[4]{'selection'} eq 'with') {
                    $sqlquery_where .= " com.hasissues = 'T'";
                } else {
                    $sqlquery_where .= " com.hasissues = 'F'";
                }
                $count++;
            }
        }
########
        if ($items{'commenttext'}[5] eq 'T') {
            if ($items{'commenttext'}[4]{'searchtext'} gt '    ') {
                if ($count > 0) {$sqlquery_where .= " $report_boolean";}
                $sqlquery_where .= " com.text like '%" . $items{'commenttext'}[4]{'searchtext'} . "%'";
                $count++;
            }
        }

        if ($items{'response'}[5] eq 'T') {
            if ($items{'response'}[4]{'searchtext'} gt '    ') {
                if ($count > 0) {$sqlquery_where .= " $report_boolean";}
                $sqlquery_where .= " rv.lastsubmittedtext like '%" . $items{'response'}[4]{'searchtext'} . "%'";
                $count++;
            }
        }

        if ($items{'docremarks'}[5] eq 'T') {
            if ($items{'docremarks'}[4]{'searchtext'} gt '    ') {
                if ($count > 0) {$sqlquery_where .= " $report_boolean";}
                $sqlquery_where .= " docr.text like '%" . $items{'docremarks'}[4]{'searchtext'} . "%'";
                $count++;
            }
        }

        if ($items{'comremarks'}[5] eq 'T') {
            if ($items{'comremarks'}[4]{'searchtext'} gt '    ') {
                if ($count > 0) {$sqlquery_where .= " $report_boolean";}
                $sqlquery_where .= " comr.text like '%" . $items{'comremarks'}[4]{'searchtext'} . "%'";
                $count++;
            }
        }

        
        if (defined($crdcgi->param('extra_where_info')) && $crdcgi->param('extra_where_info') gt '') {
            if ($count > 0) {$sqlquery_where .= " $report_boolean";}
            $sqlquery_where .= $crdcgi->param('extra_where_info');
            $count++;
        
        }
        
        
        $sqlquery_where .= ") ";
    }
    
    
    # build sql statement
    $sqlquery = $sqlquery_select . $sqlquery_from . $sqlquery_where . $sqlquery_order;
    
    #
    eval {
        if ($args{'command'} eq 'adhoctest') {
            $sqlquery =~ s/ (\+)/(\+)/g;
            
            $outputstring .= "\n\n $sqlquery \n\n";
            foreach $key (sort keys %args) {
                $outputstring .= "$key - $args{$key}\n"
            }
            $outputstring .= "\n";
                $outputstring .= "\n*************************************************\n";
                foreach $key (keys %items) {
                    $outputstring .= "\n$key - $items{$key}[0] - $items{$key}[1] - $items{$key}[2]\n";
                    $outputstring .= "$items{$key}[3][0]\n";
                    for ($key2=0; $key2 <= $#{ $items{$key}[3] }; $key2++) {$outputstring .= "$items{$key}[3][$key2], ";}
                    foreach $key2 (keys %{ $items{$key}[4] }) 
                        {$outputstring .= "$key2 - $items{$key}[4]{$key2}, ";}
                    $outputstring .= ";\n";
                    $outputstring .= "$items{$key}[5]\n***\n";
                }
                $outputstring .= "\n*************************************************\n";
print STDERR "**************  $sqlquery *******\n";
            @values = $dbh->selectrow_array($sqlquery);
            if ($values[0] < 1) {
                $outputstring .= "<script language=javascript><!--\n";
                $outputstring .= "   alert('Selections generated an empty report');\n";
                $outputstring .= "//-->\n";
                $outputstring .= "</script>\n";
                $outputstring .= "<br>\n\n$sqlquery\n\n<br>\n";
                $outputstring .= "HasSelections = $hasSelections\n";
                $outputstring .= "\n*************************************************\n";
                foreach $key (keys %tables) {
                    $outputstring .= "\n$key, $tables{$key}[0]\n";
                    $outputstring .= "$tables{$key}[1][0]\n";
                    $outputstring .= "$tables{$key}[2] - $tables{$key}[2]\n";
                }
                $outputstring .= "\n*************************************************\n";
                foreach $key (keys %items) {
                    $outputstring .= "\n$key - $items{$key}[0] - $items{$key}[1] - $items{$key}[2]\n";
                    $outputstring .= "$items{$key}[3][0]\n";
                    for ($key2=0; $key2 <= $#{ $items{$key}[3] }; $key2++) {$outputstring .= "$items{$key}[3][$key2], ";}
                    foreach $key2 (keys %{ $items{$key}[4] }) 
                        {$outputstring .= "$key2 - $items{$key}[4]{$key2}, ";}
                    $outputstring .= ";\n";
                    $outputstring .= "$items{$key}[5]\n***\n";
                }
                $outputstring .= "\n*************************************************\n";
                $outputstring .= "bincoordinators: ";
                for ($key2=0; $key2 <= $#{ $items{'bincoordinator'}[4]{'userlist'} }; $key2++) {$outputstring .= "$items{'bincoordinator'}[4]{'userlist'}[$key2] ";}
                $outputstring .= "<**>\n";
                $outputstring .= [ $crdcgi->param('bincoordinator') ];
                $outputstring .= "\n";
                $outputstring .= "responsewriters: ";
                for ($key2=0; $key2 <= $#{ $items{'responsewriter'}[4]{'userlist'} }; $key2++) {$outputstring .= "$items{'responsewriter'}[4]{'userlist'}[$key2] ";}
                $outputstring .= "<**>\n";
            } else {
                
                $outputstring .= "<input type=hidden name='reporttitle' value=\"" . $reporttitle . "\">\n";
                $outputstring .= "<input type=hidden name='sortdirection' value='" . $crdcgi->param('sortdirection') . "'>\n";
                $outputstring .= "<input type=hidden name='report_boolean' value='" . $crdcgi->param('report_boolean') . "'>\n";
                $outputstring .= "<input type=hidden name='text_limit' value='" . ((defined($crdcgi->param('text_limit'))) ? $crdcgi->param('text_limit') : "F") . "'>\n";
                
                $outputstring .= "<input type=hidden name='sortorder' value='" . $crdcgi->param('sortorder') . "'>\n";

#
##################
#

                $outputstring .= "<input type=hidden name='doc_selected' value='" . ((defined($crdcgi->param('doc_selected'))) ? $crdcgi->param('doc_selected') : "") . "'>\n";
                $outputstring .= "<input type=hidden name='documentid' value='" . ((defined($crdcgi->param('documentid'))) ? $crdcgi->param('documentid') : "") . "'>\n";
                $outputstring .= "<input type=hidden name='commentnum' value='" . ((defined($crdcgi->param('commentnum'))) ? $crdcgi->param('commentnum') : "") . "'>\n";
                $outputstring .= "<input type=hidden name='use_all_docs' value='" . ((defined($crdcgi->param('use_all_docs'))) ? $crdcgi->param('use_all_docs') : "") . "'>\n";
                $outputstring .= "<input type=hidden name='use_only_docs' value='" . ((defined($crdcgi->param('use_only_docs'))) ? $crdcgi->param('use_only_docs') : "") . "'>\n";

                $outputstring .= "<input type=hidden name='startingdocid' value='" . ((defined($crdcgi->param('startingdocid'))) ? $crdcgi->param('startingdocid') : "") . "'>\n";
                $outputstring .= "<input type=hidden name='endingdocid' value='" . ((defined($crdcgi->param('endingdocid'))) ? $crdcgi->param('endingdocid') : "") . "'>\n";

                $outputstring .= "<input type=hidden name='mindocid' value='" . ((defined($crdcgi->param('mindocid'))) ? $crdcgi->param('mindocid') : "") . "'>\n";
                $outputstring .= "<input type=hidden name='maxdocid' value='" . ((defined($crdcgi->param('maxdocid'))) ? $crdcgi->param('maxdocid') : "") . "'>\n";

                $outputstring .= "<input type=hidden name='doctype_selected' value='" . ((defined($crdcgi->param('doctype_selected'))) ? $crdcgi->param('doctype_selected') : "") . "'>\n";
                $outputstring .= "<input type=hidden name='doctype' value='" . ((defined($crdcgi->param('doctype'))) ? $crdcgi->param('doctype') : "") . "'>\n";
                
                $outputstring .= "<input type=hidden name='bin_selected' value='" . ((defined($crdcgi->param('bin_selected'))) ? $crdcgi->param('bin_selected') : "") . "'>\n";
                $outputstring .= "<input type=hidden name='binid' value='" . ((defined($crdcgi->param('binid'))) ? $crdcgi->param('binid') : "") . "'>\n";
                $outputstring .= "<input type=hidden name='usesubbins' value='" . ((defined($crdcgi->param('usesubbins'))) ? $crdcgi->param('usesubbins') : "F") . "'>\n";
                
                $outputstring .= "<input type=hidden name='bincoordinator_selected' value='" . ((defined($crdcgi->param('bincoordinator_selected'))) ? $crdcgi->param('bincoordinator_selected') : "") . "'>\n";
                $outputstring .= "<select multiple name='bincoordinator' size=5>\n";
                for $key (0 .. $#{ $items{'bincoordinator'}[4]{'userlist'} }) {
                    $outputstring .= "<option value='$items{'bincoordinator'}[4]{'userlist'}[$key]' selected>$items{'bincoordinator'}[4]{'userlist'}[$key]</option>\n";
                }
                $outputstring .= "</select>\n";
                $outputstring .= "<input type=hidden name='bincoordinator_detail' value='" . ((defined($crdcgi->param('bincoordinator_detail'))) ? $crdcgi->param('bincoordinator_detail') : "F") . "'>\n";
                
                $outputstring .= "<input type=hidden name='responsewriter_selected' value='" . ((defined($crdcgi->param('responsewriter_selected'))) ? $crdcgi->param('responsewriter_selected') : "") . "'>\n";
                $outputstring .= "<select multiple name='responsewriter' size=5>\n";
                for $key (0 .. $#{ $items{'responsewriter'}[4]{'userlist'} }) {
                    $outputstring .= "<option value='$items{'responsewriter'}[4]{'userlist'}[$key]' selected>$items{'responsewriter'}[4]{'userlist'}[$key]</option>\n";
                }
                $outputstring .= "</select>\n";
                $outputstring .= "<input type=hidden name='responsewriter_detail' value='" . ((defined($crdcgi->param('responsewriter_detail'))) ? $crdcgi->param('responsewriter_detail') : "F") . "'>\n";

                $outputstring .= "<input type=hidden name='responsestatus_selected' value='" . ((defined($crdcgi->param('responsestatus_selected'))) ? $crdcgi->param('responsestatus_selected') : "") . "'>\n";
                $outputstring .= "<select multiple name='responsestatus' size=5>\n";
                #if ($items{'responsestatus'}[5] eq 'T') {
                    for $key (0 .. $#{ $items{'responsestatus'}[4]{'list'} }) {
                        $outputstring .= "<option value='$items{'responsestatus'}[4]{'list'}[$key]' selected>$items{'responsestatus'}[4]{'list'}[$key]</option>\n";
                    }
                #}
                $outputstring .= "</select>\n";
                #$outputstring .= "<input type=hidden name='responsestatus' value='" . ((defined($crdcgi->param('responsestatus'))) ? $crdcgi->param('responsestatus') : "") . "'>\n";
                
                $outputstring .= "<input type=hidden name='technicalreviewer_selected' value='" . ((defined($crdcgi->param('technicalreviewer_selected'))) ? $crdcgi->param('technicalreviewer_selected') : "") . "'>\n";
                $outputstring .= "<select multiple name='technicalreviewer' size=5>\n";
                for $key (0 .. $#{ $items{'technicalreviewer'}[4]{'userlist'} }) {
                    $outputstring .= "<option value='$items{'technicalreviewer'}[4]{'userlist'}[$key]' selected>$items{'technicalreviewer'}[4]{'userlist'}[$key]</option>\n";
                }
                $outputstring .= "</select>\n";
                $outputstring .= "<input type=hidden name='technicalreviewer_detail' value='" . ((defined($crdcgi->param('technicalreviewer_detail'))) ? $crdcgi->param('technicalreviewer_detail') : "F") . "'>\n";
                
                $outputstring .= "<input type=hidden name='nepareviewer_selected' value='" . ((defined($crdcgi->param('nepareviewer_selected'))) ? $crdcgi->param('nepareviewer_selected') : "F") . "'>\n";
                $outputstring .= "<select multiple name='nepareviewer' size=5>\n";
                if ($items{'nepareviewer'}[5] eq 'T') {
                    for $key (0 .. $#{ $items{'nepareviewer'}[4]{'userlist'} }) {
                        $outputstring .= "<option value='$items{'nepareviewer'}[4]{'userlist'}[$key]' selected>$items{'nepareviewer'}[4]{'userlist'}[$key]</option>\n";
                    }
                }
                $outputstring .= "</select>\n";
                $outputstring .= "<input type=hidden name='nepareviewer_detail' value='" . ((defined($crdcgi->param('nepareviewer_detail'))) ? $crdcgi->param('nepareviewer_detail') : "F") . "'>\n";

                $outputstring .= "<input type=hidden name='commentor_selected' value='" . ((defined($crdcgi->param('commentor_selected'))) ? $crdcgi->param('commentor_selected') : "") . "'>\n";
                $outputstring .= "<input type=hidden name='commentorid' value='" . $crdcgi->param('commentorid') . "'>\n";
                $outputstring .= "<input type=hidden name='cityid' value='" . $crdcgi->param('cityid') . "'>\n";
                $outputstring .= "<input type=hidden name='stateid' value='" . $crdcgi->param('stateid') . "'>\n";
                $outputstring .= "<input type=hidden name='organization' value=\"" . $crdcgi->param('organization') . "\">\n";
                $outputstring .= "<input type=hidden name='affiliationid' value='" . $crdcgi->param('affiliationid') . "'>\n";
                $outputstring .= "<input type=hidden name='commentordetail' value='" . ((defined($crdcgi->param('commentordetail'))) ? $crdcgi->param('commentordetail') : "F") . "'>\n";
                $outputstring .= "<input type=hidden name='postalcode' value='" . $crdcgi->param('postalcode') . "'>\n";
                #my @postalcodes = $crdcgi->param('postalcode');
                #$outputstring .= "<select multiple name='postalcode' size=5>\n";
                #for $key (0 .. $#postalcodes) {
                #    $outputstring .= "<option value='$postalcodes[$key]' selected>$postalcodes[$key]</option>\n";
                #}
                #$outputstring .= "</select>\n";
                $outputstring .= "<input type=hidden name='areacode' value='" . $crdcgi->param('areacode') . "'>\n";
                $outputstring .= "<input type=hidden name='faxareacode' value='" . $crdcgi->param('faxareacode') . "'>\n";

                $outputstring .= "<input type=hidden name='commentorname_selected' value='" . ((defined($crdcgi->param('commentorname_selected'))) ? $crdcgi->param('commentorname_selected') : "") . "'>\n";
                $outputstring .= "<input type=hidden name='commentoraddress_selected' value='" . ((defined($crdcgi->param('commentoraddress_selected'))) ? $crdcgi->param('commentoraddress_selected') : "") . "'>\n";
                $outputstring .= "<input type=hidden name='commentororg_selected' value='" . ((defined($crdcgi->param('commentororg_selected'))) ? $crdcgi->param('commentororg_selected') : "") . "'>\n";
                $outputstring .= "<input type=hidden name='commentoraff_selected' value='" . ((defined($crdcgi->param('commentoraff_selected'))) ? $crdcgi->param('commentoraff_selected') : "") . "'>\n";
                $outputstring .= "<input type=hidden name='commentorphone_selected' value='" . ((defined($crdcgi->param('commentorphone_selected'))) ? $crdcgi->param('commentorphone_selected') : "") . "'>\n";
                $outputstring .= "<input type=hidden name='commentoremail_selected' value='" . ((defined($crdcgi->param('commentoremail_selected'))) ? $crdcgi->param('commentoremail_selected') : "") . "'>\n";
                $outputstring .= "<input type=hidden name='commentorposition_selected' value='" . ((defined($crdcgi->param('commentorposition_selected'))) ? $crdcgi->param('commentorposition_selected') : "") . "'>\n";
                
                $outputstring .= "<input type=hidden name='date_received_selected' value='" . ((defined($crdcgi->param('date_received_selected'))) ? $crdcgi->param('date_received_selected') : "") . "'>\n";
                $outputstring .= "<input type=hidden name='date_received_start' value='" . $items{'datereceived'}[4]{'startdate'} . "'>\n";
                $outputstring .= "<input type=hidden name='date_received_end' value='" . $items{'datereceived'}[4]{'enddate'} . "'>\n";
                
                $outputstring .= "<input type=hidden name='date_assigned_selected' value='" . ((defined($crdcgi->param('date_assigned_selected'))) ? $crdcgi->param('date_assigned_selected') : "") . "'>\n";
                $outputstring .= "<input type=hidden name='date_assigned_start' value='" . $items{'dateassigned'}[4]{'startdate'} . "'>\n";
                $outputstring .= "<input type=hidden name='date_assigned_end' value='" . $items{'dateassigned'}[4]{'enddate'} . "'>\n";
                
                $outputstring .= "<input type=hidden name='date_approved_selected' value='" . ((defined($crdcgi->param('date_approved_selected'))) ? $crdcgi->param('date_approved_selected') : "") . "'>\n";
                $outputstring .= "<input type=hidden name='date_approved_start' value='" . $items{'dateapproved'}[4]{'startdate'} . "'>\n";
                $outputstring .= "<input type=hidden name='date_approved_end' value='" . $items{'dateapproved'}[4]{'enddate'} . "'>\n";
                
                $outputstring .= "<input type=hidden name='date_updated_selected' value='" . ((defined($crdcgi->param('date_updated_selected'))) ? $crdcgi->param('date_updated_selected') : "") . "'>\n";
                $outputstring .= "<input type=hidden name='date_updated_start' value='" . $items{'dateupdated'}[4]{'startdate'} . "'>\n";
                $outputstring .= "<input type=hidden name='date_updated_end' value='" . $items{'dateupdated'}[4]{'enddate'} . "'>\n";
                
                $outputstring .= "<input type=hidden name='addressee_selected' value='" . ((defined($crdcgi->param('addressee_selected'))) ? $crdcgi->param('addressee_selected') : "") . "'>\n";
                $outputstring .= "<input type=hidden name='addressee' value='" . ((defined($crdcgi->param('addressee'))) ? $crdcgi->param('addressee') : "") . "'>\n";
                
                $outputstring .= "<input type=hidden name='evaluationfactor_selected' value='" . ((defined($crdcgi->param('evaluationfactor_selected'))) ? $crdcgi->param('evaluationfactor_selected') : "") . "'>\n";
                $outputstring .= "<input type=hidden name='evaluationfactor' value='" . ((defined($crdcgi->param('evaluationfactor'))) ? $crdcgi->param('evaluationfactor') : "") . "'>\n";
                
                $outputstring .= "<input type=hidden name='hassrcomments_selected' value='" . ((defined($crdcgi->param('hassrcomments_selected'))) ? $crdcgi->param('hassrcomments_selected') : "") . "'>\n";
                $outputstring .= "<input type=hidden name='hassrcomments' value='" . ((defined($crdcgi->param('hassrcomments'))) ? $crdcgi->param('hassrcomments') : "") . "'>\n";
                
                $outputstring .= "<input type=hidden name='haslacomments_selected' value='" . ((defined($crdcgi->param('haslacomments_selected'))) ? $crdcgi->param('haslacomments_selected') : "") . "'>\n";
                $outputstring .= "<input type=hidden name='haslacomments' value='" . ((defined($crdcgi->param('haslacomments'))) ? $crdcgi->param('haslacomments') : "") . "'>\n";
                
                $outputstring .= "<input type=hidden name='has960comments_selected' value='" . ((defined($crdcgi->param('has960comments_selected'))) ? $crdcgi->param('has960comments_selected') : "") . "'>\n";
                $outputstring .= "<input type=hidden name='has960comments' value='" . ((defined($crdcgi->param('has960comments'))) ? $crdcgi->param('has960comments') : "") . "'>\n";
                
                $outputstring .= "<input type=hidden name='wasrescanned_selected' value='" . ((defined($crdcgi->param('wasrescanned_selected'))) ? $crdcgi->param('wasrescanned_selected') : "") . "'>\n";
                $outputstring .= "<input type=hidden name='wasrescanned' value='" . ((defined($crdcgi->param('wasrescanned'))) ? $crdcgi->param('wasrescanned') : "") . "'>\n";
                
                $outputstring .= "<input type=hidden name='hasenclosures_selected' value='" . ((defined($crdcgi->param('hasenclosures_selected'))) ? $crdcgi->param('hasenclosures_selected') : "") . "'>\n";
                $outputstring .= "<input type=hidden name='hasenclosures' value='" . ((defined($crdcgi->param('hasenclosures'))) ? $crdcgi->param('hasenclosures') : "") . "'>\n";
                
                $outputstring .= "<input type=hidden name='changeimpact_selected' value='" . ((defined($crdcgi->param('changeimpact_selected'))) ? $crdcgi->param('changeimpact_selected') : "") . "'>\n";
                $outputstring .= "<input type=hidden name='changeimpact' value='" . ((defined($crdcgi->param('changeimpact'))) ? $crdcgi->param('changeimpact') : "") . "'>\n";
                
                $outputstring .= "<input type=hidden name='commitments_selected' value='" . ((defined($crdcgi->param('commitments_selected'))) ? $crdcgi->param('commitments_selected') : "") . "'>\n";
                $outputstring .= "<input type=hidden name='commitments' value='" . ((defined($crdcgi->param('commitments'))) ? $crdcgi->param('commitments') : "") . "'>\n";
                
                $outputstring .= "<input type=hidden name='hasissues_selected' value='" . ((defined($crdcgi->param('hasissues_selected'))) ? $crdcgi->param('hasissues_selected') : "") . "'>\n";
                $outputstring .= "<input type=hidden name='hasissues' value='" . ((defined($crdcgi->param('hasissues'))) ? $crdcgi->param('hasissues') : "") . "'>\n";
                
                $outputstring .= "<input type=hidden name='comments_selected' value='" . ((defined($crdcgi->param('comments_selected'))) ? $crdcgi->param('comments_selected') : "") . "'>\n";
                $outputstring .= "<input type=hidden name='commentsearchtext' value='" . ((defined($crdcgi->param('commentsearchtext'))) ? $crdcgi->param('commentsearchtext') : "") . "'>\n";
                
                $outputstring .= "<input type=hidden name='response_selected' value='" . ((defined($crdcgi->param('response_selected'))) ? $crdcgi->param('response_selected') : "") . "'>\n";
                $outputstring .= "<input type=hidden name='responsesearchtext' value='" . ((defined($crdcgi->param('responsesearchtext'))) ? $crdcgi->param('responsesearchtext') : "") . "'>\n";
                
                $outputstring .= "<input type=hidden name='techreviewtext_selected' value='" . ((defined($crdcgi->param('techreviewtext_selected'))) ? $crdcgi->param('techreviewtext_selected') : "") . "'>\n";
                
                $outputstring .= "<input type=hidden name='doc_remarks_selected' value='" . ((defined($crdcgi->param('doc_remarks_selected'))) ? $crdcgi->param('doc_remarks_selected') : "") . "'>\n";
                $outputstring .= "<input type=hidden name='docremarkssearchtext' value='" . ((defined($crdcgi->param('docremarkssearchtext'))) ? $crdcgi->param('docremarkssearchtext') : "") . "'>\n";
                
                $outputstring .= "<input type=hidden name='com_remarks_selected' value='" . ((defined($crdcgi->param('com_remarks_selected'))) ? $crdcgi->param('com_remarks_selected') : "") . "'>\n";
                $outputstring .= "<input type=hidden name='comremarkssearchtext' value='" . ((defined($crdcgi->param('comremarkssearchtext'))) ? $crdcgi->param('comremarkssearchtext') : "") . "'>\n";
                
                $outputstring .= "<input type=hidden name='start_page_selected' value='" . ((defined($crdcgi->param('start_page_selected'))) ? $crdcgi->param('start_page_selected') : "") . "'>\n";
                
                $outputstring .= "<input type=hidden name='scr_indicator_selected' value='" . ((defined($crdcgi->param('scr_indicator_selected'))) ? $crdcgi->param('scr_indicator_selected') : "") . "'>\n";
                $outputstring .= "<input type=hidden name='scr_indicator' value='" . ((defined($crdcgi->param('scr_indicator'))) ? $crdcgi->param('scr_indicator') : "") . "'>\n";
                
                $outputstring .= "<input type=hidden name='dup_comment_selected' value='" . ((defined($crdcgi->param('dup_comment_selected'))) ? $crdcgi->param('dup_comment_selected') : "") . "'>\n";

                $outputstring .= "<input type=hidden name='extra_where_info' value=\"" . ((defined($crdcgi->param('extra_where_info'))) ? $crdcgi->param('extra_where_info') : "") . "\">\n";

                $outputstring .= "<input type=hidden name='excludetable' value=\"" . ((defined($crdcgi->param('excludetable'))) ? $crdcgi->param('excludetable') : "") . "\">\n";

#
##################
#

                if ($items{'summary'}[5] eq 'T' && $items{'summary'}[4]{'selection'} eq 'without') {
                    # build sql statement
                    my $sqlquery = "SELECT com.document,com.commentnum,com.dupsimdocumentid,com.dupsimcommentid " . $sqlquery_from . $sqlquery_where . " AND com.dupsimstatus=2 " . $sqlquery_order;
                    my $csr = $args{dbh}->prepare($sqlquery);
                    my $status = $csr->execute;
                    while (my ($docID,$comID,$dupDoc,$dupCom) = $csr->fetchrow_array) {
                        my $summaryID = get_value($args{dbh},$args{schema},'comments','summary', "document = $dupDoc AND commentnum = $dupCom");
                        if (defined($summaryID)) {
                            $values[0]--;
                        }
                    }
                    $csr->finish;
                }

                $outputstring .= "<script language=javascript><!--\n";
                $outputstring .= "    if (confirm('Found $values[0] record" . (($values[0] != 1) ? "s" : "") . ".\\nDo you wish to continue?')) {\n";
                $outputstring .= "        submitFormNewWindow('$form', 'adhocreport', 'adhocreport');\n";
                $outputstring .= "    };\n";
                $outputstring .= "//-->\n";
                $outputstring .= "</script>\n";
                $outputstring .= "<br>\n\n$sqlquery\n\n<br>\n";
            }
        }
        if ($command eq 'adhocreport') {
            
            #
$outputstring .= "\n\n<!-- $sqlquery -->\n\n";
#my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime;
#$mon = substr("00" . ++$mon, -2);
#$mday = substr("00" . $mday, -2);
#$year += 1900;
#$hour = substr("00" . $hour, -2);
#$min = substr("00" . $min, -2);
#$sec = substr("00" . $sec, -2);
#print STDERR "\nad_hoc_reports.pl SQL Query: $mon/$mday/$year $hour:$min:$sec - $username/$userid/$schema - \n$sqlquery\n\n";

            $csr = $args{'dbh'}->prepare($sqlquery);
            $status = $csr->execute;
            $count = 0;
            $outputstring .= "<script language=javascript><!--\n";
            $outputstring .= "    document.title=\"" . htmlStrip($crdcgi->param('reporttitle')) . "\";\n";
            $outputstring .= "//--></script>\n";
            $outputstring .= "<table border=0 width=670><tr><td><font size=-1>\n";
            $outputstring .= "<center><font size=+2>" . $crdcgi->param('reporttitle') . "</font><br>\n";
            $outputstring .= "$args{'run_date'}</center>\n";
            while (@values = $csr->fetchrow_array) {
              my $skipRecord = 'False';
              if ($items{'summary'}[5] eq 'T' && $items{'summary'}[4]{'selection'} eq 'without' && $values[$fields{'com_dupsimstatus'}] == 2) {
                  my $summaryID = get_value($args{dbh},$args{schema},'comments','summary', "document = $values[$fields{'com_dupsimdocumentid'}] AND commentnum = $values[$fields{'com_dupsimcommentid'}]");
                  if (defined($summaryID)) {
                      $skipRecord = 'True';
                  }
              }
              if ($skipRecord ne 'True') {
                $count++;
                $itemcount=0;
                $outputstring .= "<br><hr>\n";

#
##################
#

                if ($items{'cdidcid'}[0] eq 'T') {
                    $outputstring .= $CRDType . lpadzero($values[$fields{'doc_id'}],6);
                    if (defined($values[$fields{'com_commentnum'}]) && $values[$fields{'com_commentnum'}] >= 1) {
                        $outputstring .= " / " . lpadzero($values[$fields{'com_commentnum'}], 4);
                    }
                    if ($items{'responsestatus'}[0] eq 'T' && $values[$fields{'doc_dupsimstatus'}] == 1) {
                        if ($tables{'response_version'}[0] eq 'T' && defined($values[$fields{'rv_status'}]) && $values[$fields{'rv_status'}] >= 1 && $values[$fields{'com_dupsimstatus'}] == 1) {
                            $outputstring .= " - Status: " . get_value($args{'dbh'},$args{'schema'},'response_status', 'name', "id = $values[$fields{'rv_status'}]");
                        }
                    }
                    $outputstring .= "<br>\n";
                    if ($values[$fields{'doc_dupsimstatus'}] == 2) {
                        $outputstring .= "Document is a duplicate of " . $CRDType . lpadzero($values[$fields{'doc_dupsimid'}],6) . "<br>\n";
                    }
                }
                if ($items{'docid'}[0] eq 'T') {
                    $outputstring .= $CRDType . lpadzero($values[$fields{'doc_id'}],6);
                    $outputstring .= "<br>\n";
                    if ($values[$fields{'doc_dupsimstatus'}] == 2) {
                        $outputstring .= "Document is a duplicate of " . $CRDType . lpadzero($values[$fields{'doc_dupsimid'}],6) . "<br>\n";
                    }
                }
                if ($items{'doctype'}[0] eq 'T') {
                    $outputstring .= "Document Type: " . get_value($args{'dbh'},$args{'schema'}, 'document_type', 'name', "id = $values[$fields{'doc_documenttype'}]") ."<br>\n";
                }
                if ($items{'dupcomment'}[0] eq 'T' && defined($values[$fields{'com_dupsimstatus'}]) && $values[$fields{'com_dupsimstatus'}] == 2) {
                    $outputstring .= "Comment is a duplicate of " . $CRDType . lpadzero($values[$fields{'com_dupsimdocumentid'}],6) . " / " . lpadzero($values[$fields{'com_dupsimcommentid'}],4) . "<br>\n";
                }
                if ($items{'summary'}[0] eq 'T' && defined($values[$fields{'com_summary'}]) && $values[$fields{'com_summary'}] > 0) {
                    $outputstring .= "Comment summarized by: SCR" . lpadzero($values[$fields{'com_summary'}],4) . "<br>\n";
                }
                if ($items{'binid'}[0] eq 'T') {
                    if (defined($values[$fields{'bin_id'}]) && $values[$fields{'bin_id'}] >= 1) {
                        $outputstring .= "Bin: " . $values[$fields{'bin_name'}] . "<br>\n";
                    }
                }
                if ($items{'bincoordinator'}[0] eq 'T' && defined($values[$fields{'bin_coordinator'}])) {
                    $outputstring .= "Bin Coordinator: " . get_fullname($args{'dbh'},$args{'schema'},$values[$fields{'bin_coordinator'}]) . "<br>\n";
                    if ($items{'bincoordinator'}[4]{'details'} eq 'T') {
                        $outputstring .= nbspaces(10) . "Location: ". get_value($args{'dbh'},$args{'schema'}, 'users', 'location', "id = $values[$fields{'bin_coordinator'}]") . "<br>\n";
                        $outputstring .= nbspaces(10) . "Organization: ". get_value($args{'dbh'},$args{'schema'}, 'users', 'organization', "id = $values[$fields{'bin_coordinator'}]") . "<br>\n";
                        $outputstring .= nbspaces(10) . "Email address: ". get_value($args{'dbh'},$args{'schema'}, 'users', 'email', "id = $values[$fields{'bin_coordinator'}]") . "<br>\n";
                        $outputstring .= nbspaces(10) . "Phone: (". get_value($args{'dbh'},$args{'schema'}, 'users', 'areacode', "id = $values[$fields{'bin_coordinator'}]") . ") ". substr(get_value($args{'dbh'},$args{'schema'}, 'users', 'phonenumber', "id = $values[$fields{'bin_coordinator'}]"),0,3) . "-" . substr(get_value($args{'dbh'},$args{'schema'}, 'users', 'phonenumber', "id = $values[$fields{'bin_coordinator'}]"),3,4) . nbspaces(4) . get_value($args{'dbh'},$args{'schema'}, 'users', "NVL(extension,' ')", "id = $values[$fields{'bin_coordinator'}]") . "<br>\n";
                    }
                }
                if ($items{'responsewriter'}[0] eq 'T' && defined($values[$fields{'rv_responsewriter'}])) {
                    $outputstring .= "Response Writer: " . get_fullname($args{'dbh'},$args{'schema'},$values[$fields{'rv_responsewriter'}]) . "<br>\n";
                    if ($items{'responsewriter'}[4]{'details'} eq 'T') {
                        $outputstring .= nbspaces(10) . "Location: ". get_value($args{'dbh'},$args{'schema'}, 'users', 'location', "id = $values[$fields{'rv_responsewriter'}]") . "<br>\n";
                        $outputstring .= nbspaces(10) . "Organization: ". get_value($args{'dbh'},$args{'schema'}, 'users', 'organization', "id = $values[$fields{'rv_responsewriter'}]") . "<br>\n";
                        $outputstring .= nbspaces(10) . "Email address: ". get_value($args{'dbh'},$args{'schema'}, 'users', 'email', "id = $values[$fields{'rv_responsewriter'}]") . "<br>\n";
                        $outputstring .= nbspaces(10) . "Phone: (". get_value($args{'dbh'},$args{'schema'}, 'users', 'areacode', "id = $values[$fields{'rv_responsewriter'}]") . ") ". substr(get_value($args{'dbh'},$args{'schema'}, 'users', 'phonenumber', "id = $values[$fields{'rv_responsewriter'}]"),0,3) . "-" . substr(get_value($args{'dbh'},$args{'schema'}, 'users', 'phonenumber', "id = $values[$fields{'rv_responsewriter'}]"),3,4) . nbspaces(4) . get_value($args{'dbh'},$args{'schema'}, 'users', "NVL(extension,' ')", "id = $values[$fields{'rv_responsewriter'}]") . "<br>\n";
                    }
                }
                if ($items{'technicalreviewer'}[0] eq 'T' && defined($values[$fields{'com_commentnum'}])) {
                    my $trcsr = $args{dbh}->prepare("SELECT tr.document,tr.commentnum,tr.reviewer,TO_CHAR(tr.dateassigned,'DD-MON-YYYY HH24:MI:SS'),u.firstname,u.lastname FROM $schema.technical_reviewer tr, $schema.users u WHERE tr.reviewer = u.id AND tr.document=$values[$fields{'com_document'}] AND tr.commentnum=$values[$fields{'com_commentnum'}] ORDER BY u.username");
                    $status = $trcsr->execute;
                    my @trvalues;
                    
                    if ($items{'technicalreviewer'}[4]{'details'} eq 'T') {
                        while (@trvalues = $trcsr->fetchrow_array) {
                            $outputstring .= "Assigned Technical Reviewer: $trvalues[4] $trvalues[5]<br>\n";
                            $outputstring .= nbspaces(10) . "Location: ". get_value($args{'dbh'},$args{'schema'}, 'users', 'location', "id = $trvalues[2]") . "<br>\n";
                            $outputstring .= nbspaces(10) . "Organization: ". get_value($args{'dbh'},$args{'schema'}, 'users', 'organization', "id = $trvalues[2]") . "<br>\n";
                            $outputstring .= nbspaces(10) . "Email address: ". get_value($args{'dbh'},$args{'schema'}, 'users', 'email', "id = $trvalues[2]") . "<br>\n";
                            $outputstring .= nbspaces(10) . "Phone: (". get_value($args{'dbh'},$args{'schema'}, 'users', 'areacode', "id = $trvalues[2]") . ") ". substr(get_value($args{'dbh'},$args{'schema'}, 'users', 'phonenumber', "id = $trvalues[2]"),0,3) . "-" . substr(get_value($args{'dbh'},$args{'schema'}, 'users', 'phonenumber', "id = $trvalues[2]"),3,4) . nbspaces(4) . get_value($args{'dbh'},$args{'schema'}, 'users', "NVL(extension,' ')", "id = $trvalues[2]") . "<br>\n";
                        }
                    } else {
                        my @row = $args{'dbh'}->selectrow_array("SELECT count(*) FROM $args{'schema'}.technical_reviewer WHERE document=$values[$fields{'com_document'}] AND commentnum=$values[$fields{'com_commentnum'}]");
                        if ($row[0] >= 1) {
                            $outputstring .= "Assigned Technical Reviewer" . (($row[0] != 1) ? "s" : "") . ": \n";
                            while (@trvalues = $trcsr->fetchrow_array) {
                                $outputstring .= "$trvalues[4] $trvalues[5], ";
                            }
                            chop($outputstring);
                            chop($outputstring);
                            $outputstring .= "<br>\n";
                        }
                    }
                    $trcsr->finish;
                }
                if ($items{'nepareviewer'}[0] eq 'T' && defined($values[$fields{'bin_nepareviewer'}])) {
                    $outputstring .= &FirstReviewName . " Reviewer: " . get_fullname($args{'dbh'},$args{'schema'},$values[$fields{'bin_nepareviewer'}]) . "<br>\n";
                    if ($items{'nepareviewer'}[4]{'details'} eq 'T') {
                        $outputstring .= nbspaces(10) . "Location: ". get_value($args{'dbh'},$args{'schema'}, 'users', 'location', "id = $values[$fields{'bin_nepareviewer'}]") . "<br>\n";
                        $outputstring .= nbspaces(10) . "Organization: ". get_value($args{'dbh'},$args{'schema'}, 'users', 'organization', "id = $values[$fields{'bin_nepareviewer'}]") . "<br>\n";
                        $outputstring .= nbspaces(10) . "Email address: ". get_value($args{'dbh'},$args{'schema'}, 'users', 'email', "id = $values[$fields{'bin_nepareviewer'}]") . "<br>\n";
                        $outputstring .= nbspaces(10) . "Phone: (". get_value($args{'dbh'},$args{'schema'}, 'users', 'areacode', "id = $values[$fields{'bin_nepareviewer'}]") . ") ". substr(get_value($args{'dbh'},$args{'schema'}, 'users', 'phonenumber', "id = $values[$fields{'bin_nepareviewer'}]"),0,3) . "-" . substr(get_value($args{'dbh'},$args{'schema'}, 'users', 'phonenumber', "id = $values[$fields{'bin_nepareviewer'}]"),3,4) . nbspaces(4) . get_value($args{'dbh'},$args{'schema'}, 'users', "NVL(extension,' ')", "id = $values[$fields{'bin_nepareviewer'}]") . "<br>\n";
                    }
                }
                if ($items{'commentor'}[0] eq 'T') {
                    if ($excludeTable eq 'document' || $values[$fields{'doc_namestatus'}] == 1) {
                        if (defined ($items{'commentor'}[4]{'details'}) && $items{'commentor'}[4]{'details'} eq 'T') {
                            $outputstring .= "Commentor: " . ((defined($values[$fields{'cmntr_title'}])) ? $values[$fields{'cmntr_title'}] . " " : "");
                            $outputstring .= ((defined($values[$fields{'cmntr_firstname'}])) ? $values[$fields{'cmntr_firstname'}] . " " : "");
                            $outputstring .= ((defined($values[$fields{'cmntr_middlename'}])) ? $values[$fields{'cmntr_middlename'}] . " " : "");
                            $outputstring .= ((defined($values[$fields{'cmntr_lastname'}])) ? $values[$fields{'cmntr_lastname'}] : "");
                            $outputstring .= ((defined($values[$fields{'cmntr_suffix'}])) ? " " . $values[$fields{'cmntr_suffix'}] : "");
                            $outputstring .= " (C" . lpadzero($values[$fields{'cmntr_id'}],4) . ")";
                            $outputstring .= "<br>\n";
                            if (defined($values[$fields{'cmntr_organization'}]) && $values[$fields{'cmntr_organization'}] gt ' ') {$outputstring .= nbspaces(10) . "Organization: $values[$fields{'cmntr_organization'}]<br>\n";}
                            if (defined($values[$fields{'cmntr_position'}]) && $values[$fields{'cmntr_position'}] gt ' ') {$outputstring .= nbspaces(10) . "Position: $values[$fields{'cmntr_position'}]<br>\n";}
                            if (defined($values[$fields{'cmntr_affiliation'}]) && $values[$fields{'cmntr_affiliation'}] gt ' ') {$outputstring .= nbspaces(10) . "Affiliation: " . get_value($args{'dbh'}, $args{'schema'},'commentor_affiliation', 'name', "id = $values[$fields{'cmntr_affiliation'}]") . "<br>\n";}
                            if (defined($values[$fields{'cmntr_address'}]) && $values[$fields{'cmntr_address'}] gt ' ') {$outputstring .= nbspaces(10) . "$values[$fields{'cmntr_address'}]<br>\n";}
                            $itemcount=0;
                            if (defined($values[$fields{'cmntr_city'}]) && $values[$fields{'cmntr_city'}] gt ' ') {$outputstring .= nbspaces(10) . "$values[$fields{'cmntr_city'}]\n";$itemcount++}
                            if (defined($values[$fields{'cmntr_state'}]) && $values[$fields{'cmntr_state'}] gt ' ') {$outputstring .= (($itemcount>=1) ? ", " : nbspaces(10)) . "$values[$fields{'cmntr_state'}]\n";$itemcount++}
                            if (defined($values[$fields{'cmntr_postalcode'}]) && $values[$fields{'cmntr_postalcode'}] gt ' ') {$outputstring .=  (($itemcount>=1) ? " " : nbspaces(10)) . "$values[$fields{'cmntr_postalcode'}]\n";$itemcount++}
                            if (defined($values[$fields{'cmntr_country'}]) && $values[$fields{'cmntr_country'}] gt ' ') {$outputstring .=  (($itemcount>=1) ? " " : nbspaces(10)) . "$values[$fields{'cmntr_country'}]\n";$itemcount++}
                            if ($itemcount >= 1) {$outputstring .= "<br>\n";}
                            my $phone = '';
                            $itemcount=0;
                            if (defined($values[$fields{'cmntr_areacode'}]) && $values[$fields{'cmntr_areacode'}] gt ' ') {$phone .=  "($values[$fields{'cmntr_areacode'}])";$itemcount++}
                            if (defined($values[$fields{'cmntr_phonenumber'}]) && $values[$fields{'cmntr_phonenumber'}] gt ' ') {$phone .=  (($itemcount>=1) ? " " : "") . substr($values[$fields{'cmntr_phonenumber'}],0,3) . "-" . substr($values[$fields{'cmntr_phonenumber'}],3,4);$itemcount++}
                            if (defined($values[$fields{'cmntr_phoneextension'}]) && $values[$fields{'cmntr_phoneextension'}] gt ' ') {$phone .=  (($itemcount>=1) ? " Ext. " : "") . "$values[$fields{'cmntr_phoneextension'}]";$itemcount++}
                            if ($phone gt ' ') {$outputstring .= nbspaces(10) . "Phone: $phone\n";}
                            $itemcount=0;
                            my $fax = '';
                            if (defined($values[$fields{'cmntr_faxareacode'}]) && $values[$fields{'cmntr_faxareacode'}] gt ' ') {$fax .=  "($values[$fields{'cmntr_faxareacode'}])";$itemcount++}
                            if (defined($values[$fields{'cmntr_faxnumber'}]) && $values[$fields{'cmntr_faxnumber'}] gt ' ') {$fax .=  (($itemcount>=1) ? " " : "") . substr($values[$fields{'cmntr_faxnumber'}],0,3) . "-" . substr($values[$fields{'cmntr_faxnumber'}],3,4);$itemcount++}
                            if (defined($values[$fields{'cmntr_faxextension'}]) && $values[$fields{'cmntr_faxextension'}] gt ' ') {$fax .=  (($itemcount>=1) ? " Ext. " : "") . "$values[$fields{'cmntr_faxextension'}]";$itemcount++}
                            if ($fax gt ' ') {$outputstring .= nbspaces(10) . "Fax: $fax\n";}
                            if ($phone gt ' ' || $fax gt ' ') {$outputstring .= "<br>\n";}
                            if (defined($values[$fields{'cmntr_email'}]) && $values[$fields{'cmntr_email'}] gt ' ') {$outputstring .= nbspaces(10) . "Email address: $values[$fields{'cmntr_email'}]<br>\n";}
                        } else {
                            $outputstring .= "Commentor: " . ((defined($values[$fields{'cmntr_firstname'}])) ? $values[$fields{'cmntr_firstname'}] : "") . " " . ((defined($values[$fields{'cmntr_lastname'}])) ? $values[$fields{'cmntr_lastname'}] : "") . " (C" . lpadzero($values[$fields{'cmntr_id'}],4) . ")<br>\n";
                        }
#                        
                    } else {
                        $outputstring .= "Commentor: " . get_value($args{'dbh'},$args{'schema'},'commentor_name_status', 'name', "id = $values[$fields{'doc_namestatus'}]") . "<br>\n";
                    }
                }
                if ($items{'commentorname'}[0] eq 'T') {
                    $outputstring .= "Commentor: " . ((defined($values[$fields{'cmntr_title'}])) ? $values[$fields{'cmntr_title'}] . " " : "");
                    $outputstring .= ((defined($values[$fields{'cmntr_firstname'}])) ? $values[$fields{'cmntr_firstname'}] . " " : "");
                    $outputstring .= ((defined($values[$fields{'cmntr_middlename'}])) ? $values[$fields{'cmntr_middlename'}] . " " : "");
                    $outputstring .= ((defined($values[$fields{'cmntr_lastname'}])) ? $values[$fields{'cmntr_lastname'}] : "");
                    $outputstring .= ((defined($values[$fields{'cmntr_suffix'}])) ? " " . $values[$fields{'cmntr_suffix'}] : "");
                    $outputstring .= " (C" . lpadzero($values[$fields{'cmntr_id'}],4) . ")";
                    $outputstring .= "<br>\n";
                }
                if ($items{'commentororg'}[0] eq 'T') {
                    if (defined($values[$fields{'cmntr_organization'}]) && $values[$fields{'cmntr_organization'}] gt ' ') {$outputstring .= nbspaces(10) . "Organization: $values[$fields{'cmntr_organization'}]<br>\n";}
                }
                if ($items{'commentorposition'}[0] eq 'T') {
                    if (defined($values[$fields{'cmntr_position'}]) && $values[$fields{'cmntr_position'}] gt ' ') {$outputstring .= nbspaces(10) . "Position: $values[$fields{'cmntr_position'}]<br>\n";}
                }
                if ($items{'commentoraff'}[0] eq 'T') {
                    if (defined($values[$fields{'cmntr_affiliation'}]) && $values[$fields{'cmntr_affiliation'}] gt ' ') {$outputstring .= nbspaces(10) . "Affiliation: " . get_value($args{'dbh'}, $args{'schema'},'commentor_affiliation', 'name', "id = $values[$fields{'cmntr_affiliation'}]") . "<br>\n";}
                }
                if ($items{'commentoraddress'}[0] eq 'T') {
                    if (defined($values[$fields{'cmntr_address'}]) && $values[$fields{'cmntr_address'}] gt ' ') {$outputstring .= nbspaces(10) . "$values[$fields{'cmntr_address'}]<br>\n";}
                    $itemcount=0;
                    if (defined($values[$fields{'cmntr_city'}]) && $values[$fields{'cmntr_city'}] gt ' ') {$outputstring .= nbspaces(10) . "$values[$fields{'cmntr_city'}]\n";$itemcount++}
                    if (defined($values[$fields{'cmntr_state'}]) && $values[$fields{'cmntr_state'}] gt ' ') {$outputstring .= (($itemcount>=1) ? ", " : nbspaces(10)) . "$values[$fields{'cmntr_state'}]\n";$itemcount++}
                    if (defined($values[$fields{'cmntr_postalcode'}]) && $values[$fields{'cmntr_postalcode'}] gt ' ') {$outputstring .=  (($itemcount>=1) ? " " : nbspaces(10)) . "$values[$fields{'cmntr_postalcode'}]\n";$itemcount++}
                    if (defined($values[$fields{'cmntr_country'}]) && $values[$fields{'cmntr_country'}] gt ' ') {$outputstring .=  (($itemcount>=1) ? " " : nbspaces(10)) . "$values[$fields{'cmntr_country'}]\n";$itemcount++}
                    if ($itemcount >= 1) {$outputstring .= "<br>\n";}
                }
                if ($items{'commentorphone'}[0] eq 'T') {
                    my $phone = '';
                    $itemcount=0;
                    if (defined($values[$fields{'cmntr_areacode'}]) && $values[$fields{'cmntr_areacode'}] gt ' ') {$phone .=  "($values[$fields{'cmntr_areacode'}])";$itemcount++}
                    if (defined($values[$fields{'cmntr_phonenumber'}]) && $values[$fields{'cmntr_phonenumber'}] gt ' ') {$phone .=  (($itemcount>=1) ? " " : "") . substr($values[$fields{'cmntr_phonenumber'}],0,3) . "-" . substr($values[$fields{'cmntr_phonenumber'}],3,4);$itemcount++}
                    if (defined($values[$fields{'cmntr_phoneextension'}]) && $values[$fields{'cmntr_phoneextension'}] gt ' ') {$phone .=  (($itemcount>=1) ? " Ext. " : "") . "$values[$fields{'cmntr_phoneextension'}]";$itemcount++}
                    if ($phone gt ' ') {$outputstring .= nbspaces(10) . "Phone: $phone\n";}
                    $itemcount=0;
                    my $fax = '';
                    if (defined($values[$fields{'cmntr_faxareacode'}]) && $values[$fields{'cmntr_faxareacode'}] gt ' ') {$fax .=  "($values[$fields{'cmntr_faxareacode'}])";$itemcount++}
                    if (defined($values[$fields{'cmntr_faxnumber'}]) && $values[$fields{'cmntr_faxnumber'}] gt ' ') {$fax .=  (($itemcount>=1) ? " " : "") . substr($values[$fields{'cmntr_faxnumber'}],0,3) . "-" . substr($values[$fields{'cmntr_faxnumber'}],3,4);$itemcount++}
                    if (defined($values[$fields{'cmntr_faxextension'}]) && $values[$fields{'cmntr_faxextension'}] gt ' ') {$fax .=  (($itemcount>=1) ? " Ext. " : "") . "$values[$fields{'cmntr_faxextension'}]";$itemcount++}
                    if ($fax gt ' ') {$outputstring .= nbspaces(10) . "Fax: $fax\n";}
                    if ($phone gt ' ' || $fax gt ' ') {$outputstring .= "<br>\n";}
                }
                if ($items{'commentoremail'}[0] eq 'T') {
                    if (defined($values[$fields{'cmntr_email'}]) && $values[$fields{'cmntr_email'}] gt ' ') {$outputstring .= nbspaces(10) . "Email address: $values[$fields{'cmntr_email'}]<br>\n";}
                }
                $itemcount=0;
                if ($items{'datereceived'}[0] eq 'T') {
                    $outputstring .= "Date Received: $values[$fields{'doc_datereceived'}]";
                    $itemcount++;
                }
                if ($items{'dateassigned'}[0] eq 'T' && defined($values[$fields{'com_dateassigned'}])) {
                    if ($itemcount > 0) {$outputstring .= " - ";}
                    $outputstring .= "Date Assigned: $values[$fields{'com_dateassigned'}]";
                    $itemcount++;
                }
                if ($items{'dateapproved'}[0] eq 'T' && defined($values[$fields{'com_dateapproved'}])) {
                    if ($itemcount > 0) {$outputstring .= " - ";}
                    $outputstring .= "Date Approved: $values[$fields{'com_dateapproved'}]";
                    $itemcount++;
                }
                if ($items{'dateupdated'}[0] eq 'T' && defined($values[$fields{'rv_dateupdated'}])) {
                    if ($itemcount > 0) {$outputstring .= " - ";}
                    $outputstring .= "Date Response Last Updated: $values[$fields{'rv_dateupdated'}]";
                    $itemcount++;
                }
                if ($itemcount > 0) {$outputstring .= "<br>\n";}
                if ($items{'addressee'}[0] eq 'T') {
                    $outputstring .= "Addressee: $values[$fields{'doc_addressee'}]<br>\n";
                }
                if ($items{'evaluationfactor'}[0] eq 'T') {
                    $outputstring .= "Evaluation Factor: " . ((defined($values[$fields{'doc_evaluationfactor'}])) ? get_value($args{dbh},$args{schema},'evaluation_factor','name',"id=$values[$fields{'doc_evaluationfactor'}]") : "None Assigned") . "<br>\n";
                }
                $itemcount=0;
                if ($items{'srcomments'}[0] eq 'T' && $values[$fields{'doc_hassrcomments'}] eq 'T') {
                    $outputstring .= "Has $CRDRelatedTextShort Comments";
                    $itemcount++;
                }
                if ($items{'lacomments'}[0] eq 'T' && $values[$fields{'doc_haslacomments'}] eq 'T') {
                    if ($itemcount > 0) {$outputstring .= " - ";}
                    $outputstring .= "Has LA Comments";
                    $itemcount++;
                }
                if ($items{'960comments'}[0] eq 'T' && $values[$fields{'doc_has960comments'}] eq 'T') {
                    if ($itemcount > 0) {$outputstring .= " - ";}
                    $outputstring .= "Has 960/963 Comments";
                    $itemcount++;
                }
                if ($items{'wasrescanned'}[0] eq 'T' && $values[$fields{'doc_wasrescanned'}] eq 'T') {
                    if ($itemcount > 0) {$outputstring .= " - ";}
                    $outputstring .= "Was Rescanned, Remarked, & Appended";
                    $itemcount++;
                }
                if ($items{'enclosures'}[0] eq 'T' && $values[$fields{'doc_hasenclosures'}] eq 'T') {
                    if ($itemcount > 0) {$outputstring .= " - ";}
                    $outputstring .= "Has Enclosures";
                    $itemcount++;
                }
                if ($items{'commitments'}[0] eq 'T' && defined($values[$fields{'com_hascommitments'}]) && $values[$fields{'com_hascommitments'}] eq 'T') {
                    if ($itemcount > 0) {$outputstring .= " - ";}
                    $outputstring .= "Has Commitments";
                    $itemcount++;
                }
                if ($items{'hasissues'}[0] eq 'T' && defined($values[$fields{'com_hasissues'}]) && $values[$fields{'com_hasissues'}] eq 'T') {
                    if ($itemcount > 0) {$outputstring .= " - ";}
                    $outputstring .= "Has Potential Issues";
                    $itemcount++;
                }
                if ($itemcount > 0) {$outputstring .= "<br>\n";}
                if ($items{'changeimpact'}[0] eq 'T' && defined($values[$fields{'com_changeimpact'}]) && $values[$fields{'com_changeimpact'}] > 1) {
                    $outputstring .= "Comment has '" . get_value($args{'dbh'},$args{'schema'},'document_change_impact', 'name', "id = $values[$fields{'com_changeimpact'}]") . "'";
                    if (defined($values[$fields{'com_changecontrolnum'}]) && $values[$fields{'com_changecontrolnum'}] gt ' ') {
                        $outputstring .= " - Change Control Number: " . $values[$fields{'com_changecontrolnum'}];
                    }
                    $outputstring .= "<br>\n";
                    $itemcount++;
                }
                if ($items{'page'}[0] eq 'T' && defined($values[$fields{'com_startpage'}])) {
                    $outputstring .= "Comment starts on page " . $values[$fields{'com_startpage'}] . "<br>\n";
                }
                if ($items{'commenttext'}[0] eq 'T' && defined($values[$fields{'com_text'}])) {
                    if ($args{'text_limit'} eq 'T') {
                        $outputstring .= "<br><u>Comment:</u><br>" . getDisplayString($values[$fields{'com_text'}], 115) . "<br>\n";
                    } else {
                        $values[$fields{'com_text'}] =~ s/\n/<br>/g;
                        $values[$fields{'com_text'}] =~ s/  /&nbsp;&nbsp;/g;
                        $outputstring .= "<br><table border=0 width=100% cellpadding=0 cellspacing=0><tr><td><font size=-1><u>Comment:</u><br>$values[$fields{'com_text'}]</font></td></tr></table>\n";
                    }
                }
                if ($items{'response'}[0] eq 'T' && defined($values[$fields{'rv_lastsubmittedtext'}])) {
                    $values[$fields{'rv_lastsubmittedtext'}] = lastSubmittedText(dbh => $dbh, schema => $schema, documentID => $values[$fields{'rv_document'}], commentID => $values[$fields{'rv_commentnum'}]);
                    if ($args{'text_limit'} eq 'T') {
                        $outputstring .= "<br><u>Response:</u><br>" . getDisplayString($values[$fields{'rv_lastsubmittedtext'}], 115) . "<br>\n";
                    } else {
                        $values[$fields{'rv_lastsubmittedtext'}] =~ s/\n/<br>/g;
                        $values[$fields{'rv_lastsubmittedtext'}] =~ s/  /&nbsp;&nbsp;/g;
                        $outputstring .= "<br><table border=0 width=100% cellpadding=0 cellspacing=0><tr><td><font size=-1><u>Response:</u><br>$values[$fields{'rv_lastsubmittedtext'}]</font></td></tr></table>\n";
                    }
                } elsif ($items{'response'}[0] eq 'T' && defined($values[$fields{'rv_originaltext'}])) {
                    if ($args{'text_limit'} eq 'T') {
                        $outputstring .= "<br><u>Response:</u><br>" . getDisplayString($values[$fields{'rv_originaltext'}], 115) . "<br>\n";
                    } else {
                        $values[$fields{'rv_originaltext'}] =~ s/\n/<br>/g;
                        $values[$fields{'rv_originaltext'}] =~ s/  /&nbsp;&nbsp;/g;
                        $outputstring .= "<br><table border=0 width=100% cellpadding=0 cellspacing=0><tr><td><font size=-1><u>Response:</u><br>$values[$fields{'rv_originaltext'}]</font></td></tr></table>\n";
                    }
                }
                if ($items{'techreviewtext'}[0] eq 'T' && defined($values[$fields{'com_commentnum'}])) {
                    my $trsqlquery = "SELECT tr.document,tr.commentnum,tr.reviewer,tr.version,tr.status,tr.text,TO_CHAR(tr.dateupdated,'DD-MON-YYYY HH24:MI:SS'),";
                    $trsqlquery .= "u.firstname,u.lastname FROM $schema.technical_review tr, $schema.users u ";
                    $trsqlquery .= "WHERE tr.reviewer = u.id AND tr.document=$values[$fields{'com_document'}] ";
                    $trsqlquery .= "AND tr.commentnum=$values[$fields{'com_commentnum'}] AND tr.status <> 4 ORDER BY u.username";
                    my $trcsr = $args{dbh}->prepare($trsqlquery);
                    $trcsr->execute;
                    my @trvalues;
                    while (@trvalues = $trcsr->fetchrow_array) {
                        $outputstring .= "<br><br>Technical Reviewer: $trvalues[7] $trvalues[8]";
                        $outputstring .= nbspaces(5) . "Status: " . get_value($args{dbh},$args{schema},'technical_review_status','name',"id = $trvalues[4]") . "<br>\n";
                        if ($trvalues[4] >= 3) {
                            if ($args{'text_limit'} eq 'T') {
                                $outputstring .= "<br><u>Review Text:</u><br>" . getDisplayString($trvalues[5], 115) . "<br>\n";
                            } else {
                                $trvalues[5] =~ s/\n/<br>/g;
                                $trvalues[5] =~ s/  /&nbsp;&nbsp;/g;
                                $outputstring .= "<br><table border=0 width=100% cellpadding=0 cellspacing=0><tr><td><font size=-1><u>Review Text:</u><br>$trvalues[5]</font></td></tr></table>\n";
                            }
                        }
                    }
                    $trcsr->finish;
                }
                if ($items{'docremarks'}[0] eq 'T') {
                    @row = $args{'dbh'}->selectrow_array("SELECT count(*) FROM $args{'schema'}.document_remark WHERE (document = $values[$fields{'doc_id'}])");
                    if ($row[0] >= 1) {
                        $sqlquery2 = "SELECT document,remarker,TO_CHAR(dateentered, 'DD-MON-YY HH24:MI:SS'), text FROM $args{'schema'}.document_remark WHERE (document = $values[$fields{'doc_id'}])";
                        $csr2 = $args{'dbh'}->prepare($sqlquery2);
                        $status = $csr2->execute;
                        $outputstring .= "<br><u>Document Remarks:</u>\n";
                        $outputstring .= "<table border=0 width=100% cellpadding=0 cellspacing=0>\n";
                        while (@values2 = $csr2->fetchrow_array) {
                            $outputstring .= "<tr><td width=130 valign=top><font size=-1>" . get_fullname($args{'dbh'}, $args{'schema'}, $values2[1]) . "</font></td>";
                            $outputstring .= "<td width=120 valign=top><font size=-1>$values2[2]</font></td>\n";
                            $outputstring .= "<td valign=top><font size=-1>" . (($args{'text_limit'} eq 'T') ? getDisplayString($values2[3], 73) : $values2[3]) . "</font></td></tr>\n";
                        }
                        $csr2->finish;
                        $outputstring .= "</table>\n";
                    }
                }
                if ($items{'comremarks'}[0] eq 'T') {
                    if (defined($values[$fields{'com_commentnum'}]) && $values[$fields{'com_commentnum'}] > 0) {
                        @row = $args{'dbh'}->selectrow_array("SELECT count(*) FROM $args{'schema'}.comments_remark WHERE (document = $values[$fields{'com_document'}]) AND (commentnum = $values[$fields{'com_commentnum'}])");
                        if ($row[0] >= 1) {
                            $sqlquery2 = "SELECT document,commentnum,remarker,TO_CHAR(dateentered, 'DD-MON-YY HH24:MI:SS'), text FROM $args{'schema'}.comments_remark WHERE (document = $values[$fields{'com_document'}]) AND (commentnum = $values[$fields{'com_commentnum'}])";
                            $csr2 = $args{'dbh'}->prepare($sqlquery2);
                            $status = $csr2->execute;
                            $outputstring .= "<br><u>Comment Remarks:</u>\n";
                            $outputstring .= "<table border=0 width=100% cellpadding=0 cellspacing=0>\n";
                            while (@values2 = $csr2->fetchrow_array) {
                                $outputstring .= "<tr><td width=130 valign=top><font size=-1>" . get_fullname($args{'dbh'}, $args{'schema'}, $values2[2]) . "</font></td>";
                                $outputstring .= "<td width=120 valign=top><font size=-1>$values2[3]</font></td>\n";
                                $outputstring .= "<td valign=top><font size=-1>" . (($args{'text_limit'} eq 'T') ? getDisplayString($values2[4], 80) : $values2[4]) . "</font></td></tr>\n";
                            }
                            $csr2->finish;
                            $outputstring .= "</table>\n";
                        }
                    }
                }
              }
            }
            $csr->finish;
            $outputstring .= "<br><hr><font size=-1>$count Record" . (($count != 1) ? "s" : "") . " Displayed.<br>\n";
        }

    };
    if ($@) {
        $message = errorMessage($dbh,$username,$userid,$schema,"generate an $args{'command'}.",$@);
        print doAlertBox( text => $message);
        
        my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime;
        $mon = substr("00" . ++$mon, -2);
        $mday = substr("00" . $mday, -2);
        $year += 1900;
        $hour = substr("00" . $hour, -2);
        $min = substr("00" . $min, -2);
        $sec = substr("00" . $sec, -2);
        print STDERR "\nad_hoc_reports.pl SQL Query: $mon/$mday/$year $hour:$min:$sec - $username/$userid/$schema - \n$sqlquery\n$documentid\n";
        print STDERR &dumpItems . "\n";
    }

    return ($outputstring);
}


#$dbh = &db_connect(server => 'ydoracle');
$dbh = &db_connect();
$dbh->{LongTruncOk} = 1;   # specify whether to fetch whole text or truncated fraction 
$dbh->{LongReadLen} = 10000000;

print $crdcgi->header('text/html');
print <<end;
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
      function lpadzero(instring, width) {
          var result = '';
          var index;
          for (index = 1; index <= (width - instring.length); index++) {
              result += '0';
          }
          return (result + instring);
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
          newwin.focus();
      }
      function submitFormCGIResults(script, command, id) {
          document.$form.command.value = command;
          document.$form.id.value = id;
          document.$form.action = '$path' + script + '.pl';
          document.$form.target = 'cgiresults';
          document.$form.submit();
      }
      function submitReportPage() {
          document.$form.target = '_popup';
          document.$form.submit();
      }

//#
//##################
//#
      function processFormSubmit() {
          var msg = "";
end
if ($command eq 'adhocsetup' && $items{'cdidcid'}[6]{$documentid} eq 'T') {
print <<end;
          if (isblank(document.$form.documentid.value) && !(isblank(document.$form.commentnum.value))) {
              msg += "Document ID can not be blank when Comment Number is entered\\n";
          }
          if (!(isblank(document.$form.documentid.value)) && !(isnumeric(document.$form.documentid.value)) || !(isblank(document.$form.commentnum.value)) && !(isnumeric(document.$form.commentnum.value))) {
              msg += "Document ID and Comment Number must be numeric\\n";
          }
end
}
if ($command eq 'adhocsetup' && $items{'docid'}[6]{$documentid} eq 'T') {
print <<end;
          if (isblank(document.$form.startingdocid.value) && !(isblank(document.$form.endingdocid.value)) || !(isblank(document.$form.startingdocid.value)) && isblank(document.$form.endingdocid.value) || !(isblank(document.$form.startingdocid.value)) && !(isnumeric(document.$form.startingdocid.value)) || !(isblank(document.$form.endingdocid.value)) && !(isnumeric(document.$form.endingdocid.value))) {
              msg += "Both Beinging and Ending Document ID must be entered and be numeric.\\n";
          }
end
}
if ($command eq 'adhocsetup' && $items{'docidrange'}[6]{$documentid} eq 'T') {
print <<end;
          if (!(isblank(document.$form.mindocid.value)) && !(isnumeric(document.$form.mindocid.value)) || !(isblank(document.$form.maxdocid.value)) && !(isnumeric(document.$form.maxdocid.value))) {
              msg += "Starting and Ending Document ID's must be numeric.\\n";
          }
end
}
if ($command eq 'adhocsetup' && $items{'datereceived'}[6]{$documentid} eq 'T') {
print <<end;
          if ((!(isblank(document.$form.date_received_start_day.value)) || !(isblank(document.$form.date_received_start_month.value)) || !(isblank(document.$form.date_received_start_year.value)) || !(isblank(document.$form.date_received_end_day.value)) || !(isblank(document.$form.date_received_end_month.value)) || !(isblank(document.$form.date_received_end_year.value)))) {
              if (((isblank(document.$form.date_received_start_day.value)) || (isblank(document.$form.date_received_start_month.value)) || (isblank(document.$form.date_received_start_year.value)) || (isblank(document.$form.date_received_end_day.value)) || (isblank(document.$form.date_received_end_month.value)) || (isblank(document.$form.date_received_end_year.value)))) {
                  msg += "All date parts must be selected for Date Document Received\\n";
              } else {
                  if (document.$form.date_received_start_year.value + '-' + lpadzero(document.$form.date_received_start_month.value,2) + '-' + lpadzero(document.$form.date_received_start_day.value,2) > 
                  document.$form.date_received_end_year.value + '-' + lpadzero(document.$form.date_received_end_month.value,2) + '-' + lpadzero(document.$form.date_received_end_day.value,2)) {
                      msg += "Start date can not be after the end date for Date Document Received\\n";
                  }
              }
          }
end
}
if ($command eq 'adhocsetup' && $items{'dateassigned'}[6]{$documentid} eq 'T') {
print <<end;
          if ((!(isblank(document.$form.date_assigned_start_day.value)) || !(isblank(document.$form.date_assigned_start_month.value)) || !(isblank(document.$form.date_assigned_start_year.value)) || !(isblank(document.$form.date_assigned_end_day.value)) || !(isblank(document.$form.date_assigned_end_month.value)) || !(isblank(document.$form.date_assigned_end_year.value)))) {
              if (((isblank(document.$form.date_assigned_start_day.value)) || (isblank(document.$form.date_assigned_start_month.value)) || (isblank(document.$form.date_assigned_start_year.value)) || (isblank(document.$form.date_assigned_end_day.value)) || (isblank(document.$form.date_assigned_end_month.value)) || (isblank(document.$form.date_assigned_end_year.value)))) {
                  msg += "All date parts must be selected for Date Document Assigned\\n";
              } else {
                  if (document.$form.date_assigned_start_year.value + '-' + lpadzero(document.$form.date_assigned_start_month.value,2) + '-' + lpadzero(document.$form.date_assigned_start_day.value,2) > 
                  document.$form.date_assigned_end_year.value + '-' + lpadzero(document.$form.date_assigned_end_month.value,2) + '-' + lpadzero(document.$form.date_assigned_end_day.value,2)) {
                      msg += "Start date can not be after the end date for Date Document Assigned\\n";
                  }
              }
          }
end
}
if ($command eq 'adhocsetup' && $items{'dateapproved'}[6]{$documentid} eq 'T') {
print <<end;
          if ((!(isblank(document.$form.date_approved_start_day.value)) || !(isblank(document.$form.date_approved_start_month.value)) || !(isblank(document.$form.date_approved_start_year.value)) || !(isblank(document.$form.date_approved_end_day.value)) || !(isblank(document.$form.date_approved_end_month.value)) || !(isblank(document.$form.date_approved_end_year.value)))) {
              if (((isblank(document.$form.date_approved_start_day.value)) || (isblank(document.$form.date_approved_start_month.value)) || (isblank(document.$form.date_approved_start_year.value)) || (isblank(document.$form.date_approved_end_day.value)) || (isblank(document.$form.date_approved_end_month.value)) || (isblank(document.$form.date_approved_end_year.value)))) {
                  msg += "All date parts must be selected for Date Document Approved\\n";
              } else {
                  if (document.$form.date_approved_start_year.value + '-' + lpadzero(document.$form.date_approved_start_month.value,2) + '-' + lpadzero(document.$form.date_approved_start_day.value,2) > 
                  document.$form.date_approved_end_year.value + '-' + lpadzero(document.$form.date_approved_end_month.value,2) + '-' + lpadzero(document.$form.date_approved_end_day.value,2)) {
                      msg += "Start date can not be after the end date for Date Document Approved\\n";
                  }
              }
          }
end
}
if ($command eq 'adhocsetup' && $items{'dateupdated'}[6]{$documentid} eq 'T') {
print <<end;
          if ((!(isblank(document.$form.date_updated_start_day.value)) || !(isblank(document.$form.date_updated_start_month.value)) || !(isblank(document.$form.date_updated_start_year.value)) || !(isblank(document.$form.date_updated_end_day.value)) || !(isblank(document.$form.date_updated_end_month.value)) || !(isblank(document.$form.date_updated_end_year.value)))) {
              if (((isblank(document.$form.date_updated_start_day.value)) || (isblank(document.$form.date_updated_start_month.value)) || (isblank(document.$form.date_updated_start_year.value)) || (isblank(document.$form.date_updated_end_day.value)) || (isblank(document.$form.date_updated_end_month.value)) || (isblank(document.$form.date_updated_end_year.value)))) {
                  msg += "All date parts must be selected for Date Response Last Updated\\n";
              } else {
                  if (document.$form.date_updated_start_year.value + '-' + lpadzero(document.$form.date_updated_start_month.value,2) + '-' + lpadzero(document.$form.date_updated_start_day.value,2) > 
                  document.$form.date_updated_end_year.value + '-' + lpadzero(document.$form.date_updated_end_month.value,2) + '-' + lpadzero(document.$form.date_updated_end_day.value,2)) {
                      msg += "Start date can not be after the end date for Date Response Last Updated\\n";
                  }
              }
          }
end
}
print <<end;
          if (msg != "") {
              alert (msg);
          } else {
end
if ($command eq 'adhocsetup' && $items{'bincoordinator'}[6]{$documentid} eq 'T') {
print <<end;
              for (index=0; index < document.$form.bincoordinator.length-1;index++) {
                  document.$form.bincoordinator.options[index].selected = true;
              }
end
}
if ($command eq 'adhocsetup' && $items{'responsewriter'}[6]{$documentid} eq 'T') {
print <<end;
              for (index=0; index < document.$form.responsewriter.length-1;index++) {
                  document.$form.responsewriter.options[index].selected = true;
              }
end
}
if ($command eq 'adhocsetup' && $items{'technicalreviewer'}[6]{$documentid} eq 'T') {
print <<end;
              for (index=0; index < document.$form.technicalreviewer.length-1;index++) {
                  document.$form.technicalreviewer.options[index].selected = true;
              }
end
}
if ($command eq 'adhocsetup' && $items{'nepareviewer'}[6]{$documentid} eq 'T') {
print <<end;
              for (index=0; index < document.$form.nepareviewer.length-1;index++) {
                  document.$form.nepareviewer.options[index].selected = true;
              }
end
}
if ($command eq 'adhocsetup' && $items{'responsestatus'}[6]{$documentid} eq 'T') {
print <<end;
              for (index=0; index < document.$form.responsestatus.length-1;index++) {
                  document.$form.responsestatus.options[index].selected = true;
              }
end
}
print <<end;
              submitFormCGIResults('$form', 'adhoctest', 'none');
          }
      }
      
//-->
</script>
end
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
if ($command eq 'adhocsetup') {
    if ($documentid eq 'comment') {
        print &writeTitleBar(userName => $username, userID => $userid, schema => $schema, title => "Customizable Comments Report");
    } elsif ($documentid eq 'document') {
        print &writeTitleBar(userName => $username, userID => $userid, schema => $schema, title => "Customizable Comment Documents Report");
    } elsif ($documentid eq 'commentor') {
        print &writeTitleBar(userName => $username, userID => $userid, schema => $schema, title => "Customizable Commentors Report");
    } else {
        print &writeTitleBar(userName => $username, userID => $userid, schema => $schema, title => "Customizable Report");
    }
    print AdHocSelectionPage(userName => $username, userID => $userid, schema => $schema, dbh => $dbh, type => $documentid, 'items' => \%items);
    print "<br><table border=0 width=750>\n";
#    print "</table>\n";
} elsif ($command eq 'adhoctest' || $command eq 'adhocreport') {

#
##################
#

    # item - cdidcid 
    if (defined($crdcgi->param('doc_selected'))) {
        $items{'cdidcid'}[0] = $crdcgi->param('doc_selected');
    }
    if ($crdcgi->param('sortorder') eq 'doc_sort') {
        $items{'cdidcid'}[1] = 'T';
    }
    if (defined($crdcgi->param('documentid'))) {
        $items{'cdidcid'}[4]{'document'} = $crdcgi->param('documentid');
    }
    if (defined($crdcgi->param('commentnum'))) {
        $items{'cdidcid'}[4]{'commentnum'} = $crdcgi->param('commentnum');
    }
    if (defined($crdcgi->param('use_all_docs'))) {
        $items{'cdidcid'}[4]{'use_all_docs'} = $crdcgi->param('use_all_docs');
    }
    if ($items{'cdidcid'}[4]{'document'} gt '' || $items{'cdidcid'}[4]{'commentnum'} gt '') {
        $items{'cdidcid'}[5] = 'T';
    }

    # item - docid 
    if (defined($crdcgi->param('use_only_docs'))) {
        if ($crdcgi->param('use_only_docs') eq 'T') {
            $items{'docid'}[0] = 'T';
            if ($crdcgi->param('sortorder') eq 'doc_sort') {
                $items{'docid'}[1] = 'T';
            }
            if (defined($crdcgi->param('documentid'))) {
                $items{'docid'}[4]{'document'} = $crdcgi->param('documentid');
            }
            $items{'docid'}[4]{'startid'} = ((defined($crdcgi->param('startingdocid'))) ? $crdcgi->param('startingdocid') : 0);
            $items{'docid'}[4]{'endid'} = ((defined($crdcgi->param('endingdocid'))) ? $crdcgi->param('endingdocid') : 0);
            if ($items{'docid'}[4]{'document'} gt '') {
                $items{'docid'}[5] = 'T';
            }
            if ($items{'docid'}[4]{'startid'} gt "0"  || $items{'docid'}[4]{'endid'} gt "0") {
                $items{'docid'}[5] = 'T';
            }
            
            $items{'cdidcid'}[0] = 'F';
            $items{'cdidcid'}[1] = 'F';
            $items{'cdidcid'}[5] = 'F';
            $items{'cdidcid'}[4]{'document'} = '';
            $items{'cdidcid'}[4]{'commentnum'} = '';
        }
    }

    # item - docidrange 
    #if (defined($crdcgi->param('docidrange_selected'))) {
    #    $items{'docidrange'}[0] = $crdcgi->param('docidrange_selected');
    #}
    #if ($crdcgi->param('sortorder') eq 'docidrange_sort') {
    #    $items{'docidrange'}[1] = 'T';
    #}
    if (defined($crdcgi->param('mindocid'))) {
        $items{'docidrange'}[4]{'startid'} = $crdcgi->param('mindocid');
    }
    if (defined($crdcgi->param('maxdocid'))) {
        $items{'docidrange'}[4]{'endid'} = $crdcgi->param('maxdocid');
    }
    if ($items{'docidrange'}[4]{'startid'} gt "0" || $items{'docidrange'}[4]{'endid'} gt "0") {
        $items{'docidrange'}[5] = 'T';
    }

    # item - doctype 
    if (defined($crdcgi->param('doctype_selected'))) {
        $items{'doctype'}[0] = $crdcgi->param('doctype_selected');
    }
    if ($crdcgi->param('sortorder') eq 'doctype_sort') {
        $items{'doctype'}[1] = 'T';
    }
    if (defined($crdcgi->param('doctype'))) {
        $items{'doctype'}[4]{'selection'} = $crdcgi->param('doctype');
    }
    if ($items{'doctype'}[4]{'selection'} gt "0") {
        $items{'doctype'}[5] = 'T';
    }
    
    # item - binid
    if (defined($crdcgi->param('bin_selected'))) {
        $items{'binid'}[0] = $crdcgi->param('bin_selected');
    }
    if ($crdcgi->param('sortorder') eq 'bin_sort') {
        $items{'binid'}[1] = 'T';
    }
    if (defined($crdcgi->param('binid'))) {
        $items{'binid'}[4]{'binid'} = $crdcgi->param('binid');
    }
    if (defined($crdcgi->param('usesubbins'))) {
        $items{'binid'}[4]{'subBins'} = $crdcgi->param('usesubbins');
    }
    if ($items{'binid'}[4]{'binid'} gt '0') {
        $items{'binid'}[5] = 'T';
    }
    
    # item - bincoordinator
    if (defined($crdcgi->param('bincoordinator_selected'))) {
        $items{'bincoordinator'}[0] = $crdcgi->param('bincoordinator_selected');
    }
    #if ($crdcgi->param('sortorder') eq 'bincoordinator_sort') {
    #    $items{'bincoordinator'}[1] = 'T';
    #}
    if (defined($crdcgi->param('bincoordinator'))) {
        $items{'bincoordinator'}[4]{'userlist'} = [ $crdcgi->param('bincoordinator') ];
    }
    if (defined($crdcgi->param('bincoordinator_detail'))) {
        $items{'bincoordinator'}[4]{'details'} = $crdcgi->param('bincoordinator_detail');
    }
    if (defined( $items{'bincoordinator'}[4]{'userlist'}[0] ) && $items{'bincoordinator'}[4]{'userlist'}[0] gt "0") {
        $items{'bincoordinator'}[5] = 'T';
    }
    
    # item - responsewriter
    if (defined($crdcgi->param('responsewriter_selected'))) {
        $items{'responsewriter'}[0] = $crdcgi->param('responsewriter_selected');
    }
    #if ($crdcgi->param('sortorder') eq 'responsewriter_sort') {
    #    $items{'responsewriter'}[1] = 'T';
    #}
    if (defined($crdcgi->param('responsewriter'))) {
        $items{'responsewriter'}[4]{'userlist'} = [ $crdcgi->param('responsewriter') ];
    }
    if (defined($crdcgi->param('responsewriter_detail'))) {
        $items{'responsewriter'}[4]{'details'} = $crdcgi->param('responsewriter_detail');
    }
    if (defined( $items{'responsewriter'}[4]{'userlist'}[0] ) && $items{'responsewriter'}[4]{'userlist'}[0] gt "0") {
        $items{'responsewriter'}[5] = 'T';
    }
    
    # item - technicalreviewer
    if (defined($crdcgi->param('technicalreviewer_selected'))) {
        $items{'technicalreviewer'}[0] = $crdcgi->param('technicalreviewer_selected');
    }
    #if ($crdcgi->param('sortorder') eq 'technicalreviewer_sort') {
    #    $items{'technicalreviewer'}[1] = 'T';
    #}
    if (defined($crdcgi->param('technicalreviewer'))) {
        $items{'technicalreviewer'}[4]{'userlist'} = [ $crdcgi->param('technicalreviewer') ];
    }
    if (defined($crdcgi->param('technicalreviewer_detail'))) {
        $items{'technicalreviewer'}[4]{'details'} = $crdcgi->param('technicalreviewer_detail');
    }
    if (defined( $items{'technicalreviewer'}[4]{'userlist'}[0] ) && $items{'technicalreviewer'}[4]{'userlist'}[0] gt "0") {
        $items{'technicalreviewer'}[5] = 'T';
    }
    
    # item - nepareviewer
    if (defined($crdcgi->param('nepareviewer_selected'))) {
        $items{'nepareviewer'}[0] = $crdcgi->param('nepareviewer_selected');
    }
    #if ($crdcgi->param('sortorder') eq 'nepareviewer_sort') {
    #    $items{'nepareviewer'}[1] = 'T';
    #}
    if (defined($crdcgi->param('nepareviewer'))) {
        $items{'nepareviewer'}[4]{'userlist'} = [ $crdcgi->param('nepareviewer') ];
    }
    if (defined($crdcgi->param('nepareviewer_detail'))) {
        $items{'nepareviewer'}[4]{'details'} = $crdcgi->param('nepareviewer_detail');
    }
    if (defined( $items{'nepareviewer'}[4]{'userlist'}[0] ) && $items{'nepareviewer'}[4]{'userlist'}[0] gt "0"  && $documentid ne "commentor" && $documentid ne "document") {
        $items{'nepareviewer'}[5] = 'T';
    }

    # item - responsestatus 
    if (defined($crdcgi->param('responsestatus_selected'))) {
        $items{'responsestatus'}[0] = $crdcgi->param('responsestatus_selected');
    }
    if (defined($crdcgi->param('responsestatus'))) {
        $items{'responsestatus'}[4]{'list'} = [ $crdcgi->param('responsestatus') ];
    }
    if (defined( $items{'responsestatus'}[4]{'list'}[0] ) && $items{'responsestatus'}[4]{'list'}[0] gt "0") {
        $items{'responsestatus'}[5] = 'T';
    }
    
    # item - commentor
    if (defined($crdcgi->param('commentor_selected'))) {
        $items{'commentor'}[0] = $crdcgi->param('commentor_selected');
    }
    if ($crdcgi->param('sortorder') eq 'commentor_sort') {
        $items{'commentor'}[1] = 'T';
    }
    if (defined($crdcgi->param('commentorid')) && $crdcgi->param('commentorid') ne '0') {
        $items{'commentor'}[4]{'commentor'} = $crdcgi->param('commentorid');
    }
    if (defined($crdcgi->param('cityid')) && $crdcgi->param('cityid') ne '0') {
        $items{'commentor'}[4]{'city'} = $crdcgi->param('cityid');
    }
    if (defined($crdcgi->param('stateid')) && $crdcgi->param('stateid') ne '0') {
        $items{'commentor'}[4]{'state'} = $crdcgi->param('stateid');
    }
    if (defined($crdcgi->param('organization')) && $crdcgi->param('organization') ne '0') {
        $items{'commentor'}[4]{'organization'} = $crdcgi->param('organization');
    }
    if (defined($crdcgi->param('affiliationid')) && $crdcgi->param('affiliationid') ne '0') {
        $items{'commentor'}[4]{'affiliation'} = $crdcgi->param('affiliationid');
    }
    if (defined($crdcgi->param('postalcode')) && $crdcgi->param('postalcode') ne '0') {
        #my @postalcodes = $crdcgi->param('postalcode');
        #$items{'commentor'}[4]{'postalcode'} = [ @postalcodes ];
        $items{'commentor'}[4]{'postalcode'} = $crdcgi->param('postalcode');
    }
    if (defined($crdcgi->param('areacode')) && $crdcgi->param('areacode') ne '0') {
        $items{'commentor'}[4]{'areacode'} = $crdcgi->param('areacode');
    }
    if (defined($crdcgi->param('faxareacode')) && $crdcgi->param('faxareacode') ne '0') {
        $items{'commentor'}[4]{'faxareacode'} = $crdcgi->param('faxareacode');
    }
    if (defined($crdcgi->param('commentordetail'))) {
        $items{'commentor'}[4]{'details'} = $crdcgi->param('commentordetail');
    }
    if ($items{'commentor'}[4]{'commentor'} gt '' || $items{'commentor'}[4]{'city'} gt '' || $items{'commentor'}[4]{'state'} gt '' || $items{'commentor'}[4]{'organization'} gt '' || $items{'commentor'}[4]{'affiliation'} gt '' || $items{'commentor'}[4]{'postalcode'} gt '' || $items{'commentor'}[4]{'areacode'} gt '' || $items{'commentor'}[4]{'faxareacode'} gt '') {
        $items{'commentor'}[5] = 'T';
    }
    
    # item - commentorname
    if (defined($crdcgi->param('commentorname_selected'))) {
        $items{'commentorname'}[0] = $crdcgi->param('commentorname_selected');
        $items{'commentor'}[5] = 'F';
    }
    if ($crdcgi->param('sortorder') eq 'commentorname_sort') {
        $items{'commentorname'}[1] = 'T';
    }
    if (defined($crdcgi->param('commentorid')) && $crdcgi->param('commentorid') ne '0') {
        $items{'commentorname'}[4]{'commentor'} = $crdcgi->param('commentorid');
    }
    if ($items{'commentorname'}[4]{'commentor'} gt '') {
        $items{'commentorname'}[5] = 'T';
    }
    
    # item - commentoraddress
    if (defined($crdcgi->param('commentoraddress_selected'))) {
        $items{'commentoraddress'}[0] = $crdcgi->param('commentoraddress_selected');
    }
    if ($crdcgi->param('sortorder') eq 'commentoraddress_sort') {
        $items{'commentoraddress'}[1] = 'T';
    }
    if (defined($crdcgi->param('cityid')) && $crdcgi->param('cityid') ne '0') {
        $items{'commentoraddress'}[4]{'city'} = $crdcgi->param('cityid');
    }
    if (defined($crdcgi->param('stateid')) && $crdcgi->param('stateid') ne '0') {
        $items{'commentoraddress'}[4]{'state'} = $crdcgi->param('stateid');
    }
    if (defined($crdcgi->param('postalcode')) && $crdcgi->param('postalcode') ne '0') {
        #my @postalcodes = $crdcgi->param('postalcode');
        #$items{'commentoraddress'}[4]{'postalcode'} = [ @postalcodes ];
        $items{'commentoraddress'}[4]{'postalcode'} = $crdcgi->param('postalcode');
    }
    if ($items{'commentoraddress'}[4]{'city'} gt '' || $items{'commentoraddress'}[4]{'state'} gt '' || $items{'commentoraddress'}[4]{'postalcode'} gt '') {
        $items{'commentoraddress'}[5] = 'T';
    }
    
    # item - commentororg
    if (defined($crdcgi->param('commentororg_selected'))) {
        $items{'commentororg'}[0] = $crdcgi->param('commentororg_selected');
    }
    if ($crdcgi->param('sortorder') eq 'commentororg_sort') {
        $items{'commentororg'}[1] = 'T';
    }
    if (defined($crdcgi->param('organization')) && $crdcgi->param('organization') ne '0') {
        $items{'commentororg'}[4]{'organization'} = $crdcgi->param('organization');
    }
    if ($items{'commentororg'}[4]{'organization'} gt '') {
        $items{'commentororg'}[5] = 'T';
    }
    
    # item - commentoraff
    if (defined($crdcgi->param('commentoraff_selected'))) {
        $items{'commentoraff'}[0] = $crdcgi->param('commentoraff_selected');
    }
    if ($crdcgi->param('sortorder') eq 'commentoraff_sort') {
        $items{'commentoraff'}[1] = 'T';
    }
    if (defined($crdcgi->param('affiliationid')) && $crdcgi->param('affiliationid') ne '0') {
        $items{'commentoraff'}[4]{'affiliation'} = $crdcgi->param('affiliationid');
    }
    if ($items{'commentoraff'}[4]{'affiliation'} gt '') {
        $items{'commentoraff'}[5] = 'T';
    }
    
    # item - commentorphone
    if (defined($crdcgi->param('commentorphone_selected'))) {
        $items{'commentorphone'}[0] = $crdcgi->param('commentorphone_selected');
    }
    if ($crdcgi->param('sortorder') eq 'commentorphone_sort') {
        $items{'commentorphone'}[1] = 'T';
    }
    if (defined($crdcgi->param('areacode')) && $crdcgi->param('areacode') ne '0') {
        $items{'commentorphone'}[4]{'areacode'} = $crdcgi->param('areacode');
    }
    if (defined($crdcgi->param('faxareacode')) && $crdcgi->param('faxareacode') ne '0') {
        $items{'commentorphone'}[4]{'faxareacode'} = $crdcgi->param('faxareacode');
    }
    if ($items{'commentorphone'}[4]{'areacode'} gt '' || $items{'commentorphone'}[4]{'faxareacode'} gt '') {
        $items{'commentorphone'}[5] = 'T';
    }
    
    # item - commentoremail
    if (defined($crdcgi->param('commentoremail_selected'))) {
        $items{'commentoremail'}[0] = $crdcgi->param('commentoremail_selected');
    }
    
    # item - commentorposition
    if (defined($crdcgi->param('commentorposition_selected'))) {
        $items{'commentorposition'}[0] = $crdcgi->param('commentorposition_selected');
    }
    
    # item - datereceived
    if (defined($crdcgi->param('date_received_selected'))) {
        $items{'datereceived'}[0] = $crdcgi->param('date_received_selected');
    }
    if ($crdcgi->param('sortorder') eq 'date_received_sort') {
        $items{'datereceived'}[1] = 'T';
    }
    if ($command eq 'adhoctest') {
        if (defined($crdcgi->param('date_received_start_month')) && defined($crdcgi->param('date_received_start_day')) && defined($crdcgi->param('date_received_start_year'))) {
            $items{'datereceived'}[4]{'startdate'} = $crdcgi->param('date_received_start_year') . '-' . lpadzero($crdcgi->param('date_received_start_month'),2) . '-' . lpadzero($crdcgi->param('date_received_start_day'),2);
        }
        if (defined($crdcgi->param('date_received_end_month')) && defined($crdcgi->param('date_received_end_day')) && defined($crdcgi->param('date_received_end_year'))) {
            $items{'datereceived'}[4]{'enddate'} = $crdcgi->param('date_received_end_year') . '-' . lpadzero($crdcgi->param('date_received_end_month'),2) . '-' . lpadzero($crdcgi->param('date_received_end_day'),2);
        }
    } else {
        if (defined($crdcgi->param('date_received_start'))) {
            $items{'datereceived'}[4]{'startdate'} = $crdcgi->param('date_received_start')
        }
        if (defined($crdcgi->param('date_received_end'))) {
            $items{'datereceived'}[4]{'enddate'} = $crdcgi->param('date_received_end')
        }
    }
    if (($items{'datereceived'}[4]{'startdate'} gt '' && substr($items{'datereceived'}[4]{'startdate'},0,1) ne '-') || 
           ($items{'datereceived'}[4]{'enddate'} gt '' && substr($items{'datereceived'}[4]{'enddate'},0,1) ne '-')) {
        $items{'datereceived'}[5] = 'T';
    }
    
    # item - dateassigned
    if (defined($crdcgi->param('date_assigned_selected'))) {
        $items{'dateassigned'}[0] = $crdcgi->param('date_assigned_selected');
    }
    if ($crdcgi->param('sortorder') eq 'date_assigned_sort') {
        $items{'dateassigned'}[1] = 'T';
    }
    if ($command eq 'adhoctest') {
        if (defined($crdcgi->param('date_assigned_start_month')) && defined($crdcgi->param('date_assigned_start_day')) && defined($crdcgi->param('date_assigned_start_year'))) {
            $items{'dateassigned'}[4]{'startdate'} = $crdcgi->param('date_assigned_start_year') . '-' . lpadzero($crdcgi->param('date_assigned_start_month'),2) . '-' . lpadzero($crdcgi->param('date_assigned_start_day'),2);
        }
        if (defined($crdcgi->param('date_assigned_end_month')) && defined($crdcgi->param('date_assigned_end_day')) && defined($crdcgi->param('date_assigned_end_year'))) {
            $items{'dateassigned'}[4]{'enddate'} = $crdcgi->param('date_assigned_end_year') . '-' . lpadzero($crdcgi->param('date_assigned_end_month'),2) . '-' . lpadzero($crdcgi->param('date_assigned_end_day'),2);
        }
    } else {
        if (defined($crdcgi->param('date_assigned_start'))) {
            $items{'dateassigned'}[4]{'startdate'} = $crdcgi->param('date_assigned_start')
        }
        if (defined($crdcgi->param('date_assigned_end'))) {
            $items{'dateassigned'}[4]{'enddate'} = $crdcgi->param('date_assigned_end')
        }
    }
    if (($items{'dateassigned'}[4]{'startdate'} gt '' && substr($items{'dateassigned'}[4]{'startdate'},0,1) ne '-') || 
           ($items{'dateassigned'}[4]{'enddate'} gt '' && substr($items{'dateassigned'}[4]{'enddate'},0,1) ne '-')) {
        $items{'dateassigned'}[5] = 'T';
    }
    
    # item - dateapproved
    if (defined($crdcgi->param('date_approved_selected'))) {
        $items{'dateapproved'}[0] = $crdcgi->param('date_approved_selected');
    }
    if ($crdcgi->param('sortorder') eq 'date_approved_sort') {
        $items{'dateapproved'}[1] = 'T';
    }
    if ($command eq 'adhoctest') {
        if (defined($crdcgi->param('date_approved_start_month')) && defined($crdcgi->param('date_approved_start_day')) && defined($crdcgi->param('date_approved_start_year'))) {
            $items{'dateapproved'}[4]{'startdate'} = $crdcgi->param('date_approved_start_year') . '-' . lpadzero($crdcgi->param('date_approved_start_month'),2) . '-' . lpadzero($crdcgi->param('date_approved_start_day'),2);
        }
        if (defined($crdcgi->param('date_approved_end_month')) && defined($crdcgi->param('date_approved_end_day')) && defined($crdcgi->param('date_approved_end_year'))) {
            $items{'dateapproved'}[4]{'enddate'} = $crdcgi->param('date_approved_end_year') . '-' . lpadzero($crdcgi->param('date_approved_end_month'),2) . '-' . lpadzero($crdcgi->param('date_approved_end_day'),2);
        }
    } else {
        if (defined($crdcgi->param('date_approved_start'))) {
            $items{'dateapproved'}[4]{'startdate'} = $crdcgi->param('date_approved_start')
        }
        if (defined($crdcgi->param('date_assigned_end'))) {
            $items{'dateapproved'}[4]{'enddate'} = $crdcgi->param('date_approved_end')
        }
    }
    if (($items{'dateapproved'}[4]{'startdate'} gt '' && substr($items{'dateapproved'}[4]{'startdate'},0,1) ne '-') || 
           ($items{'dateapproved'}[4]{'enddate'} gt '' && substr($items{'dateapproved'}[4]{'enddate'},0,1) ne '-')) {
        $items{'dateapproved'}[5] = 'T';
    }
    
    # item - dateupdated
    if (defined($crdcgi->param('date_updated_selected'))) {
        $items{'dateupdated'}[0] = $crdcgi->param('date_updated_selected');
    }
    if ($crdcgi->param('sortorder') eq 'date_updated_sort') {
        $items{'dateupdated'}[1] = 'T';
    }
    if ($command eq 'adhoctest') {
        if (defined($crdcgi->param('date_updated_start_month')) && defined($crdcgi->param('date_updated_start_day')) && defined($crdcgi->param('date_updated_start_year'))) {
            $items{'dateupdated'}[4]{'startdate'} = $crdcgi->param('date_updated_start_year') . '-' . lpadzero($crdcgi->param('date_updated_start_month'),2) . '-' . lpadzero($crdcgi->param('date_updated_start_day'),2);
        }
        if (defined($crdcgi->param('date_updated_end_month')) && defined($crdcgi->param('date_updated_end_day')) && defined($crdcgi->param('date_updated_end_year'))) {
            $items{'dateupdated'}[4]{'enddate'} = $crdcgi->param('date_updated_end_year') . '-' . lpadzero($crdcgi->param('date_updated_end_month'),2) . '-' . lpadzero($crdcgi->param('date_updated_end_day'),2);
        }
    } else {
        if (defined($crdcgi->param('date_updated_start'))) {
            $items{'dateupdated'}[4]{'startdate'} = $crdcgi->param('date_updated_start')
        }
        if (defined($crdcgi->param('date_updated_end'))) {
            $items{'dateupdated'}[4]{'enddate'} = $crdcgi->param('date_updated_end')
        }
    }
    if (($items{'dateupdated'}[4]{'startdate'} gt '' && substr($items{'dateupdated'}[4]{'startdate'},0,1) ne '-') || 
           ($items{'dateupdated'}[4]{'enddate'} gt '' && substr($items{'dateupdated'}[4]{'enddate'},0,1) ne '-')) {
        $items{'dateupdated'}[5] = 'T';
    }
    
    # item - addressee
    if (defined($crdcgi->param('addressee_selected'))) {
        $items{'addressee'}[0] = $crdcgi->param('addressee_selected');
    }
    if ($crdcgi->param('sortorder') eq 'addressee_sort') {
        $items{'addressee'}[1] = 'T';
    }
    if (defined($crdcgi->param('addressee'))) {
        $items{'addressee'}[4]{'addressee'} = $crdcgi->param('addressee');
    }
    if ($items{'addressee'}[4]{'addressee'} gt '0') {
        $items{'addressee'}[5] = 'T';
    }
    
    # item - evaluationfactor
    if (defined($crdcgi->param('evaluationfactor_selected'))) {
        $items{'evaluationfactor'}[0] = $crdcgi->param('evaluationfactor_selected');
    }
    if ($crdcgi->param('sortorder') eq 'evaluationfactor_sort') {
        $items{'evaluationfactor'}[1] = 'T';
    }
    if (defined($crdcgi->param('evaluationfactor'))) {
        $items{'evaluationfactor'}[4]{'id'} = $crdcgi->param('evaluationfactor');
    }
    if ($items{'evaluationfactor'}[4]{'id'} ne '0' && $items{'evaluationfactor'}[4]{'id'} != 0) {
        $items{'evaluationfactor'}[5] = 'T';
    }
    
    # item - srcomments
    if (defined($crdcgi->param('hassrcomments_selected'))) {
        $items{'srcomments'}[0] = $crdcgi->param('hassrcomments_selected');
    }
    if (defined($crdcgi->param('hassrcomments'))) {
        $items{'srcomments'}[4]{'selection'} = $crdcgi->param('hassrcomments');
    }
    if ($items{'srcomments'}[4]{'selection'} gt ' ' && $items{'srcomments'}[4]{'selection'} ne 'both') {
        $items{'srcomments'}[5] = 'T';
    }
    
    # item - lacomments
    if (defined($crdcgi->param('haslacomments_selected'))) {
        $items{'lacomments'}[0] = $crdcgi->param('haslacomments_selected');
    }
    if (defined($crdcgi->param('haslacomments'))) {
        $items{'lacomments'}[4]{'selection'} = $crdcgi->param('haslacomments');
    }
    if ($items{'lacomments'}[4]{'selection'} gt ' ' && $items{'lacomments'}[4]{'selection'} ne 'both') {
        $items{'lacomments'}[5] = 'T';
    }
    
    # item - 960comments
    if (defined($crdcgi->param('has960comments_selected'))) {
        $items{'960comments'}[0] = $crdcgi->param('has960comments_selected');
    }
    if (defined($crdcgi->param('has960comments'))) {
        $items{'960comments'}[4]{'selection'} = $crdcgi->param('has960comments');
    }
    if ($items{'960comments'}[4]{'selection'} gt ' ' && $items{'960comments'}[4]{'selection'} ne 'both') {
        $items{'960comments'}[5] = 'T';
    }
    
    # item - wasrescanned
    if (defined($crdcgi->param('wasrescanned_selected'))) {
        $items{'wasrescanned'}[0] = $crdcgi->param('wasrescanned_selected');
    }
    if (defined($crdcgi->param('wasrescanned'))) {
        $items{'wasrescanned'}[4]{'selection'} = $crdcgi->param('wasrescanned');
    }
    if ($items{'wasrescanned'}[4]{'selection'} gt ' ' && $items{'wasrescanned'}[4]{'selection'} ne 'both') {
        $items{'wasrescanned'}[5] = 'T';
    }
    
    # item - enclosures
    if (defined($crdcgi->param('hasenclosures_selected'))) {
        $items{'enclosures'}[0] = $crdcgi->param('hasenclosures_selected');
    }
    if (defined($crdcgi->param('hasenclosures'))) {
        $items{'enclosures'}[4]{'selection'} = $crdcgi->param('hasenclosures');
    }
    if ($items{'enclosures'}[4]{'selection'} gt ' ' && $items{'enclosures'}[4]{'selection'} ne 'both') {
        $items{'enclosures'}[5] = 'T';
    }
    
    # item - changeimpact
    if (defined($crdcgi->param('changeimpact_selected'))) {
        $items{'changeimpact'}[0] = $crdcgi->param('changeimpact_selected');
    }
    if (defined($crdcgi->param('changeimpact'))) {
        $items{'changeimpact'}[4]{'selection'} = $crdcgi->param('changeimpact');
    }
    if ($items{'changeimpact'}[4]{'selection'} gt '0') {
        $items{'changeimpact'}[5] = 'T';
    }
    
    # item - commitments
    if (defined($crdcgi->param('commitments_selected'))) {
        $items{'commitments'}[0] = $crdcgi->param('commitments_selected');
    }
    if (defined($crdcgi->param('commitments'))) {
        $items{'commitments'}[4]{'selection'} = $crdcgi->param('commitments');
    }
    if ($items{'commitments'}[4]{'selection'} gt ' ' && $items{'commitments'}[4]{'selection'} ne 'both') {
        $items{'commitments'}[5] = 'T';
    }
    
    # item - hasissues
    if (defined($crdcgi->param('hasissues_selected'))) {
        $items{'hasissues'}[0] = $crdcgi->param('hasissues_selected');
    }
    if (defined($crdcgi->param('hasissues'))) {
        $items{'hasissues'}[4]{'selection'} = $crdcgi->param('hasissues');
    }
    if ($items{'hasissues'}[4]{'selection'} gt ' ' && $items{'hasissues'}[4]{'selection'} ne 'both') {
        $items{'hasissues'}[5] = 'T';
    }
    
    # item - comment text
    if (defined($crdcgi->param('comments_selected'))) {
        $items{'commenttext'}[0] = $crdcgi->param('comments_selected');
    }
    if (defined($crdcgi->param('commentsearchtext'))) {
        $items{'commenttext'}[4]{'searchtext'} = $crdcgi->param('commentsearchtext');
    }
    if (defined($items{'commenttext'}[4]{'searchtext'}) && $items{'commenttext'}[4]{'searchtext'} gt '     ') {
        $items{'commenttext'}[5] = 'T';
    }
     
    # item - response
    if (defined($crdcgi->param('response_selected'))) {
        $items{'response'}[0] = $crdcgi->param('response_selected');
    }
    if (defined($crdcgi->param('responsesearchtext'))) {
        $items{'response'}[4]{'searchtext'} = $crdcgi->param('responsesearchtext');
    }
    if (defined($items{'response'}[4]{'searchtext'}) && $items{'response'}[4]{'searchtext'} gt '     ') {
        $items{'response'}[5] = 'T';
    }
     
    # item - techreviewtext
    if (defined($crdcgi->param('techreviewtext_selected'))) {
        $items{'techreviewtext'}[0] = $crdcgi->param('techreviewtext_selected');
    }
     
    # item - docremarks
    if (defined($crdcgi->param('doc_remarks_selected'))) {
        $items{'docremarks'}[0] = $crdcgi->param('doc_remarks_selected');
    }
    if (defined($crdcgi->param('docremarkssearchtext'))) {
        $items{'docremarks'}[4]{'searchtext'} = $crdcgi->param('docremarkssearchtext');
    }
    if (defined($items{'docremarks'}[4]{'searchtext'}) && $items{'docremarks'}[4]{'searchtext'} gt '     ') {
        $items{'docremarks'}[5] = 'T';
    }
     
    # item - comremarks
    if (defined($crdcgi->param('com_remarks_selected'))) {
        $items{'comremarks'}[0] = $crdcgi->param('com_remarks_selected');
    }
    if (defined($crdcgi->param('comremarkssearchtext'))) {
        $items{'comremarks'}[4]{'searchtext'} = $crdcgi->param('comremarkssearchtext');
    }
    if (defined($items{'comremarks'}[4]{'searchtext'}) && $items{'comremarks'}[4]{'searchtext'} gt '     ') {
        $items{'comremarks'}[5] = 'T';
    }
     
    # item - start page
    if (defined($crdcgi->param('start_page_selected'))) {
        $items{'page'}[0] = $crdcgi->param('start_page_selected');
    }
     
    # item - summary
    if (defined($crdcgi->param('scr_indicator_selected'))) {
        $items{'summary'}[0] = $crdcgi->param('scr_indicator_selected');
    }
    if (defined($crdcgi->param('scr_indicator'))) {
        $items{'summary'}[4]{'selection'} = $crdcgi->param('scr_indicator');
    }
    if ($items{'summary'}[4]{'selection'} gt ' ' && $items{'summary'}[4]{'selection'} ne 'both') {
        $items{'summary'}[5] = 'T';
    }
     
    # item - dupcomment
    if (defined($crdcgi->param('dup_comment_selected'))) {
        $items{'dupcomment'}[0] = $crdcgi->param('dup_comment_selected');
    }
    
    #
    print AdHocReportPage('schema' => $schema, 'dbh' => $dbh, 'command' => $command,
        'reporttitle' => ((defined($crdcgi->param('reporttitle'))) ? $crdcgi->param('reporttitle') : 'Ad Hoc Report'),
        'sortdirection' => $crdcgi->param('sortdirection'), 'report_boolean' => $crdcgi->param('report_boolean'),
        'text_limit' => ((defined($crdcgi->param('text_limit'))) ? $crdcgi->param('text_limit') : 'F'),
        'tables' => \%tables, 'items' => \%items, 'joins' => \@joins);
   
} elsif ($command eq 'report') {
    if ($documentid eq 'adhoc') {
    } else {
        print "<br><table border=0 width=750>\n";
        print "Command: $command<br>\n";
    }
} else {
    print "<br><table border=0 width=750>\n";
    print "Command: $command<br>\n";
}
print "</table></form>\n";
print "</font>\n</center>\n";
print "<script language=javascript>\n<!--\nvar mytext ='$errorstr';\nalert(unescape(mytext));\n//-->\n</script>\n" if ($errorstr);
print "</body>\n</html>\n";
&db_disconnect($dbh);
exit();
