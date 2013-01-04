#!/usr/local/bin/newperl -w
#
# $Source: /data/dev/cirs/perl/RCS/ad_hoc_reports.pl,v $
# $Revision: 1.5 $
# $Date: 2000/06/23 18:17:53 $
# $Author: atchleyb $
# $Locker:  $
# $Log: ad_hoc_reports.pl,v $
# Revision 1.5  2000/06/23 18:17:53  atchleyb
# Fixed bug with item block nested in with another item block
# Changed display of Functional to Technical
#
# Revision 1.4  2000/06/14 18:15:26  zepedaj
# Added code to limit description of WBS to 80 characters
#
# Revision 1.3  2000/05/19 23:03:09  atchleyb
# added workbreakdown structure to report options
#
# Revision 1.2  2000/05/18 23:00:25  zepedaj
# Added background image
#
# Revision 1.1  2000/05/12 23:36:52  atchleyb
# Initial revision
#
#
#
#
use integer;
use strict;
use ONCS_Header qw(:Constants);
use ONCS_Widgets qw(:Functions);
use ONCS_Utilities_Lib qw(:Functions);
use Tie::IxHash;
use DBI;
use DBD::Oracle qw(:ora_types);
use CGI qw(param);
use Carp;

my $cirscgi = new CGI;
my $username = $cirscgi->param("loginusername");
my $userid = $cirscgi->param("loginusersid");
my $schema = ((defined($cirscgi->param("schema"))) ? $cirscgi->param("schema") : $SCHEMA);
my $documentid = $cirscgi->param("id");
if (!(defined($documentid))) {$documentid='commitment';}
my $command = $cirscgi->param("command");
if (!(defined($command))) {$command='adhocsetup';}
#&checkLogin ($username, $userid, $schema);
$ENV{SCRIPT_NAME} =~ m%(.*/)(.*)\..*$%;
my $path = $1;
my $form = $2;
my $pageNum = 1;
my $dbh;
my $errorstr = "";
my $underDevelopment = &nbspaces(3) . "<b><font size=2 color=#ff0000>(currently under development)</font></b>";
my $printHeaderHelp = "<table border=1 width=75% align=center><tr><td><font size=-1><b><i>To set report page headers and footers for printing, select Page Setup... from the File menu, remove the text from the Footer box and replace the text in the Header box with the following:</i> <br><center>&d &t &b&bPage &p of &P</center><i>Then click on OK.</i></b></font></td></tr></table>\n";
my %tables;
my %items;
my @joins;
my %fields;
my $refval;
my @temparray;
my $itemsselected = 'F';
my $DateFormat = "'mm/dd/yyyy'";

# tables description
# 'table id' => ['selected', [ filed names ], 'table name', 'table alias']
%tables = (
    'issue' =>         ['F', ["issueid","text","entereddate","sourcedocid","page","enteredby","categoryid","dateoccurred"], 'issue', 'iss'],
    'commitment' =>    ['F', ["commitmentid","duedate","statusid","commitdate","criticalpath","estimate","functionalrecommend","commitmentrationale",
                        "text","comments","rejectionrationale","resubmitrationale","actionstaken","actionsummary","actionplan","cmrecommendation",
                        "closeddate","controlaccountid","issueid","approver","replacedby","updatedby","commitmentlevelid","oldid",
                        "primarydiscipline","secondarydiscipline"], 'commitment', 'com'],
    'committedorg' =>  ['F', ["commitmentid","organizationid"], 'committedorg', 'co'],
    'organiztion' =>   ['F', ["organiztionid","name","address1","address2","city","state","zipode","country","areacode","phonenumber","extension",
                        "contact","department","division","faxareacode","faxnumber","parentorg"], 'organiztion', 'org'],
    'keyword' =>       ['F', ["keyword","description","isactive"], 'keyword', 'keyw'],
    'issuekeyword' =>  ['F', ["issueid","keywordid"], 'issuekeyword', 'ikeyw'],
    'comkeyword' =>    ['F', ["commitmentid","keywordid"], 'commitmentkeyword', 'ckeyw'],
    'product' =>       ['F', ["productid","description","isactive"], 'product', 'prod'],
    'prodaffection' => ['F', ["productid","commitmentid"], 'productaffected', 'prodaff'],
    'response' =>      ['F', ["responseid","text","writtendate","commitmentid","letterid"], 'response', 'res'],
    'letter' =>        ['F', ["letterid","accessionnum","sentdate","addressee","signeddate","organizationid","signer"], 'letter', 'let'],
    'sourcedoc' =>     ['F', ["sourcedocid","accessionnum","title","signer","email","areacode","phonenumber","documentdate",
                        "organizationid","categoryid"], 'sourcedoc', 'sd'],
    'role' =>          ['F', ["roleid","description","isactive","dependson"], 'role', 'role'],
    #'comrole' =>       ['F', ["commitmentid","roleid","usersid"], 'commitmentrole', 'cr'],
    'category' =>      ['F', ["categoryid","description","isactive"], 'category', 'cat'],
    'status' =>        ['F', ["statusid","description","isactive"], 'status', 'st'],
    'cmlevel' =>       ['F', ["commitmentlevelid","description","isactive","definition"], 'commitmentlevel', 'cl'],
    'wbs' =>           ['F', ["changerequestnum","controlaccountid","description","pointofcontact","isactive"], 'workbreakdownstructure', 'wbs']
);

#
##################
#
# items description
# 'item id' => ['selected', 'sort by', 'sort code', [ required tables ], { parameter hash }, 'has selections', { forms }]
%items = (
    'issueid'            => ['F', 'F', 'iss.issueid', ['issue'], {'id' => ''}, 'F', {'commitment' => 'T'}],
    #'issite'             => ['F', 'F', '', ['issue'], {'id' => ''}, 'F', {'commitment' => 'T'}],
    'istext'             => ['F', 'F', '', ['issue'], {}, 'F', {'commitment' => 'T'}],
    'isentereddate'      => ['F', 'F', 'iss.entereddate', ['issue'], {'startdate' => '', 'enddate' => ''}, 'F', {'commitment' => 'T'}],
    'ispage'             => ['F', 'F', '', ['issue'], {}, 'F', {'commitment' => 'T'}],
    'iscategory'         => ['F', 'F', 'cat.description', ['issue','category'], {'list' => []}, 'F', {'commitment' => 'T'}],
    'isenteredby'        => ['F', 'F', '', ['issue'], {id => ''}, 'F', {'commitment' => 'T'}],
    'iskeyword'          => ['F', 'F', '', ['issue'], {'list' => [], 'boolean' => 'any'}, 'F', {'commitment' => 'T'}],
    'sourcedoc'          => ['F', 'F', 'sd.accessionnum', ['issue','sourcedoc'], {'id' => '', details => 'F'}, 'F', {'commitment' => 'T'}],
    'commitmentid'       => ['F', 'F', 'com.commitmentid', ['commitment'], {'id' => ''}, 'F', {'commitment' => 'T'}],
    'controlaccountid'   => ['F', 'F', 'wbs.controlaccountid', ['wbs'], {'id' => ''}, 'F', {'commitment' => 'T'}],
    #'comsite'            => ['F', 'F', '', ['commitment'], {'id' => ''}, 'F', {'commitment' => 'T'}],
    #'comrole'            => ['F', 'F', '', ['commitment'], {'id' => ''}, 'F', {'commitment' => 'T'}],
    'comduedate'         => ['F', 'F', 'com.duedate', ['commitment'], {'startdate' => '', 'enddate' => ''}, 'F', {'commitment' => 'T'}],
    'cfunctionaldisp'    => ['F', 'F', '', ['commitment'], {'id' => ''}, 'F', {'commitment' => 'T'}],
    'cestimate'          => ['F', 'F', '', ['commitment'], {}, 'F', {'commitment' => 'T'}],
    'cfunctionalrec'     => ['F', 'F', '', ['commitment'], {}, 'F', {'commitment' => 'T'}],
    'ccommitrationale'   => ['F', 'F', '', ['commitment'], {}, 'F', {'commitment' => 'T'}],
    'capprovalrationale' => ['F', 'F', '', ['commitment'], {}, 'F', {'commitment' => 'T'}],
    'ctext'              => ['F', 'F', '', ['commitment'], {}, 'F', {'commitment' => 'T'}],
    'ccomments'          => ['F', 'F', '', ['commitment'], {}, 'F', {'commitment' => 'T'}],
    'crejectrationale'   => ['F', 'F', '', ['commitment'], {}, 'F', {'commitment' => 'T'}],
    'cresubrationale'    => ['F', 'F', '', ['commitment'], {}, 'F', {'commitment' => 'T'}],
    'cactionstaken'      => ['F', 'F', '', ['commitment'], {}, 'F', {'commitment' => 'T'}],
    'cactionsummary'     => ['F', 'F', '', ['commitment'], {}, 'F', {'commitment' => 'T'}],
    'cactionplan'        => ['F', 'F', '', ['commitment'], {}, 'F', {'commitment' => 'T'}],
    'ccmrecommendation'  => ['F', 'F', '', ['commitment'], {}, 'F', {'commitment' => 'T'}],
    'coldid'             => ['F', 'F', 'com.oldid', ['commitment'], {'id' => ''}, 'F', {'commitment' => 'T'}],
    'ccloseddate'        => ['F', 'F', 'com.closeddate', ['commitment'], {'startdate' => '', 'enddate' => ''}, 'F', {'commitment' => 'T'}],
    'ccontrolaccountid'  => ['F', 'F', 'com.controlaccountid', ['commitment'], {'id' => ''}, 'F', {'commitment' => 'T'}],
    'capprover'          => ['F', 'F', '', ['commitment'], {'id' => ''}, 'F', {'commitment' => 'T'}],
    'cupdatedby'         => ['F', 'F', '', ['commitment'], {'id' => ''}, 'F', {'commitment' => 'T'}],
    'creplacedby'        => ['F', 'F', 'com.replacedby', ['commitment'], {'id' => ''}, 'F', {'commitment' => 'T'}],
    'cstatusid'          => ['F', 'F', 'st.description', ['commitment', 'status'], {'id' => ''}, 'F', {'commitment' => 'T'}],
    'ccommitmentlevel'   => ['F', 'F', 'cl.description', ['commitment','cmlevel'], {'id' => ''}, 'F', {'commitment' => 'T'}],
    'ckeyword'           => ['F', 'F', '', ['commitment'], {'list' => [], 'boolean' => 'any'}, 'F', {'commitment' => 'T'}],
    'product'            => ['F', 'F', '', ['commitment'], {'list' => [], 'boolean' => 'any'}, 'F', {'commitment' => 'T'}],
    'organization'       => ['F', 'F', '', ['commitment'], {'id' => '', 'details' => 'F'}, 'F', {'commitment' => 'T'}],
    'response'           => ['F', 'F', '', ['commitment'], {'details' => 'F'}, 'F', {'commitment' => 'T'}]
);
#    ''                  => ['F', 'F', '', ['commitment'], {}, 'F', {'commitment' => 'T'}],

# joins description
# ['table 1', 'table 2', 'sql join', 'optional order by']
@joins = (
    ['issue','sourcedoc','iss.sourcedocid = sd.sourcedocid(+)',''],
    ['issue','category','iss.categoryid = cat.categoryid(+)','cat.description,iss.issueid'],
    ['issue','commitment','iss.issueid = com.issueid(+)','iss.issueid,com.commitmentid'],
    ['commitment','status','com.statusid = st.statusid(+)',''],
    ['commitment','wbs','com.controlaccountid = wbs.controlaccountid(+)',''],
    ['commitment','cmlevel','com.commitmentlevelid = cl.commitmentlevelid(+)','']
);

%fields = (
);


sub processError {
   my %args = (
      @_,
   );
   my $error = &errorMessage($dbh, $username, $userid, '','', $args{activity}, $@);
   $error =  ('_' x 100) . "\n\n" . $error if ($errorstr ne "");
   $error =~ s/\n/\\n/g;
   $error =~ s/'/%27/g;
   $errorstr .= $error;
}


sub getReportDateTime {
    my @timedata = localtime(time);
    return(uc(get_date('')) . " " . lpadzero($timedata[2],2) . ":" . lpadzero($timedata[1],2) . ":" . lpadzero($timedata[0],2));
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
        type => 'committment',
        @_,
    );

    my $outputstring = '';
    my %items;
    my $refvar = $args{'items'};
    %items = %$refvar;
    tie my %lookup_values, "Tie::IxHash";
    tie my %lookup_values2, "Tie::IxHash";
    my $message ='';

    eval {
        $outputstring .= "<tr><td>\n$printHeaderHelp</td></tr>\n";
        $outputstring .= "<tr><td>\n";
        $outputstring .= "<br>Report Title: &nbsp <input type=text size=40 name=reporttitle><br><br>\n";

        $outputstring .= "<table border=1 cellpadding=10><tr>\n";
        $outputstring .= "<td valign=top align=center><b>Include<br>in<br>Report</b><br><font size=-1><br><a href=\"javascript:setIncludes(true);\">Select&nbspAll</a><br><br><a href=\"javascript:setIncludes(false);\">Clear All</a></font></td>\n";
        $outputstring .= "<td valign=top><b>Sort</b><br>\n";
        $outputstring .= "<input type=radio checked name=sortdirection value=assending>asc<br>\n";
        $outputstring .= "<input type=radio name=sortdirection value=desending>desc</td>\n";
        $outputstring .= "<td valign=top><b>Description/Qualifiers/Selection Criteria</b><br>\n";
        $outputstring .= "Records will be selected if they match <input type=radio checked name=report_boolean value=all>all or\n";
        $outputstring .= "<input type=radio name=report_boolean value=any>any of the entered qualifiers.<br>\n";
        if ($args{type} ne 'commentor') {
            $outputstring .= "Limit text blocks to the first line. <input type=checkbox checked name=text_limit value='T'><br>\n";
        } else {
            $outputstring .= "<input type=hidden name=text_limit value='T'>\n";
        }
        $outputstring .= "<i>Entering values into the fields below will limit your report to Records that match the entered values,\n";
        $outputstring .= "even if 'Include in Report' is not selected for that field.\n";
        $outputstring .= "Too many qualified fields, when 'all' is selected above, may cause the resulting report to be empty.\n";
        $outputstring .= "<br><br><center><font size=-1><a href=\"javascript:clearForm();\">Clear all Selections</a></font></center></i></td></tr>\n";

#
##################
#

        if ($items{'issueid'}[6]{$args{type}} eq 'T') {
            $outputstring .= "<tr><td valign=top align=center><input type=checkbox name=issueid_selected value='T' checked onClick=\"document.$form.issueid_selected.checked=true;\"></td>\n";
            $outputstring .= "<td valign=top align=center><input type=radio checked name=sortorder value=issueid_sort></td><td valign=top>\n";
            $outputstring .= "Issue ID: <input type=text size=10 maxlength=10 name=issueid> &nbsp\n";
            $outputstring .= "</td></tr>\n";
        }

        #if ($items{'issite'}[6]{$args{type}} eq 'T') {
        #    $outputstring .= "<tr><td valign=top align=center><input type=checkbox name=issite_selected value='T'></td>\n";
        #    $outputstring .= "<td valign=top align=center>&nbsp;</td><td valign=top>\n";
        #    %lookup_values = get_lookup_values($args{'dbh'},'site','siteid',"name", "1=1 ORDER BY name");
        #    $outputstring .= "Issue Site: &nbsp;\n";
        #    $outputstring .= build_drop_box ('issite', \%lookup_values, '0', 'InitialBlank', '');
        #    $outputstring .= "</td></tr>\n";
        #}

        if ($items{'sourcedoc'}[6]{$args{type}} eq 'T') {
            $outputstring .= "<tr><td valign=top align=center><input type=checkbox name=sourcedoc_selected value='T'></td>\n";
            $outputstring .= "<td valign=top align=center><input type=radio name=sortorder value=sourcedoc_sort></td><td valign=top>\n";
            $outputstring .= "Source Document Accession Number: <input type=text size=17 maxlength=17 name=sourcedoc>\n";
            $outputstring .= "<br>Show details <input type=checkbox name=sddetails value='T'>\n";
            $outputstring .= "</td></tr>\n";
        }

        if ($items{'isentereddate'}[6]{$args{type}} eq 'T') {
            $outputstring .= "<tr><td valign=top align=center><input type=checkbox name=isentereddate_selected value='T'></td>\n";
            $outputstring .= "<td valign=top align=center><input type=radio name=sortorder value=isentereddate_sort></td><td valign=top>\n";
            $outputstring .= "Issue Entry Date:<br>\n";
            $outputstring .= "<table border=0 width=100%>\n";
            $outputstring .= "<tr><td>" . nbspaces(10) . "</td><td><font size=-1>Starting &nbsp; </font></td><td>" . build_date_selection('isentereddate_start',$form,'blank') . "</td></tr>\n";
            $outputstring .= "<tr><td>" . nbspaces(10) . "</td><td><font size=-1>Ending </font></td><td>" . build_date_selection('isentereddate_end',$form,'blank') . "</td></tr>\n";
            $outputstring .= "</table>\n";
            $outputstring .= "</td></tr>\n";
        }

        if ($items{'iscategory'}[6]{$args{type}} eq 'T') {
            $outputstring .= "<tr><td valign=top align=center><input type=checkbox name=iscategory_selected value='T'></td>\n";
            $outputstring .= "<td valign=top align=center><input type=radio name=sortorder value=iscategory_sort></td><td valign=top>\n";
            $outputstring .= "Issue Category:<br>\n";
            %lookup_values = get_lookup_values($args{'dbh'},'category','categoryid',"description", "1=1 ORDER BY description");
            $outputstring .= build_dual_select ('iscategory', $form, \%lookup_values, \%lookup_values2, '<b>Available</b>', '<b>Selected</b>', 0);
            $outputstring .= "</td></tr>\n";
        }

        if ($items{'iskeyword'}[6]{$args{type}} eq 'T') {
            $outputstring .= "<tr><td valign=top align=center><input type=checkbox name=iskeyword_selected value='T'></td>\n";
            $outputstring .= "<td valign=top align=center>&nbsp;</td><td valign=top>\n";
            $outputstring .= "Issue Keywords:<br>\n";
            %lookup_values = get_lookup_values($args{'dbh'},'keyword','keywordid',"description", "keywordid IN (SELECT keywordid FROM $schema.issuekeyword) ORDER BY description");
            $outputstring .= build_dual_select ('iskeyword', $form, \%lookup_values, \%lookup_values2, '<b>Available</b>', '<b>Selected</b>', 0);
            $outputstring .= nbspaces(5) . "<i>Match <input type=radio name=iskeyword_boolean value=all checked>all or <input type=radio name=iskeyword_boolean value=any>any keyword(s).</i>\n";
            $outputstring .= "</td></tr>\n";
        }

        if ($items{'isenteredby'}[6]{$args{type}} eq 'T') {
            $outputstring .= "<tr><td valign=top align=center><input type=checkbox name=isenteredby_selected value='T'></td>\n";
            $outputstring .= "<td valign=top align=center>&nbsp;</td><td valign=top>\n";
            %lookup_values = get_lookup_values($args{'dbh'},'users','usersid',"lastname || ', ' || firstname", "usersid IN (SELECT enteredby FROM $schema.issue) ORDER BY lastname, firstname");
            $outputstring .= "Issue Entered By: &nbsp;\n";
            $outputstring .= build_drop_box ('isenteredby', \%lookup_values, '0', 'InitialBlank', '');
            $outputstring .= "</td></tr>\n";
        }

        if ($items{'ispage'}[6]{$args{type}} eq 'T') {
            $outputstring .= "<tr><td valign=top align=center><input type=checkbox name=ispage_selected value='T'></td>\n";
            $outputstring .= "<td valign=top align=center>&nbsp;</td><td valign=top>\n";
            $outputstring .= "Issue Page Number\n";
            $outputstring .= "</td></tr>\n";
        }

        if ($items{'istext'}[6]{$args{type}} eq 'T') {
            $outputstring .= "<tr><td valign=top align=center><input type=checkbox name=istext_selected value='T'></td>\n";
            $outputstring .= "<td valign=top align=center>&nbsp;</td><td valign=top>\n";
            $outputstring .= "Issue Text\n";
            $outputstring .= "</td></tr>\n";
        }

        if ($items{'commitmentid'}[6]{$args{type}} eq 'T') {
            $outputstring .= "<tr><td valign=top align=center><input type=checkbox name=commitmentid_selected value='T'></td>\n";
            $outputstring .= "<td valign=top align=center><input type=radio name=sortorder value=commitmentid_sort></td><td valign=top>\n";
            $outputstring .= "Commitment ID: <input type=text size=10 maxlength=10 name=commitmentid>\n";
            $outputstring .= "</td></tr>\n";
        }

        if ($items{'controlaccountid'}[6]{$args{type}} eq 'T') {
            $outputstring .= "<tr><td valign=top align=center><input type=checkbox name=controlaccountid_selected value='T'></td>\n";
            $outputstring .= "<td valign=top align=center><input type=radio name=sortorder value=controlaccountid_sort></td><td valign=top>\n";
            %lookup_values = get_lookup_values($args{'dbh'},'workbreakdownstructure',"controlaccountid","controlaccountid || ' - ' || description", "1=1 ORDER BY controlaccountid");
            while ((my $keyitem, my $valueitem) = each %lookup_values)
              {
              $lookup_values{$keyitem} = getDisplayString ($valueitem, 80);
              }
            $outputstring .= "Work Breakdown Structure: &nbsp;\n";
            $outputstring .= build_drop_box ('controlaccountid', \%lookup_values, '0', 'InitialBlank', '');
            $outputstring .= "</td></tr>\n";
        }

        #if ($items{'comsite'}[6]{$args{type}} eq 'T') {
        #    $outputstring .= "<tr><td valign=top align=center><input type=checkbox name=comsite_selected value='T'></td>\n";
        #    $outputstring .= "<td valign=top align=center>&nbsp;</td><td valign=top>\n";
        #    %lookup_values = get_lookup_values($args{'dbh'},'site','siteid',"name", "1=1 ORDER BY name");
        #    $outputstring .= "Commitment Site: &nbsp;\n";
        #    $outputstring .= build_drop_box ('comsite', \%lookup_values, '0', 'InitialBlank', '');
        #    $outputstring .= "</td></tr>\n";
        #}

        #if ($items{'comrole'}[6]{$args{type}} eq 'T') {
        #    $outputstring .= "<tr><td valign=top align=center><input type=checkbox name=comrole_selected value='T'></td>\n";
        #    $outputstring .= "<td valign=top align=center>&nbsp;</td><td valign=top>\n";
        #    my $rolesqlquery = "SELECT DISTINCT cr.roleid, cr.usersid, r.description descr, u.lastname lname, u.firstname fname, 'commitment' tablenamestring ";
        #    $rolesqlquery .= "FROM $args{schema}.commitmentrole cr, $args{schema}.role r, $args{schema}.users u ";
        #    $rolesqlquery .= "WHERE (cr.roleid = r.roleid) AND (cr.usersid = u.usersid) ";
        #    $rolesqlquery .= "UNION SELECT DISTINCT ir.roleid, ir.usersid, r.description descr, u.lastname lname, u.firstname fname, 'issue' tablenamestring ";
        #    $rolesqlquery .= "FROM $args{schema}.issuerole ir, $args{schema}.role r, $args{schema}.users u ";
        #    $rolesqlquery .= "WHERE (ir.roleid = r.roleid) AND (ir.usersid = u.usersid) ";
        #    $rolesqlquery .= "ORDER BY lname,fname, descr";
        #    print "<!-- $rolesqlquery -->\n";
        #    my $rolecsr = $args{dbh}->prepare($rolesqlquery);
        #    my @rolevalues;
        #    %lookup_values = ();
        #    $rolecsr->execute;
        #    while (@rolevalues = $rolecsr->fetchrow_array) {
        #        $lookup_values{"$rolevalues[0]-$rolevalues[1]-$rolevalues[5]"} = "$rolevalues[3], $rolevalues[4] - $rolevalues[2]";
        #    }
        #    $rolecsr->finish;
        #    $outputstring .= "Commitment Role: &nbsp;\n";
        #    $outputstring .= build_drop_box ('comrole', \%lookup_values, '0', 'InitialBlank', '');
        #    $outputstring .= "</td></tr>\n";
        #}

        if ($items{'comduedate'}[6]{$args{type}} eq 'T') {
            $outputstring .= "<tr><td valign=top align=center><input type=checkbox name=comduedate_selected value='T'></td>\n";
            $outputstring .= "<td valign=top align=center><input type=radio name=sortorder value=comduedate_sort></td><td valign=top>\n";
            $outputstring .= "Date Due to Commitment Maker:<br>\n";
            $outputstring .= "<table border=0 width=100%>\n";
            $outputstring .= "<tr><td>" . nbspaces(10) . "</td><td><font size=-1>Starting &nbsp; </font></td><td>" . build_date_selection('comduedate_start',$form,'blank') . "</td></tr>\n";
            $outputstring .= "<tr><td>" . nbspaces(10) . "</td><td><font size=-1>Ending </font></td><td>" . build_date_selection('comduedate_end',$form,'blank') . "</td></tr>\n";
            $outputstring .= "</table>\n";
            $outputstring .= "</td></tr>\n";
        }

        if ($items{'cfunctionaldisp'}[6]{$args{type}} eq 'T') {
            $outputstring .= "<tr><td valign=top align=center><input type=checkbox name=cfunctionaldisp_selected value='T'></td>\n";
            $outputstring .= "<td valign=top align=center>&nbsp;</td><td valign=top>\n";
            %lookup_values = get_lookup_values($args{'dbh'},'discipline','disciplineid',"description", "1=1 ORDER BY description");
            $outputstring .= "Functional Discipline: &nbsp;\n";
            $outputstring .= build_drop_box ('cfunctionaldisp', \%lookup_values, '0', 'InitialBlank', '');
            $outputstring .= "</td></tr>\n";
        }

        if ($items{'cestimate'}[6]{$args{type}} eq 'T') {
            $outputstring .= "<tr><td valign=top align=center><input type=checkbox name=cestimate_selected value='T'></td>\n";
            $outputstring .= "<td valign=top align=center>&nbsp;</td><td valign=top>\n";
            $outputstring .= "Estimate\n";
            $outputstring .= "</td></tr>\n";
        }

        if ($items{'cfunctionalrec'}[6]{$args{type}} eq 'T') {
            $outputstring .= "<tr><td valign=top align=center><input type=checkbox name=cfunctionalrec_selected value='T'></td>\n";
            $outputstring .= "<td valign=top align=center>&nbsp;</td><td valign=top>\n";
            $outputstring .= "DOE Discipline Lead Recomend\n";
            $outputstring .= "</td></tr>\n";
        }

        if ($items{'ccommitrationale'}[6]{$args{type}} eq 'T') {
            $outputstring .= "<tr><td valign=top align=center><input type=checkbox name=ccommitrationale_selected value='T'></td>\n";
            $outputstring .= "<td valign=top align=center>&nbsp;</td><td valign=top>\n";
            $outputstring .= "Commitment Rationale\n";
            $outputstring .= "</td></tr>\n";
        }

        if ($items{'capprovalrationale'}[6]{$args{type}} eq 'T') {
            $outputstring .= "<tr><td valign=top align=center><input type=checkbox name=capprovalrationale_selected value='T'></td>\n";
            $outputstring .= "<td valign=top align=center>&nbsp;</td><td valign=top>\n";
            $outputstring .= "Approval Rationale\n";
            $outputstring .= "</td></tr>\n";
        }

        if ($items{'ctext'}[6]{$args{type}} eq 'T') {
            $outputstring .= "<tr><td valign=top align=center><input type=checkbox name=ctext_selected value='T'></td>\n";
            $outputstring .= "<td valign=top align=center>&nbsp;</td><td valign=top>\n";
            $outputstring .= "Commitment Text\n";
            $outputstring .= "</td></tr>\n";
        }

        if ($items{'ccomments'}[6]{$args{type}} eq 'T') {
            $outputstring .= "<tr><td valign=top align=center><input type=checkbox name=ccomments_selected value='T'></td>\n";
            $outputstring .= "<td valign=top align=center>&nbsp;</td><td valign=top>\n";
            $outputstring .= "Commitment Comments\n";
            $outputstring .= "</td></tr>\n";
        }

        if ($items{'crejectrationale'}[6]{$args{type}} eq 'T') {
            $outputstring .= "<tr><td valign=top align=center><input type=checkbox name=crejectrationale_selected value='T'></td>\n";
            $outputstring .= "<td valign=top align=center>&nbsp;</td><td valign=top>\n";
            $outputstring .= "Rejection Rationale\n";
            $outputstring .= "</td></tr>\n";
        }

        if ($items{'cresubrationale'}[6]{$args{type}} eq 'T') {
            $outputstring .= "<tr><td valign=top align=center><input type=checkbox name=cresubrationale_selected value='T'></td>\n";
            $outputstring .= "<td valign=top align=center>&nbsp;</td><td valign=top>\n";
            $outputstring .= "Resubmit Rationale\n";
            $outputstring .= "</td></tr>\n";
        }

        if ($items{'cactionstaken'}[6]{$args{type}} eq 'T') {
            $outputstring .= "<tr><td valign=top align=center><input type=checkbox name=cactionstaken_selected value='T'></td>\n";
            $outputstring .= "<td valign=top align=center>&nbsp;</td><td valign=top>\n";
            $outputstring .= "Actions Taken\n";
            $outputstring .= "</td></tr>\n";
        }

        if ($items{'cactionsummary'}[6]{$args{type}} eq 'T') {
            $outputstring .= "<tr><td valign=top align=center><input type=checkbox name=cactionsummary_selected value='T'></td>\n";
            $outputstring .= "<td valign=top align=center>&nbsp;</td><td valign=top>\n";
            $outputstring .= "Actions Summary\n";
            $outputstring .= "</td></tr>\n";
        }

        if ($items{'cactionplan'}[6]{$args{type}} eq 'T') {
            $outputstring .= "<tr><td valign=top align=center><input type=checkbox name=cactionplan_selected value='T'></td>\n";
            $outputstring .= "<td valign=top align=center>&nbsp;</td><td valign=top>\n";
            $outputstring .= "Action Plan\n";
            $outputstring .= "</td></tr>\n";
        }

        if ($items{'ccmrecommendation'}[6]{$args{type}} eq 'T') {
            $outputstring .= "<tr><td valign=top align=center><input type=checkbox name=ccmrecommendation_selected value='T'></td>\n";
            $outputstring .= "<td valign=top align=center>&nbsp;</td><td valign=top>\n";
            $outputstring .= "CM Recomendation\n";
            $outputstring .= "</td></tr>\n";
        }

        if ($items{'coldid'}[6]{$args{type}} eq 'T') {
            $outputstring .= "<tr><td valign=top align=center><input type=checkbox name=coldid_selected value='T'></td>\n";
            $outputstring .= "<td valign=top align=center><input type=radio name=sortorder value=coldid_sort></td><td valign=top>\n";
            $outputstring .= "Old Commitment ID: <input type=text size=20 maxlength=20 name=coldid>\n";
            $outputstring .= "</td></tr>\n";
        }

        if ($items{'ccloseddate'}[6]{$args{type}} eq 'T') {
            $outputstring .= "<tr><td valign=top align=center><input type=checkbox name=ccloseddate_selected value='T'></td>\n";
            $outputstring .= "<td valign=top align=center><input type=radio name=sortorder value=ccloseddate_sort></td><td valign=top>\n";
            $outputstring .= "Commitment Colsed Date:<br>\n";
            $outputstring .= "<table border=0 width=100%>\n";
            $outputstring .= "<tr><td>" . nbspaces(10) . "</td><td><font size=-1>Starting &nbsp; </font></td><td>" . build_date_selection('ccloseddate_start',$form,'blank') . "</td></tr>\n";
            $outputstring .= "<tr><td>" . nbspaces(10) . "</td><td><font size=-1>Ending </font></td><td>" . build_date_selection('ccloseddate_end',$form,'blank') . "</td></tr>\n";
            $outputstring .= "</table>\n";
            $outputstring .= "</td></tr>\n";
        }

        if ($items{'ccontrolaccountid'}[6]{$args{type}} eq 'T') {
            $outputstring .= "<tr><td valign=top align=center><input type=checkbox name=ccontrolaccountid_selected value='T'></td>\n";
            $outputstring .= "<td valign=top align=center><input type=radio name=sortorder value=ccontrolaccountid_sort></td><td valign=top>\n";
            $outputstring .= "Accession #: <input type=text size=10 maxlength=10 name=ccontrolaccountid>\n";
            $outputstring .= "</td></tr>\n";
        }

        if ($items{'capprover'}[6]{$args{type}} eq 'T') {
            $outputstring .= "<tr><td valign=top align=center><input type=checkbox name=capprover_selected value='T'></td>\n";
            $outputstring .= "<td valign=top align=center>&nbsp;</td><td valign=top>\n";
            %lookup_values = get_lookup_values($args{'dbh'},'users','usersid',"lastname || ', ' || firstname", "usersid IN (SELECT approver FROM $schema.commitment) ORDER BY lastname, firstname");
            $outputstring .= "Commitment Maker: &nbsp;\n";
            $outputstring .= build_drop_box ('capprover', \%lookup_values, '0', 'InitialBlank', '');
            $outputstring .= "</td></tr>\n";
        }

        if ($items{'cupdatedby'}[6]{$args{type}} eq 'T') {
            $outputstring .= "<tr><td valign=top align=center><input type=checkbox name=cupdatedby_selected value='T'></td>\n";
            $outputstring .= "<td valign=top align=center>&nbsp;</td><td valign=top>\n";
            %lookup_values = get_lookup_values($args{'dbh'},'users','usersid',"lastname || ', ' || firstname", "usersid IN (SELECT updatedby FROM $schema.commitment) ORDER BY lastname, firstname");
            $outputstring .= "Commitment Updated By: &nbsp;\n";
            $outputstring .= build_drop_box ('cupdatedby', \%lookup_values, '0', 'InitialBlank', '');
            $outputstring .= "</td></tr>\n";
        }

        if ($items{'creplacedby'}[6]{$args{type}} eq 'T') {
            $outputstring .= "<tr><td valign=top align=center><input type=checkbox name=creplacedby_selected value='T'></td>\n";
            $outputstring .= "<td valign=top align=center><input type=radio name=sortorder value=creplacedby_sort></td><td valign=top>\n";
            $outputstring .= "Replaced By ID: <input type=text size=10 maxlength=10 name=creplacedby>\n";
            $outputstring .= "</td></tr>\n";
        }

        if ($items{'cstatusid'}[6]{$args{type}} eq 'T') {
            $outputstring .= "<tr><td valign=top align=center><input type=checkbox name=cstatusid_selected value='T'></td>\n";
            $outputstring .= "<td valign=top align=center><input type=radio name=sortorder value=cstatusid_sort></td><td valign=top>\n";
            %lookup_values = get_lookup_values($args{'dbh'},'status','statusid',"description", "(1=1) ORDER BY description");
            $outputstring .= "Commitment Status: &nbsp;\n";
            $outputstring .= build_drop_box ('cstatusid', \%lookup_values, '0', 'InitialBlank', '');
            $outputstring .= "</td></tr>\n";
        }

        if ($items{'ccommitmentlevel'}[6]{$args{type}} eq 'T') {
            $outputstring .= "<tr><td valign=top align=center><input type=checkbox name=ccommitmentlevel_selected value='T'></td>\n";
            $outputstring .= "<td valign=top align=center><input type=radio name=sortorder value=ccommitmentlevel_sort></td><td valign=top>\n";
            %lookup_values = get_lookup_values($args{'dbh'},'commitmentlevel','commitmentlevelid',"description", "(1=1) ORDER BY description");
            $outputstring .= "Commitment Level: &nbsp;\n";
            $outputstring .= build_drop_box ('ccommitmentlevel', \%lookup_values, '0', 'InitialBlank', '');
            $outputstring .= "</td></tr>\n";
        }

        if ($items{'ckeyword'}[6]{$args{type}} eq 'T') {
            $outputstring .= "<tr><td valign=top align=center><input type=checkbox name=ckeyword_selected value='T'></td>\n";
            $outputstring .= "<td valign=top align=center>&nbsp;</td><td valign=top>\n";
            $outputstring .= "Commitment Keywords:<br>\n";
            %lookup_values = get_lookup_values($args{'dbh'},'keyword','keywordid',"description", "keywordid IN (SELECT keywordid FROM $schema.commitmentkeyword) ORDER BY description");
            $outputstring .= build_dual_select ('ckeyword', $form, \%lookup_values, \%lookup_values2, '<b>Available</b>', '<b>Selected</b>', 0);
            $outputstring .= nbspaces(5) . "<i>Match <input type=radio name=ckeyword_boolean value=all checked>all or <input type=radio name=ckeyword_boolean value=any>any keyword(s).</i>\n";
            $outputstring .= "</td></tr>\n";
        }

        if ($items{'product'}[6]{$args{type}} eq 'T') {
            $outputstring .= "<tr><td valign=top align=center><input type=checkbox name=product_selected value='T'></td>\n";
            $outputstring .= "<td valign=top align=center>&nbsp;</td><td valign=top>\n";
            $outputstring .= "Products Affected:<br>\n";
            %lookup_values = get_lookup_values($args{'dbh'},'product','productid',"description", "(1=1) ORDER BY description");
            $outputstring .= build_dual_select ('product', $form, \%lookup_values, \%lookup_values2, '<b>Available</b>', '<b>Selected</b>', 0);
            $outputstring .= nbspaces(5) . "<i>Match <input type=radio name=product_boolean value=all checked>all or <input type=radio name=product_boolean value=any>any keyword(s).</i>\n";
            $outputstring .= "</td></tr>\n";
        }

        if ($items{'organization'}[6]{$args{type}} eq 'T') {
            $outputstring .= "<tr><td valign=top align=center><input type=checkbox name=organization_selected value='T'></td>\n";
            $outputstring .= "<td valign=top align=center>&nbsp;</td><td valign=top>\n";
            %lookup_values = get_lookup_values($args{'dbh'},'organization','organizationid',"name", "(1=1) ORDER BY name");
            $outputstring .= "Committed Organization: &nbsp;\n";
            $outputstring .= build_drop_box ('organization', \%lookup_values, '0', 'InitialBlank', '');
            $outputstring .= "<br>Show details <input type=checkbox name=organization_details value='T'>\n";
            $outputstring .= "</td></tr>\n";
        }

        if ($items{'response'}[6]{$args{type}} eq 'T') {
            $outputstring .= "<tr><td valign=top align=center><input type=checkbox name=response_selected value='T'></td>\n";
            $outputstring .= "<td valign=top align=center>&nbsp;</td><td valign=top>\n";
            $outputstring .= "Commitment Response &nbsp;\n";
            $outputstring .= "<br>Show details <input type=checkbox name=response_details value='T'>\n";
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
        if ($items{'issueid'}[6]{$args{type}} eq 'T')               {$outputstring .= "        document.$form.issueid_selected.checked = true;\n";}
        #if ($items{'issite'}[6]{$args{type}} eq 'T')                {$outputstring .= "        document.$form.issite_selected.checked = isChecked;\n";}
        if ($items{'isentereddate'}[6]{$args{type}} eq 'T')         {$outputstring .= "        document.$form.isentereddate_selected.checked = isChecked;\n";}
        if ($items{'iscategory'}[6]{$args{type}} eq 'T')            {$outputstring .= "        document.$form.iscategory_selected.checked = isChecked;\n";}
        if ($items{'isenteredby'}[6]{$args{type}} eq 'T')           {$outputstring .= "        document.$form.isenteredby_selected.checked = isChecked;\n";}
        if ($items{'ispage'}[6]{$args{type}} eq 'T')                {$outputstring .= "        document.$form.ispage_selected.checked = isChecked;\n";}
        if ($items{'istext'}[6]{$args{type}} eq 'T')                {$outputstring .= "        document.$form.istext_selected.checked = isChecked;\n";}
        if ($items{'iskeyword'}[6]{$args{type}} eq 'T')             {$outputstring .= "        document.$form.iskeyword_selected.checked = isChecked;\n";}
        if ($items{'sourcedoc'}[6]{$args{type}} eq 'T')             {$outputstring .= "        document.$form.sourcedoc_selected.checked = isChecked;\n";}
        if ($items{'commitmentid'}[6]{$args{type}} eq 'T')          {$outputstring .= "        document.$form.commitmentid_selected.checked = isChecked;\n";}
        if ($items{'controlaccountid'}[6]{$args{type}} eq 'T')      {$outputstring .= "        document.$form.controlaccountid_selected.checked = isChecked;\n";}
        #if ($items{'comsite'}[6]{$args{type}} eq 'T')               {$outputstring .= "        document.$form.comsite_selected.checked = isChecked;\n";}
        #if ($items{'comrole'}[6]{$args{type}} eq 'T')               {$outputstring .= "        document.$form.comrole_selected.checked = isChecked;\n";}
        if ($items{'comduedate'}[6]{$args{type}} eq 'T')            {$outputstring .= "        document.$form.comduedate_selected.checked = isChecked;\n";}
        if ($items{'cfunctionaldisp'}[6]{$args{type}} eq 'T')       {$outputstring .= "        document.$form.cfunctionaldisp_selected.checked = isChecked;\n";}
        if ($items{'cestimate'}[6]{$args{type}} eq 'T')             {$outputstring .= "        document.$form.cestimate_selected.checked = isChecked;\n";}
        if ($items{'cfunctionalrec'}[6]{$args{type}} eq 'T')        {$outputstring .= "        document.$form.cfunctionalrec_selected.checked = isChecked;\n";}
        if ($items{'ccommitrationale'}[6]{$args{type}} eq 'T')      {$outputstring .= "        document.$form.ccommitrationale_selected.checked = isChecked;\n";}
        if ($items{'capprovalrationale'}[6]{$args{type}} eq 'T')    {$outputstring .= "        document.$form.capprovalrationale_selected.checked = isChecked;\n";}
        if ($items{'ctext'}[6]{$args{type}} eq 'T')                 {$outputstring .= "        document.$form.ctext_selected.checked = isChecked;\n";}
        if ($items{'ccomments'}[6]{$args{type}} eq 'T')             {$outputstring .= "        document.$form.ccomments_selected.checked = isChecked;\n";}
        if ($items{'crejectrationale'}[6]{$args{type}} eq 'T')      {$outputstring .= "        document.$form.crejectrationale_selected.checked = isChecked;\n";}
        if ($items{'cresubrationale'}[6]{$args{type}} eq 'T')       {$outputstring .= "        document.$form.cresubrationale_selected.checked = isChecked;\n";}
        if ($items{'cactionstaken'}[6]{$args{type}} eq 'T')         {$outputstring .= "        document.$form.cactionstaken_selected.checked = isChecked;\n";}
        if ($items{'cactionsummary'}[6]{$args{type}} eq 'T')        {$outputstring .= "        document.$form.cactionsummary_selected.checked = isChecked;\n";}
        if ($items{'cactionplan'}[6]{$args{type}} eq 'T')           {$outputstring .= "        document.$form.cactionplan_selected.checked = isChecked;\n";}
        if ($items{'ccmrecommendation'}[6]{$args{type}} eq 'T')     {$outputstring .= "        document.$form.ccmrecommendation_selected.checked = isChecked;\n";}
        if ($items{'coldid'}[6]{$args{type}} eq 'T')                {$outputstring .= "        document.$form.coldid_selected.checked = isChecked;\n";}
        if ($items{'ccloseddate'}[6]{$args{type}} eq 'T')           {$outputstring .= "        document.$form.ccloseddate_selected.checked = isChecked;\n";}
        if ($items{'ccontrolaccountid'}[6]{$args{type}} eq 'T')     {$outputstring .= "        document.$form.ccontrolaccountid_selected.checked = isChecked;\n";}
        if ($items{'capprover'}[6]{$args{type}} eq 'T')             {$outputstring .= "        document.$form.capprover_selected.checked = isChecked;\n";}
        if ($items{'cupdatedby'}[6]{$args{type}} eq 'T')            {$outputstring .= "        document.$form.cupdatedby_selected.checked = isChecked;\n";}
        if ($items{'creplacedby'}[6]{$args{type}} eq 'T')           {$outputstring .= "        document.$form.creplacedby_selected.checked = isChecked;\n";}
        if ($items{'cstatusid'}[6]{$args{type}} eq 'T')             {$outputstring .= "        document.$form.cstatusid_selected.checked = isChecked;\n";}
        if ($items{'ccommitmentlevel'}[6]{$args{type}} eq 'T')      {$outputstring .= "        document.$form.ccommitmentlevel_selected.checked = isChecked;\n";}
        if ($items{'ckeyword'}[6]{$args{type}} eq 'T')              {$outputstring .= "        document.$form.ckeyword_selected.checked = isChecked;\n";}
        if ($items{'product'}[6]{$args{type}} eq 'T')               {$outputstring .= "        document.$form.product_selected.checked = isChecked;\n";}
        if ($items{'organization'}[6]{$args{type}} eq 'T')          {$outputstring .= "        document.$form.organization_selected.checked = isChecked;\n";}
        if ($items{'response'}[6]{$args{type}} eq 'T')              {$outputstring .= "        document.$form.response_selected.checked = isChecked;\n";}
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
        $outputstring .= "        document.$form.text_limit.checked = true;\n";
        if ($items{'issueid'}[6]{$args{type}} eq 'T') {
            $outputstring .= "        document.$form.issueid.value = '';\n";
        }
        #if ($items{'issite'}[6]{$args{type}} eq 'T') {
        #    $outputstring .= "        document.$form.issite.value = '';\n";
        #}
        if ($items{'sourcedoc'}[6]{$args{type}} eq 'T') {
            $outputstring .= "        document.$form.sourcedoc.value = '';\n";
            $outputstring .= "        document.$form.sddetails.checked = false;\n";
        }
        if ($items{'iscategory'}[6]{$args{type}} eq 'T') {
            $outputstring .= "for (index=document.$form.iscategory.length-2; index >= 0 ;index--) {\n";
            $outputstring .= "    document.$form.iscategory.options[index].selected = true;\n";
            $outputstring .= "    process_dual_select_option(document.$form.iscategory.options,document.$form.availiscategory.options,'move');\n";
            $outputstring .= "}\n";
        }
        if ($items{'iskeyword'}[6]{$args{type}} eq 'T') {
            $outputstring .= "for (index=document.$form.iskeyword.length-2; index >= 0 ;index--) {\n";
            $outputstring .= "    document.$form.iskeyword.options[index].selected = true;\n";
            $outputstring .= "    process_dual_select_option(document.$form.iskeyword.options,document.$form.availiskeyword.options,'move');\n";
            $outputstring .= "}\n";
            $outputstring .= "document.$form.iskeyword_boolean[0].checked = true;\n";
        }
        if ($items{'isenteredby'}[6]{$args{type}} eq 'T') {
            $outputstring .= "        set_selected_option(document.$form.isenteredby, 0);\n";
        }
        if ($items{'isentereddate'}[6]{$args{type}} eq 'T') {
            $outputstring .= "        set_selected_option(document.$form.isentereddate_start_month, 0);\n";
            $outputstring .= "        set_selected_option(document.$form.isentereddate_start_day, 0);\n";
            $outputstring .= "        document.$form.isentereddate_start_year.value = '';\n";
            $outputstring .= "        set_selected_option(document.$form.isentereddate_end_month, 0);\n";
            $outputstring .= "        set_selected_option(document.$form.isentereddate_end_day, 0);\n";
            $outputstring .= "        document.$form.isentereddate_end_year.value = '';\n";
        }
        if ($items{'commitmentid'}[6]{$args{type}} eq 'T') {
            $outputstring .= "        document.$form.commitmentid.value = '';\n";
        }
        if ($items{'controlaccountid'}[6]{$args{type}} eq 'T') {
            $outputstring .= "        set_selected_option(document.$form.controlaccountid, 0);\n";
        }
        #if ($items{'comsite'}[6]{$args{type}} eq 'T') {
        #    $outputstring .= "        document.$form.comsite.value = '';\n";
        #}
       # if ($items{'comrole'}[6]{$args{type}} eq 'T') {
       #     #$outputstring .= "        document.$form.comrole.value = '';\n";
       # }
        if ($items{'comduedate'}[6]{$args{type}} eq 'T') {
            $outputstring .= "        set_selected_option(document.$form.comduedate_start_month, 0);\n";
            $outputstring .= "        set_selected_option(document.$form.comduedate_start_day, 0);\n";
            $outputstring .= "        document.$form.comduedate_start_year.value = '';\n";
            $outputstring .= "        set_selected_option(document.$form.comduedate_end_month, 0);\n";
            $outputstring .= "        set_selected_option(document.$form.comduedate_end_day, 0);\n";
            $outputstring .= "        document.$form.comduedate_end_year.value = '';\n";
        }
        if ($items{'cfunctionaldisp'}[6]{$args{type}} eq 'T') {
            $outputstring .= "        set_selected_option(document.$form.cfunctionaldisp, 0);\n";
        }
        if ($items{'coldid'}[6]{$args{type}} eq 'T') {
            $outputstring .= "        document.$form.coldid.value = '';\n";
        }
        if ($items{'comduedate'}[6]{$args{type}} eq 'T') {
            $outputstring .= "        set_selected_option(document.$form.ccloseddate_start_month, 0);\n";
            $outputstring .= "        set_selected_option(document.$form.ccloseddate_start_day, 0);\n";
            $outputstring .= "        document.$form.ccloseddate_start_year.value = '';\n";
            $outputstring .= "        set_selected_option(document.$form.ccloseddate_end_month, 0);\n";
            $outputstring .= "        set_selected_option(document.$form.ccloseddate_end_day, 0);\n";
            $outputstring .= "        document.$form.ccloseddate_end_year.value = '';\n";
        }
        if ($items{'ccontrolaccountid'}[6]{$args{type}} eq 'T') {
            $outputstring .= "        document.$form.ccontrolaccountid.value = '';\n";
        }
        if ($items{'capprover'}[6]{$args{type}} eq 'T') {
            $outputstring .= "        set_selected_option(document.$form.capprover, 0);\n";
        }
        if ($items{'cupdatedby'}[6]{$args{type}} eq 'T') {
            $outputstring .= "        set_selected_option(document.$form.cupdatedby, 0);\n";
        }
        if ($items{'creplacedby'}[6]{$args{type}} eq 'T') {
            $outputstring .= "        document.$form.creplacedby.value = '';\n";
        }
        if ($items{'cstatusid'}[6]{$args{type}} eq 'T') {
            $outputstring .= "        document.$form.cstatusid.value = '';\n";
        }
        if ($items{'ccommitmentlevel'}[6]{$args{type}} eq 'T') {
            $outputstring .= "        document.$form.ccommitmentlevel.value = '';\n";
        }
        if ($items{'ckeyword'}[6]{$args{type}} eq 'T') {
            $outputstring .= "for (index=document.$form.ckeyword.length-2; index >= 0 ;index--) {\n";
            $outputstring .= "    document.$form.ckeyword.options[index].selected = true;\n";
            $outputstring .= "    process_dual_select_option(document.$form.ckeyword.options,document.$form.availckeyword.options,'move');\n";
            $outputstring .= "}\n";
            $outputstring .= "document.$form.ckeyword_boolean[0].checked = true;\n";
        }
        if ($items{'product'}[6]{$args{type}} eq 'T') {
            $outputstring .= "for (index=document.$form.product.length-2; index >= 0 ;index--) {\n";
            $outputstring .= "    document.$form.product.options[index].selected = true;\n";
            $outputstring .= "    process_dual_select_option(document.$form.product.options,document.$form.availproduct.options,'move');\n";
            $outputstring .= "}\n";
            $outputstring .= "document.$form.product_boolean[0].checked = true;\n";
        }
        if ($items{'organization'}[6]{$args{type}} eq 'T') {
            $outputstring .= "        document.$form.organization.value = '';\n";
            $outputstring .= "        document.$form.organization_details.checked = false;\n";
        }
        if ($items{'response'}[6]{$args{type}} eq 'T') {
            $outputstring .= "        document.$form.response_details.checked = false;\n";
        }


        $outputstring .= "    }\n";
        $outputstring .= "//--></script>\n";
    };
    if ($@) {
        $message = errorMessage($dbh,$username,$userid,'','',"creating an ad hoc selection page.",$@);
        $message =~ s/\n/\\n/g;
        $message =~ s/'/''/g;
        $outputstring .= "<script language=javascript><!--\n";
        $outputstring .= "    alert('$message');\n";
        $outputstring .= "//--></script>\n";
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
    my $reporttitle = ((defined($cirscgi->param('reporttitle'))) ? $cirscgi->param('reporttitle') : '');
    my $excludeTable = ((defined($cirscgi->param('excludetable'))) ? $cirscgi->param('excludetable') : "");

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

        $outputstring .= "\n\n<!-- Got Here 1 - $excludeTable -->\n\n";
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
                    if (index($tables{$key}[1][$key2],'date') >= 0 && index($tables{$key}[1][$key2],'update') < 0) {
                        $sqlquery_select .= "TO_CHAR($tables{$key}[3].$tables{$key}[1][$key2],$DateFormat), ";
                    } else {
                        $sqlquery_select .= "$tables{$key}[3].$tables{$key}[1][$key2], ";
                    }
                }
            }
        }
        chop($sqlquery_select);
        chop($sqlquery_select);
    }

    $outputstring .= "\n\n";
    foreach $key (keys %fields) {
        $outputstring .= "<!-- $key - $fields{$key} -->\n";
    }
    $outputstring .= "\n\n";

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
    if (defined($cirscgi->param('extra_where_info')) && $cirscgi->param('extra_where_info') gt '') { $hasSelections = 'T';}

#
##################
#

    if ($hasSelections eq 'T') {
        $sqlquery_where .= " AND (";
        #
        $count = 0;


        if ($items{'issueid'}[5] eq 'T') {
            $sqlquery_where .= "(iss.issueid = $items{'issueid'}[4]{'id'}";
            $sqlquery_where .= ")";
            $count++;
        }

        #if ($items{'issite'}[5] eq 'T') {
        #    if ($count > 0) {$sqlquery_where .= " $report_boolean";}
        #    $sqlquery_where .= "(iss.siteid = $items{'issite'}[4]{'id'}";
        #    $sqlquery_where .= ")";
        #    $count++;
        #}

        if ($items{'sourcedoc'}[5] eq 'T') {
            if ($count > 0) {$sqlquery_where .= " $report_boolean";}
            $sqlquery_where .= "(sd.accessionnum = '$items{'sourcedoc'}[4]{'id'}'";
            $sqlquery_where .= ")";
            $count++;
        }

        if ($items{'isenteredby'}[5] eq 'T') {
            if ($count > 0) {$sqlquery_where .= " $report_boolean";}
            $sqlquery_where .= "(iss.enteredby = $items{'isenteredby'}[4]{'id'}";
            $sqlquery_where .= ")";
            $count++;
        }

        if ($items{'iscategory'}[5] eq 'T') {
            if ($count > 0) {$sqlquery_where .= " $report_boolean";}
            $sqlquery_where .= " (iss.categoryid IN (";
            for ($key=0; $key <= $#{ $items{'iscategory'}[4]{'list'} }; $key++) {
                $sqlquery_where .= " $items{'iscategory'}[4]{'list'}[$key],";
            }
            $sqlquery_where .= " 0";
            $sqlquery_where .= ")";
            $sqlquery_where .= ")";
            $count++;
        }

        if ($items{'isentereddate'}[5] eq 'T') {
            if ($count > 0) {$sqlquery_where .= " $report_boolean";}
            $sqlquery_where .= " (TO_CHAR(iss.entereddate,'YYYY-MM-DD') BETWEEN '$items{'isentereddate'}[4]{'startdate'}' AND '$items{'isentereddate'}[4]{'enddate'}')";

            $count++;
        }

        if ($items{'cfunctionaldisp'}[5] eq 'T') {
            if ($count > 0) {$sqlquery_where .= " $report_boolean";}
            $sqlquery_where .= "(com.primarydiscipline = $items{'cfunctionaldisp'}[4]{'id'} OR com.secondarydiscipline = $items{'cfunctionaldisp'}[4]{'id'}";
            $sqlquery_where .= ")";
            $count++;
        }

        if ($items{'iskeyword'}[5] eq 'T' && $items{'iskeyword'}[4]{'boolean'} eq 'any') {
            if ($count > 0) {$sqlquery_where .= " $report_boolean";}
            $sqlquery_where .= " (iss.issueid IN (SELECT issueid FROM $schema.issuekeyword WHERE keywordid IN (";
            for ($key=0; $key <= $#{ $items{'iskeyword'}[4]{'list'} }; $key++) {
                $sqlquery_where .= " $items{'iskeyword'}[4]{'list'}[$key],";
            }
            $sqlquery_where .= " 0";
            $sqlquery_where .= "))";
            $sqlquery_where .= ")";
            $count++;
        }
        if ($items{'iskeyword'}[5] eq 'T' && $items{'iskeyword'}[4]{'boolean'} eq 'all') {
            if ($count > 0) {$sqlquery_where .= " $report_boolean";}
            $sqlquery_where .= " (";
            my $count2 = 0;
            for ($key=0; $key <= $#{ $items{'iskeyword'}[4]{'list'} }; $key++) {
                if ($count2 >= 1) {$sqlquery_where .= " AND";}
                $sqlquery_where .= " (iss.issueid IN (SELECT issueid FROM $schema.issuekeyword WHERE keywordid = $items{'iskeyword'}[4]{'list'}[$key]))";
                $count2++;
            }
            #$sqlquery_where .= ")))";
            $sqlquery_where .= ")";
            $count++;
        }

        if ($items{'commitmentid'}[5] eq 'T') {
            if ($count > 0) {$sqlquery_where .= " $report_boolean";}
            $sqlquery_where .= "(com.commitmentid = $items{'commitmentid'}[4]{'id'}";
            $sqlquery_where .= ")";
            $count++;
        }

        if ($items{'controlaccountid'}[5] eq 'T') {
            if ($count > 0) {$sqlquery_where .= " $report_boolean";}
            $sqlquery_where .= "(com.controlaccountid = '$items{'controlaccountid'}[4]{'id'}'";
            $sqlquery_where .= ")";
            $count++;
        }

        #if ($items{'comsite'}[5] eq 'T') {
        #    if ($count > 0) {$sqlquery_where .= " $report_boolean";}
        #    $sqlquery_where .= "(iss.siteid = $items{'comsite'}[4]{'id'}";
        #    $sqlquery_where .= ")";
        #    $count++;
        #}

        #if ($items{'comrole'}[5] eq 'T') {
        #    if ($count > 0) {$sqlquery_where .= " $report_boolean";}
        #    $items{'comrole'}[4]{'id'} =~ m%(\d+)-(\d+)-(.*)%;
        #    if ($3 eq 'issue') {
        #        $sqlquery_where .= "(com.commitmentid IN (SELECT issueid FROM $args{schema}.issuerole WHERE roleid = $1 AND usersid = $2)";
        #    } else {
        #        $sqlquery_where .= "(com.commitmentid IN (SELECT commitmentid FROM $args{schema}.commitmentrole WHERE roleid = $1 AND usersid = $2)";
        #    }
        #    $sqlquery_where .= ")";
        #    $count++;
        #}

        if ($items{'comduedate'}[5] eq 'T') {
            if ($count > 0) {$sqlquery_where .= " $report_boolean";}
            $sqlquery_where .= " (TO_CHAR(com.duedate,'YYYY-MM-DD') BETWEEN '$items{'comduedate'}[4]{'startdate'}' AND '$items{'comduedate'}[4]{'enddate'}')";

            $count++;
        }

        if ($items{'coldid'}[5] eq 'T') {
            if ($count > 0) {$sqlquery_where .= " $report_boolean";}
            $sqlquery_where .= "(com.oldid = '$items{'coldid'}[4]{'id'}'";
            $sqlquery_where .= ")";
            $count++;
        }


        if ($items{'ccloseddate'}[5] eq 'T') {
            if ($count > 0) {$sqlquery_where .= " $report_boolean";}
            $sqlquery_where .= " (TO_CHAR(com.closeddate,'YYYY-MM-DD') BETWEEN '$items{'ccloseddate'}[4]{'startdate'}' AND '$items{'ccloseddate'}[4]{'enddate'}')";

            $count++;
        }

        if ($items{'ccontrolaccountid'}[5] eq 'T') {
            if ($count > 0) {$sqlquery_where .= " $report_boolean";}
            $sqlquery_where .= "(com.controlaccountid = '$items{'ccontrolaccountid'}[4]{'id'}'";
            $sqlquery_where .= ")";
            $count++;
        }

        if ($items{'capprover'}[5] eq 'T') {
            if ($count > 0) {$sqlquery_where .= " $report_boolean";}
            $sqlquery_where .= "(com.approver = $items{'capprover'}[4]{'id'}";
            $sqlquery_where .= ")";
            $count++;
        }

        if ($items{'cupdatedby'}[5] eq 'T') {
            if ($count > 0) {$sqlquery_where .= " $report_boolean";}
            $sqlquery_where .= "(com.updatedby = $items{'cupdatedby'}[4]{'id'}";
            $sqlquery_where .= ")";
            $count++;
        }

        if ($items{'creplacedby'}[5] eq 'T') {
            if ($count > 0) {$sqlquery_where .= " $report_boolean";}
            $sqlquery_where .= "(com.replacedby = '$items{'creplacedby'}[4]{'id'}'";
            $sqlquery_where .= ")";
            $count++;
        }

        if ($items{'cstatusid'}[5] eq 'T') {
            if ($count > 0) {$sqlquery_where .= " $report_boolean";}
            $sqlquery_where .= "(com.statusid = '$items{'cstatusid'}[4]{'id'}'";
            $sqlquery_where .= ")";
            $count++;
        }

        if ($items{'ccommitmentlevel'}[5] eq 'T') {
            if ($count > 0) {$sqlquery_where .= " $report_boolean";}
            $sqlquery_where .= "(com.commitmentlevelid = $items{'ccommitmentlevel'}[4]{'id'}";
            $sqlquery_where .= ")";
            $count++;
        }

        if ($items{'ckeyword'}[5] eq 'T' && $items{'ckeyword'}[4]{'boolean'} eq 'any') {
            if ($count > 0) {$sqlquery_where .= " $report_boolean";}
            $sqlquery_where .= " (com.commitmentid IN (SELECT commitmentid FROM $schema.commitmentkeyword WHERE keywordid IN (";
            for ($key=0; $key <= $#{ $items{'ckeyword'}[4]{'list'} }; $key++) {
                $sqlquery_where .= " $items{'ckeyword'}[4]{'list'}[$key],";
            }
            $sqlquery_where .= " 0";
            $sqlquery_where .= "))";
            $sqlquery_where .= ")";
            $count++;
        }
        if ($items{'ckeyword'}[5] eq 'T' && $items{'ckeyword'}[4]{'boolean'} eq 'all') {
            if ($count > 0) {$sqlquery_where .= " $report_boolean";}
            $sqlquery_where .= " (";
            my $count2 = 0;
            for ($key=0; $key <= $#{ $items{'ckeyword'}[4]{'list'} }; $key++) {
                if ($count2 >= 1) {$sqlquery_where .= " AND";}
                $sqlquery_where .= " (com.commitmentid IN (SELECT commitmentid FROM $schema.commitmentkeyword WHERE keywordid = $items{'ckeyword'}[4]{'list'}[$key]))";
                $count2++;
            }
            #$sqlquery_where .= ")))";
            $sqlquery_where .= ")";
            $count++;
        }

        if ($items{'product'}[5] eq 'T' && $items{'product'}[4]{'boolean'} eq 'any') {
            if ($count > 0) {$sqlquery_where .= " $report_boolean";}
            $sqlquery_where .= " (com.commitmentid IN (SELECT commitmentid FROM $schema.productaffected WHERE productid IN (";
            for ($key=0; $key <= $#{ $items{'product'}[4]{'list'} }; $key++) {
                $sqlquery_where .= " $items{'product'}[4]{'list'}[$key],";
            }
            $sqlquery_where .= " 0";
            $sqlquery_where .= "))";
            $sqlquery_where .= ")";
            $count++;
        }
        if ($items{'product'}[5] eq 'T' && $items{'product'}[4]{'boolean'} eq 'all') {
            if ($count > 0) {$sqlquery_where .= " $report_boolean";}
            $sqlquery_where .= " (";
            my $count2 = 0;
            for ($key=0; $key <= $#{ $items{'product'}[4]{'list'} }; $key++) {
                if ($count2 >= 1) {$sqlquery_where .= " AND";}
                $sqlquery_where .= " (com.commitmentid IN (SELECT commitmentid FROM $schema.productaffected WHERE productid = $items{'product'}[4]{'list'}[$key]))";
                $count2++;
            }
            #$sqlquery_where .= ")))";
            $sqlquery_where .= ")";
            $count++;
        }

        if ($items{'organization'}[5] eq 'T') {
            if ($count > 0) {$sqlquery_where .= " $report_boolean";}
            $sqlquery_where .= "(com.commitmentid IN (SELECT commitmentid FROM $schema.committedorg WHERE organizationid = $items{'organization'}[4]{'id'}))";
            $count++;
        }



        if (defined($cirscgi->param('extra_where_info')) && $cirscgi->param('extra_where_info') gt '') {
            if ($count > 0) {$sqlquery_where .= " $report_boolean";}
            $sqlquery_where .= $cirscgi->param('extra_where_info');
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
                $outputstring .= [ $cirscgi->param('bincoordinator') ];
                $outputstring .= "\n";
                $outputstring .= "responsewriters: ";
                for ($key2=0; $key2 <= $#{ $items{'responsewriter'}[4]{'userlist'} }; $key2++) {$outputstring .= "$items{'responsewriter'}[4]{'userlist'}[$key2] ";}
                $outputstring .= "<**>\n";
            } else {

                $outputstring .= "<input type=hidden name='reporttitle' value=\"" . $reporttitle . "\">\n";
                $outputstring .= "<input type=hidden name='sortdirection' value='" . $cirscgi->param('sortdirection') . "'>\n";
                $outputstring .= "<input type=hidden name='report_boolean' value='" . $cirscgi->param('report_boolean') . "'>\n";
                $outputstring .= "<input type=hidden name='text_limit' value='" . ((defined($cirscgi->param('text_limit'))) ? $cirscgi->param('text_limit') : "F") . "'>\n";

                $outputstring .= "<input type=hidden name='sortorder' value='" . $cirscgi->param('sortorder') . "'>\n";

#
##################
#

                $outputstring .= "<input type=hidden name='issueid_selected' value='" . ((defined($cirscgi->param('issueid_selected'))) ? $cirscgi->param('issueid_selected') : "") . "'>\n";
                $outputstring .= "<input type=hidden name='issueid' value='" . ((defined($cirscgi->param('issueid'))) ? $cirscgi->param('issueid') : "") . "'>\n";

                #$outputstring .= "<input type=hidden name='issite_selected' value='" . ((defined($cirscgi->param('issite_selected'))) ? $cirscgi->param('issite_selected') : "") . "'>\n";
                #$outputstring .= "<input type=hidden name='issite' value='" . ((defined($cirscgi->param('issite'))) ? $cirscgi->param('issite') : "") . "'>\n";

                $outputstring .= "<input type=hidden name='istext_selected' value='" . ((defined($cirscgi->param('istext_selected'))) ? $cirscgi->param('istext_selected') : "") . "'>\n";

                $outputstring .= "<input type=hidden name='isentereddate_selected' value='" . ((defined($cirscgi->param('isentereddate_selected'))) ? $cirscgi->param('isentereddate_selected') : "") . "'>\n";
                $outputstring .= "<input type=hidden name='isentereddate_start' value='" . $items{'isentereddate'}[4]{'startdate'} . "'>\n";
                $outputstring .= "<input type=hidden name='isentereddate_end' value='" . $items{'isentereddate'}[4]{'enddate'} . "'>\n";

                $outputstring .= "<input type=hidden name='ispage_selected' value='" . ((defined($cirscgi->param('ispage_selected'))) ? $cirscgi->param('ispage_selected') : "") . "'>\n";

                $outputstring .= "<input type=hidden name='sourcedoc_selected' value='" . ((defined($cirscgi->param('sourcedoc_selected'))) ? $cirscgi->param('sourcedoc_selected') : "") . "'>\n";
                $outputstring .= "<input type=hidden name='sourcedoc' value='" . ((defined($cirscgi->param('sourcedoc'))) ? $cirscgi->param('sourcedoc') : "") . "'>\n";
                $outputstring .= "<input type=hidden name='sddetails' value='" . ((defined($cirscgi->param('sddetails'))) ? $cirscgi->param('sddetails') : "") . "'>\n";

                $outputstring .= "<input type=hidden name='iscategory_selected' value='" . ((defined($cirscgi->param('iscategory_selected'))) ? $cirscgi->param('iscategory_selected') : "") . "'>\n";
                $outputstring .= "<select multiple name='iscategory' size=5>\n";
                for $key (0 .. $#{ $items{'iscategory'}[4]{'list'} }) {
                    $outputstring .= "<option value='$items{'iscategory'}[4]{'list'}[$key]' selected>$items{'iscategory'}[4]{'list'}[$key]</option>\n";
                }
                $outputstring .= "</select>\n";

                $outputstring .= "<input type=hidden name='iskeyword_selected' value='" . ((defined($cirscgi->param('iskeyword_selected'))) ? $cirscgi->param('iskeyword_selected') : "") . "'>\n";
                $outputstring .= "<select multiple name='iskeyword' size=5>\n";
                for $key (0 .. $#{ $items{'iskeyword'}[4]{'list'} }) {
                    $outputstring .= "<option value='$items{'iskeyword'}[4]{'list'}[$key]' selected>$items{'iskeyword'}[4]{'list'}[$key]</option>\n";
                }
                $outputstring .= "</select>\n";
                $outputstring .= "<input type=hidden name='iskeyword_boolean' value='" . ((defined($cirscgi->param('iskeyword_boolean'))) ? $cirscgi->param('iskeyword_boolean') : "") . "'>\n";

                $outputstring .= "<input type=hidden name='isenteredby_selected' value='" . ((defined($cirscgi->param('isenteredby_selected'))) ? $cirscgi->param('isenteredby_selected') : "") . "'>\n";
                $outputstring .= "<input type=hidden name='isenteredby' value='" . ((defined($cirscgi->param('isenteredby'))) ? $cirscgi->param('isenteredby') : "") . "'>\n";

                $outputstring .= "<input type=hidden name='commitmentid_selected' value='" . ((defined($cirscgi->param('commitmentid_selected'))) ? $cirscgi->param('commitmentid_selected') : "") . "'>\n";
                $outputstring .= "<input type=hidden name='commitmentid' value='" . ((defined($cirscgi->param('commitmentid'))) ? $cirscgi->param('commitmentid') : "") . "'>\n";

                $outputstring .= "<input type=hidden name='controlaccountid_selected' value='" . ((defined($cirscgi->param('controlaccountid_selected'))) ? $cirscgi->param('controlaccountid_selected') : "") . "'>\n";
                $outputstring .= "<input type=hidden name='controlaccountid' value='" . ((defined($cirscgi->param('controlaccountid'))) ? $cirscgi->param('controlaccountid') : "") . "'>\n";

                #$outputstring .= "<input type=hidden name='comsite_selected' value='" . ((defined($cirscgi->param('comsite_selected'))) ? $cirscgi->param('comsite_selected') : "") . "'>\n";
                #$outputstring .= "<input type=hidden name='comsite' value='" . ((defined($cirscgi->param('comsite'))) ? $cirscgi->param('comsite') : "") . "'>\n";

                #$outputstring .= "<input type=hidden name='comrole_selected' value='" . ((defined($cirscgi->param('comrole_selected'))) ? $cirscgi->param('comrole_selected') : "") . "'>\n";
                #$outputstring .= "<input type=hidden name='comrole' value='" . ((defined($cirscgi->param('comrole'))) ? $cirscgi->param('comrole') : "") . "'>\n";

                $outputstring .= "<input type=hidden name='comduedate_selected' value='" . ((defined($cirscgi->param('comduedate_selected'))) ? $cirscgi->param('comduedate_selected') : "") . "'>\n";
                $outputstring .= "<input type=hidden name='comduedate_start' value='" . $items{'comduedate'}[4]{'startdate'} . "'>\n";
                $outputstring .= "<input type=hidden name='comduedate_end' value='" . $items{'comduedate'}[4]{'enddate'} . "'>\n";

                $outputstring .= "<input type=hidden name='cfunctionaldisp_selected' value='" . ((defined($cirscgi->param('cfunctionaldisp_selected'))) ? $cirscgi->param('cfunctionaldisp_selected') : "") . "'>\n";
                $outputstring .= "<input type=hidden name='cfunctionaldisp' value='" . ((defined($cirscgi->param('cfunctionaldisp'))) ? $cirscgi->param('cfunctionaldisp') : "") . "'>\n";

                $outputstring .= "<input type=hidden name='cestimate_selected' value='" . ((defined($cirscgi->param('cestimate_selected'))) ? $cirscgi->param('cestimate_selected') : "") . "'>\n";

                $outputstring .= "<input type=hidden name='cfunctionalrec_selected' value='" . ((defined($cirscgi->param('cfunctionalrec_selected'))) ? $cirscgi->param('cfunctionalrec_selected') : "") . "'>\n";

                $outputstring .= "<input type=hidden name='ccommitrationale_selected' value='" . ((defined($cirscgi->param('ccommitrationale_selected'))) ? $cirscgi->param('ccommitrationale_selected') : "") . "'>\n";

                $outputstring .= "<input type=hidden name='capprovalrationale_selected' value='" . ((defined($cirscgi->param('capprovalrationale_selected'))) ? $cirscgi->param('capprovalrationale_selected') : "") . "'>\n";

                $outputstring .= "<input type=hidden name='ctext_selected' value='" . ((defined($cirscgi->param('ctext_selected'))) ? $cirscgi->param('ctext_selected') : "") . "'>\n";

                $outputstring .= "<input type=hidden name='ccomments_selected' value='" . ((defined($cirscgi->param('ccomments_selected'))) ? $cirscgi->param('ccomments_selected') : "") . "'>\n";

                $outputstring .= "<input type=hidden name='crejectrationale_selected' value='" . ((defined($cirscgi->param('crejectrationale_selected'))) ? $cirscgi->param('crejectrationale_selected') : "") . "'>\n";

                $outputstring .= "<input type=hidden name='cresubrationale_selected' value='" . ((defined($cirscgi->param('cresubrationale_selected'))) ? $cirscgi->param('cresubrationale_selected') : "") . "'>\n";

                $outputstring .= "<input type=hidden name='cactionstaken_selected' value='" . ((defined($cirscgi->param('cactionstaken_selected'))) ? $cirscgi->param('cactionstaken_selected') : "") . "'>\n";

                $outputstring .= "<input type=hidden name='cactionsummary_selected' value='" . ((defined($cirscgi->param('cactionsummary_selected'))) ? $cirscgi->param('cactionsummary_selected') : "") . "'>\n";

                $outputstring .= "<input type=hidden name='cactionplan_selected' value='" . ((defined($cirscgi->param('cactionplan_selected'))) ? $cirscgi->param('cactionplan_selected') : "") . "'>\n";

                $outputstring .= "<input type=hidden name='ccmrecommendation_selected' value='" . ((defined($cirscgi->param('ccmrecommendation_selected'))) ? $cirscgi->param('ccmrecommendation_selected') : "") . "'>\n";

                $outputstring .= "<input type=hidden name='coldid_selected' value='" . ((defined($cirscgi->param('coldid_selected'))) ? $cirscgi->param('coldid_selected') : "") . "'>\n";
                $outputstring .= "<input type=hidden name='coldid' value='" . ((defined($cirscgi->param('coldid'))) ? $cirscgi->param('coldid') : "") . "'>\n";

                $outputstring .= "<input type=hidden name='ccloseddate_selected' value='" . ((defined($cirscgi->param('ccloseddate_selected'))) ? $cirscgi->param('ccloseddate_selected') : "") . "'>\n";
                $outputstring .= "<input type=hidden name='ccloseddate_start' value='" . $items{'ccloseddate'}[4]{'startdate'} . "'>\n";
                $outputstring .= "<input type=hidden name='ccloseddate_end' value='" . $items{'ccloseddate'}[4]{'enddate'} . "'>\n";

                $outputstring .= "<input type=hidden name='ccontrolaccountid_selected' value='" . ((defined($cirscgi->param('ccontrolaccountid_selected'))) ? $cirscgi->param('ccontrolaccountid_selected') : "") . "'>\n";
                $outputstring .= "<input type=hidden name='ccontrolaccountid' value='" . ((defined($cirscgi->param('ccontrolaccountid'))) ? $cirscgi->param('ccontrolaccountid') : "") . "'>\n";

                $outputstring .= "<input type=hidden name='capprover_selected' value='" . ((defined($cirscgi->param('capprover_selected'))) ? $cirscgi->param('capprover_selected') : "") . "'>\n";
                $outputstring .= "<input type=hidden name='capprover' value='" . ((defined($cirscgi->param('capprover'))) ? $cirscgi->param('capprover') : "") . "'>\n";

                $outputstring .= "<input type=hidden name='cupdatedby_selected' value='" . ((defined($cirscgi->param('cupdatedby_selected'))) ? $cirscgi->param('cupdatedby_selected') : "") . "'>\n";
                $outputstring .= "<input type=hidden name='cupdatedby' value='" . ((defined($cirscgi->param('cupdatedby'))) ? $cirscgi->param('cupdatedby') : "") . "'>\n";

                $outputstring .= "<input type=hidden name='creplacedby_selected' value='" . ((defined($cirscgi->param('creplacedby_selected'))) ? $cirscgi->param('creplacedby_selected') : "") . "'>\n";
                $outputstring .= "<input type=hidden name='creplacedby' value='" . ((defined($cirscgi->param('creplacedby'))) ? $cirscgi->param('creplacedby') : "") . "'>\n";

                $outputstring .= "<input type=hidden name='cstatusid_selected' value='" . ((defined($cirscgi->param('cstatusid_selected'))) ? $cirscgi->param('cstatusid_selected') : "") . "'>\n";
                $outputstring .= "<input type=hidden name='cstatusid' value='" . ((defined($cirscgi->param('cstatusid'))) ? $cirscgi->param('cstatusid') : "") . "'>\n";

                $outputstring .= "<input type=hidden name='ccommitmentlevel_selected' value='" . ((defined($cirscgi->param('ccommitmentlevel_selected'))) ? $cirscgi->param('ccommitmentlevel_selected') : "") . "'>\n";
                $outputstring .= "<input type=hidden name='ccommitmentlevel' value='" . ((defined($cirscgi->param('ccommitmentlevel'))) ? $cirscgi->param('ccommitmentlevel') : "") . "'>\n";

                $outputstring .= "<input type=hidden name='ckeyword_selected' value='" . ((defined($cirscgi->param('ckeyword_selected'))) ? $cirscgi->param('ckeyword_selected') : "") . "'>\n";
                $outputstring .= "<select multiple name='ckeyword' size=5>\n";
                for $key (0 .. $#{ $items{'ckeyword'}[4]{'list'} }) {
                    $outputstring .= "<option value='$items{'ckeyword'}[4]{'list'}[$key]' selected>$items{'ckeyword'}[4]{'list'}[$key]</option>\n";
                }
                $outputstring .= "</select>\n";
                $outputstring .= "<input type=hidden name='ckeyword_boolean' value='" . ((defined($cirscgi->param('ckeyword_boolean'))) ? $cirscgi->param('ckeyword_boolean') : "") . "'>\n";

                $outputstring .= "<input type=hidden name='product_selected' value='" . ((defined($cirscgi->param('product_selected'))) ? $cirscgi->param('product_selected') : "") . "'>\n";
                $outputstring .= "<select multiple name='product' size=5>\n";
                for $key (0 .. $#{ $items{'product'}[4]{'list'} }) {
                    $outputstring .= "<option value='$items{'product'}[4]{'list'}[$key]' selected>$items{'product'}[4]{'list'}[$key]</option>\n";
                }
                $outputstring .= "</select>\n";
                $outputstring .= "<input type=hidden name='product_boolean' value='" . ((defined($cirscgi->param('product_boolean'))) ? $cirscgi->param('product_boolean') : "") . "'>\n";

                $outputstring .= "<input type=hidden name='organization_selected' value='" . ((defined($cirscgi->param('organization_selected'))) ? $cirscgi->param('organization_selected') : "") . "'>\n";
                $outputstring .= "<input type=hidden name='organization' value='" . ((defined($cirscgi->param('organization'))) ? $cirscgi->param('organization') : "") . "'>\n";
                $outputstring .= "<input type=hidden name='organization_details' value='" . ((defined($cirscgi->param('organization_details'))) ? $cirscgi->param('organization_details') : "") . "'>\n";

                $outputstring .= "<input type=hidden name='response_selected' value='" . ((defined($cirscgi->param('response_selected'))) ? $cirscgi->param('response_selected') : "") . "'>\n";
                $outputstring .= "<input type=hidden name='response_details' value='" . ((defined($cirscgi->param('response_details'))) ? $cirscgi->param('response_details') : "") . "'>\n";

                #$outputstring .= "<input type=hidden name='_selected' value='" . ((defined($cirscgi->param('_selected'))) ? $cirscgi->param('_selected') : "") . "'>\n";



                $outputstring .= "<input type=hidden name='extra_where_info' value=\"" . ((defined($cirscgi->param('extra_where_info'))) ? $cirscgi->param('extra_where_info') : "") . "\">\n";

                $outputstring .= "<input type=hidden name='excludetable' value=\"" . ((defined($cirscgi->param('excludetable'))) ? $cirscgi->param('excludetable') : "") . "\">\n";

                $outputstring .= "<script language=javascript><!--\n";
                $outputstring .= "    if (confirm('Found $values[0] record" . (($values[0] != 1) ? "s" : "") . ".\\nDo you wish to continue?')) {\n";
                $outputstring .= "        submitFormNewWindow('$form', 'adhocreport');\n";
                $outputstring .= "    };\n";
                $outputstring .= "//-->\n";
                $outputstring .= "</script>\n";
                $outputstring .= "<br>\n\n$sqlquery\n\n<br>\n";
            }
        }
        if ($command eq 'adhocreport') {

            #
$outputstring .= "\n\n<!-- $sqlquery -->\n\n";
            $csr = $args{'dbh'}->prepare($sqlquery);
            $status = $csr->execute;
            $count = 0;
            $outputstring .= "<script language=javascript><!--\n";
            $outputstring .= "    document.title=\"" . htmlStrip($cirscgi->param('reporttitle')) . "\";\n";
            $outputstring .= "//--></script>\n";
            $outputstring .= "<table border=0 width=670><tr><td><font size=-1>\n";
            $outputstring .= "<center><font size=+2>" . $cirscgi->param('reporttitle') . "</font><br>\n";
            $outputstring .= "$args{'run_date'}</center>\n";
            while (@values = $csr->fetchrow_array) {
                $count++;
                $itemcount=0;
                $outputstring .= "<br><hr>\n";

#
##################
#

                if ($items{'issueid'}[0] eq 'T') {
                    $outputstring .= "Issue ID: $values[$fields{'iss_issueid'}]<br>\n";
                }

                #if ($items{'issite'}[0] eq 'T' && defined($values[$fields{'iss_siteid'}])) {
                #    $outputstring .= "Issue Site: " . get_value($args{dbh},$args{schema},'site','name',"siteid = $values[$fields{'iss_siteid'}]") . "<br>\n";
                #}

                if ($items{'iscategory'}[0] eq 'T' && defined($values[$fields{'cat_description'}])) {
                    $outputstring .= "Category: $values[$fields{'cat_description'}]<br>\n";
                }

                if ($items{'isenteredby'}[0] eq 'T' && defined($values[$fields{'iss_enteredby'}])) {
                    $outputstring .= "Entered By: " . get_fullname($dbh,$schema,$values[$fields{'iss_enteredby'}]) . "<br>\n";
                }

                if ($items{'isentereddate'}[0] eq 'T' && defined($values[$fields{'iss_entereddate'}])) {
                    $outputstring .= "Entry Date: $values[$fields{'iss_entereddate'}]<br>\n";
                }

                if ($items{'ispage'}[0] eq 'T' && defined($values[$fields{'iss_page'}])) {
                    $outputstring .= "Issue Page Number: $values[$fields{'iss_page'}]<br>\n";
                }

                if ($items{'iskeyword'}[0] eq 'T') {
                    %lookup_values = get_lookup_values($args{'dbh'},'keyword','keywordid',"description", "keywordid IN (SELECT keywordid FROM $schema.issuekeyword WHERE issueid=$values[$fields{'iss_issueid'}]) ORDER BY description");
                    my $keywordcount = 0;
                    foreach my $key (values %lookup_values) {
                        if ($keywordcount == 0) {
                            $outputstring .= "Issue Keywords:<br>\n";
                        }
                        $keywordcount++;
                        $outputstring .= nbspaces(5) . "$key<br>\n";
                    }
                }

                if ($items{'sourcedoc'}[0] eq 'T' && defined($values[$fields{'sd_accessionnum'}])) {
                    $outputstring .= "<br>Source Document\n";
                    if (defined ($items{'sourcedoc'}[4]{'details'}) && $items{'sourcedoc'}[4]{'details'} eq 'T') {
                        $outputstring .= "<br>\n";
                        $outputstring .= nbspaces(5) . "Accession Number: $values[$fields{'sd_accessionnum'}]<br>\n";
                        $outputstring .= "<table border=0 width=100% cellpadding=0 cellspacing=0><tr><td valign=top><font size=-1>" . nbspaces(5) . "Title: &nbsp; </font></td><td><font size=-1>\n";
                        if ($args{'text_limit'} eq 'T') {
                            $outputstring .= getDisplayString($values[$fields{'sd_title'}], 80);
                        } else {
                            $outputstring .= breakUpLongWords($values[$fields{'sd_title'}],80);
                        }
                        $outputstring .= "</font></td></tr></table>\n";
                        $outputstring .= nbspaces(5) . "Date: $values[$fields{'sd_documentdate'}]" . nbspaces(10) . "Signer: $values[$fields{'sd_signer'}]<br>\n";
                    } else {
                        $outputstring .= " Accession Number: $values[$fields{'sd_accessionnum'}]<br>\n";
                    }
                }

                if ($items{'istext'}[0] eq 'T' && defined($values[$fields{'iss_text'}])) {
                    if ($args{'text_limit'} eq 'T') {
                        $outputstring .= "<br><u>Issue:</u><br>" . getDisplayString($values[$fields{'iss_text'}], 115) . "<br>\n";
                    } else {
                        $values[$fields{'iss_text'}] =~ s/\n/<br>/g;
                        $values[$fields{'iss_text'}] =~ s/  /&nbsp;&nbsp;/g;
                        $outputstring .= "<br><table border=0 width=100% cellpadding=0 cellspacing=0><tr><td><font size=-1><u>Issue:</u><br>" . breakUpLongWords($values[$fields{'iss_text'}],80) . "</font></td></tr></table>\n";
                    }
                }

                if ($items{'commitmentid'}[0] eq 'T') {
                    if (defined($values[$fields{'com_commitmentid'}])) {
                        $outputstring .= "<br>Commitment ID: $values[$fields{'com_commitmentid'}]<br>\n";
                    }
                }

                if ($items{'controlaccountid'}[0] eq 'T') {
                    if (defined($values[$fields{'com_controlaccountid'}])) {
                        $outputstring .= "<br>Work Breakdown Structure: $values[$fields{'com_controlaccountid'}]<br>\n";
                    }
                }

                #if ($items{'comsite'}[0] eq 'T' && defined($values[$fields{'com_siteid'}])) {
                #    $outputstring .= "Commitment Site: " . get_value($args{dbh},$args{schema},'site','name',"siteid = $values[$fields{'com_siteid'}]") . "<br>\n";
                #}

                #if ($items{'comrole'}[0] eq 'T' && defined($values[$fields{'com_commitmentid'}])) {
                #    my $sqlqueryrole = "SELECT cr.roleid,cr.usersid, r.description descr FROM $args{schema}.commitmentrole cr, $args{schema}.role r ";
                #    $sqlqueryrole .= "WHERE (cr.roleid = r.roleid) AND cr.commitmentid = $values[$fields{'com_commitmentid'}] ";
                #    $sqlqueryrole .= "UNION SELECT ir.roleid,ir.usersid, r.description descr FROM $args{schema}.issuerole ir, $args{schema}.role r ";
                #    $sqlqueryrole .= "WHERE (ir.roleid = r.roleid) AND ir.issueid = $values[$fields{'iss_issueid'}] ";
                #    my @rolevalues;
                #    @rolevalues = $dbh->selectrow_array("SELECT count(*) FROM ($sqlqueryrole)");
                #    if ($rolevalues[0] >= 1) {
                #        $outputstring .= "<br>Commitment Roles: <br>\n";
                #        $outputstring .= "<table border=0 cellpadding=0 cellspacing=0>\n";
                #        $sqlqueryrole .= " ORDER BY descr";
                #        my $rolecsr = $args{dbh}->prepare($sqlqueryrole);
                #        $rolecsr->execute;
                #        while (@rolevalues = $rolecsr->fetchrow_array) {
                #            $outputstring .= "<tr><td>" . nbspaces(5) . "</td><td><font size=-1>$rolevalues[2] &nbsp; </font></td><td>&nbsp; - &nbsp;</td>";
                #            $outputstring .= "<td><font size=-1>" . get_fullname($args{dbh},$args{schema},$rolevalues[1]) . "</font></td></tr>\n";
                #        }
                #        $rolecsr->finish;
                #        $outputstring .= "</table><br>\n";
                #    }
                #}

                if ($items{'comduedate'}[0] eq 'T' && defined($values[$fields{'com_duedate'}])) {
                    $outputstring .= "Date Due to Commitment Maker: $values[$fields{'com_duedate'}]<br>\n";
                }

                if ($items{'cfunctionaldisp'}[0] eq 'T' && (defined($values[$fields{'com_primarydiscipline'}]) || defined($values[$fields{'com_secondarydiscipline'}]))) {
                    $outputstring .= "<br>Technical Disipline:<br>\n";
                    $outputstring .= "<table border=0 cellpadding=0 cellspacing=0>\n";
                    if (defined($values[$fields{'com_primarydiscipline'}])) {$outputstring .= "<tr><td>" . nbspaces(5) . "</td><td><font size=-1>Primary: </font></td><td><font size=-1>" . get_value($args{dbh},$args{schema},'discipline','description',"disciplineid = $values[$fields{'com_primarydiscipline'}]") . "</font></td></tr>\n";}
                    if (defined($values[$fields{'com_secondarydiscipline'}])) {$outputstring .= "<tr><td>" . nbspaces(5) . "</td><td><font size=-1>Secondary: &nbsp; </font></td><td><font size=-1>" . get_value($args{dbh},$args{schema},'discipline','description',"disciplineid = $values[$fields{'com_secondarydiscipline'}]") . "</font></td></tr>\n";}
                    $outputstring .= "</table>\n";
                }

                if ($items{'cestimate'}[0] eq 'T' && defined($values[$fields{'com_estimate'}])) {
                    if ($args{'text_limit'} eq 'T') {
                        $outputstring .= "<br><u>Estimate:</u><br>" . getDisplayString($values[$fields{'com_estimate'}], 115) . "<br>\n";
                    } else {
                        $values[$fields{'com_estimate'}] =~ s/\n/<br>/g;
                        $values[$fields{'com_estimate'}] =~ s/  /&nbsp;&nbsp;/g;
                        $outputstring .= "<br><table border=0 width=100% cellpadding=0 cellspacing=0><tr><td><font size=-1><u>Estimate:</u><br>" . breakUpLongWords($values[$fields{'com_estimate'}],80) . "</font></td></tr></table>\n";
                    }
                }

                if ($items{'cfunctionalrec'}[0] eq 'T' && defined($values[$fields{'com_functionalrecommend'}])) {
                    if ($args{'text_limit'} eq 'T') {
                        $outputstring .= "<br><u>DOE Discipline Lead Recommend:</u><br>" . getDisplayString($values[$fields{'com_functionalrecommend'}], 115) . "<br>\n";
                    } else {
                        $values[$fields{'com_functionalrecommend'}] =~ s/\n/<br>/g;
                        $values[$fields{'com_functionalrecommend'}] =~ s/  /&nbsp;&nbsp;/g;
                        $outputstring .= "<br><table border=0 width=100% cellpadding=0 cellspacing=0><tr><td><font size=-1><u>Technical Recommend:</u><br>" . breakUpLongWords($values[$fields{'com_functionalrecommend'}],80) . "</font></td></tr></table>\n";
                    }
                }

                if ($items{'ccommitrationale'}[0] eq 'T' && defined($values[$fields{'com_commitmentrationale'}])) {
                    if ($args{'text_limit'} eq 'T') {
                        $outputstring .= "<br><u>Commitment Rationale:</u><br>" . getDisplayString($values[$fields{'com_commitmentrationale'}], 115) . "<br>\n";
                    } else {
                        $values[$fields{'com_commitmentrationale'}] =~ s/\n/<br>/g;
                        $values[$fields{'com_commitmentrationale'}] =~ s/  /&nbsp;&nbsp;/g;
                        $outputstring .= "<br><table border=0 width=100% cellpadding=0 cellspacing=0><tr><td><font size=-1><u>Commitment Rationale:</u><br>" . breakUpLongWords($values[$fields{'com_commitmentrationale'}],80) . "</font></td></tr></table>\n";
                    }
                }

                if ($items{'capprovalrationale'}[0] eq 'T' && defined($values[$fields{'com_approvalrationale'}])) {
                    if ($args{'text_limit'} eq 'T') {
                        $outputstring .= "<br><u>Approval Rationale:</u><br>" . getDisplayString($values[$fields{'com_approvalrationale'}], 115) . "<br>\n";
                    } else {
                        $values[$fields{'com_approvalrationale'}] =~ s/\n/<br>/g;
                        $values[$fields{'com_approvalrationale'}] =~ s/  /&nbsp;&nbsp;/g;
                        $outputstring .= "<br><table border=0 width=100% cellpadding=0 cellspacing=0><tr><td><font size=-1><u>Approval Rationale:</u><br>" . breakUpLongWords($values[$fields{'com_approvalrationale'}],80) . "</font></td></tr></table>\n";
                    }
                }

                if ($items{'ctext'}[0] eq 'T' && defined($values[$fields{'com_text'}])) {
                    if ($args{'text_limit'} eq 'T') {
                        $outputstring .= "<br><u>Commitment Text:</u><br>" . getDisplayString($values[$fields{'com_text'}], 115) . "<br>\n";
                    } else {
                        $values[$fields{'com_text'}] =~ s/\n/<br>/g;
                        $values[$fields{'com_text'}] =~ s/  /&nbsp;&nbsp;/g;
                        $outputstring .= "<br><table border=0 width=100% cellpadding=0 cellspacing=0><tr><td><font size=-1><u>Commitment Text:</u><br>" . breakUpLongWords($values[$fields{'com_text'}],80) . "</font></td></tr></table>\n";
                    }
                }

                if ($items{'ccomments'}[0] eq 'T' && defined($values[$fields{'com_comments'}])) {
                    if ($args{'text_limit'} eq 'T') {
                        $outputstring .= "<br><u>Commitment Remarks:</u><br>" . getDisplayString($values[$fields{'com_comments'}], 115) . "<br>\n";
                    } else {
                        $values[$fields{'com_comments'}] =~ s/\n/<br>/g;
                        $values[$fields{'com_comments'}] =~ s/  /&nbsp;&nbsp;/g;
                        $outputstring .= "<br><table border=0 width=100% cellpadding=0 cellspacing=0><tr><td><font size=-1><u>Commitment Remarks:</u><br>" . breakUpLongWords($values[$fields{'com_comments'}],80) . "</font></td></tr></table>\n";
                    }
                }

                if ($items{'crejectrationale'}[0] eq 'T' && defined($values[$fields{'com_rejectionrationale'}])) {
                    if ($args{'text_limit'} eq 'T') {
                        $outputstring .= "<br><u>Rejection Rationale:</u><br>" . getDisplayString($values[$fields{'com_rejectionrationale'}], 115) . "<br>\n";
                    } else {
                        $values[$fields{'com_rejectionrationale'}] =~ s/\n/<br>/g;
                        $values[$fields{'com_rejectionrationale'}] =~ s/  /&nbsp;&nbsp;/g;
                        $outputstring .= "<br><table border=0 width=100% cellpadding=0 cellspacing=0><tr><td><font size=-1><u>Rejection Rationale:</u><br>" . breakUpLongWords($values[$fields{'com_rejectionrationale'}],80) . "</font></td></tr></table>\n";
                    }
                }

                if ($items{'cresubrationale'}[0] eq 'T' && defined($values[$fields{'com_resubmitrationale'}])) {
                    if ($args{'text_limit'} eq 'T') {
                        $outputstring .= "<br><u>Resubmit Rationale:</u><br>" . getDisplayString($values[$fields{'com_resubmitrationale'}], 115) . "<br>\n";
                    } else {
                        $values[$fields{'com_resubmitrationale'}] =~ s/\n/<br>/g;
                        $values[$fields{'com_resubmitrationale'}] =~ s/  /&nbsp;&nbsp;/g;
                        $outputstring .= "<br><table border=0 width=100% cellpadding=0 cellspacing=0><tr><td><font size=-1><u>Rejection Rationale:</u><br>" . breakUpLongWords($values[$fields{'com_resubmitrationale'}],80) . "</font></td></tr></table>\n";
                    }
                }

                if ($items{'cactionstaken'}[0] eq 'T' && defined($values[$fields{'com_actionstaken'}])) {
                    if ($args{'text_limit'} eq 'T') {
                        $outputstring .= "<br><u>Actions Taken:</u><br>" . getDisplayString($values[$fields{'com_actionstaken'}], 115) . "<br>\n";
                    } else {
                        $values[$fields{'com_actionstaken'}] =~ s/\n/<br>/g;
                        $values[$fields{'com_actionstaken'}] =~ s/  /&nbsp;&nbsp;/g;
                        $outputstring .= "<br><table border=0 width=100% cellpadding=0 cellspacing=0><tr><td><font size=-1><u>Actions Taken:</u><br>" . breakUpLongWords($values[$fields{'com_actionstaken'}],80) . "</font></td></tr></table>\n";
                    }
                }

                if ($items{'cactionsummary'}[0] eq 'T' && defined($values[$fields{'com_actionsummary'}])) {
                    if ($args{'text_limit'} eq 'T') {
                        $outputstring .= "<br><u>Actions Summary:</u><br>" . getDisplayString($values[$fields{'com_actionsummary'}], 115) . "<br>\n";
                    } else {
                        $values[$fields{'com_actionsummary'}] =~ s/\n/<br>/g;
                        $values[$fields{'com_actionsummary'}] =~ s/  /&nbsp;&nbsp;/g;
                        $outputstring .= "<br><table border=0 width=100% cellpadding=0 cellspacing=0><tr><td><font size=-1><u>Actions Summary:</u><br>" . breakUpLongWords($values[$fields{'com_actionsummary'}],80) . "</font></td></tr></table>\n";
                    }
                }

                if ($items{'cactionplan'}[0] eq 'T' && defined($values[$fields{'com_actionplan'}])) {
                    if ($args{'text_limit'} eq 'T') {
                        $outputstring .= "<br><u>Action Plan:</u><br>" . getDisplayString($values[$fields{'com_actionplan'}], 115) . "<br>\n";
                    } else {
                        $values[$fields{'com_actionplan'}] =~ s/\n/<br>/g;
                        $values[$fields{'com_actionplan'}] =~ s/  /&nbsp;&nbsp;/g;
                        $outputstring .= "<br><table border=0 width=100% cellpadding=0 cellspacing=0><tr><td><font size=-1><u>Action Plan:</u><br>" . breakUpLongWords($values[$fields{'com_actionplan'}],80) . "</font></td></tr></table>\n";
                    }
                }

                if ($items{'ccmrecommendation'}[0] eq 'T' && defined($values[$fields{'com_cmrecommendation'}])) {
                    if ($args{'text_limit'} eq 'T') {
                        $outputstring .= "<br><u>CM Recomendation:</u><br>" . getDisplayString($values[$fields{'com_cmrecommendation'}], 115) . "<br>\n";
                    } else {
                        $values[$fields{'com_cmrecommendation'}] =~ s/\n/<br>/g;
                        $values[$fields{'com_cmrecommendation'}] =~ s/  /&nbsp;&nbsp;/g;
                        $outputstring .= "<br><table border=0 width=100% cellpadding=0 cellspacing=0><tr><td><font size=-1><u>CM Recomendation:</u><br>" . breakUpLongWords($values[$fields{'com_cmrecommendation'}],80) . "</font></td></tr></table>\n";
                    }
                    $outputstring .= "<br>\n";
                }

                if ($items{'coldid'}[0] eq 'T') {
                    if (defined($values[$fields{'com_oldid'}])) {
                        $outputstring .= "Old Commitment ID: $values[$fields{'com_oldid'}]<br>\n";
                    }
                }

                if ($items{'ccloseddate'}[0] eq 'T' && defined($values[$fields{'com_closeddate'}])) {
                    $outputstring .= "Closed Date: $values[$fields{'com_closeddate'}]<br>\n";
                }

                if ($items{'ccontrolaccountid'}[0] eq 'T') {
                    if (defined($values[$fields{'com_controlaccountid'}])) {
                        $outputstring .= "Accession #: $values[$fields{'com_controlaccountid'}]<br>\n";
                    }
                }

                if ($items{'capprover'}[0] eq 'T' && defined($values[$fields{'com_approver'}])) {
                    $outputstring .= "Commitment Maker: " . get_fullname($dbh,$schema,$values[$fields{'com_approver'}]) . "<br>\n";
                }

                if ($items{'cupdatedby'}[0] eq 'T' && defined($values[$fields{'com_updatedby'}])) {
                    $outputstring .= "Commitment Updated By: " . get_fullname($dbh,$schema,$values[$fields{'com_updatedby'}]) . "<br>\n";
                }

                if ($items{'creplacedby'}[0] eq 'T') {
                    if (defined($values[$fields{'com_replacedby'}])) {
                        $outputstring .= "Commitment Replaced By ID: $values[$fields{'com_replacedby'}]<br>\n";
                    }
                }

                if ($items{'cstatusid'}[0] eq 'T') {
                    if (defined($values[$fields{'com_statusid'}])) {
                        $outputstring .= "Commitment Status: $values[$fields{'st_description'}]<br>\n";
                    }
                }

                if ($items{'ccommitmentlevel'}[0] eq 'T') {
                    if (defined($values[$fields{'com_commitmentlevelid'}])) {
                        $outputstring .= "Commitment Level: $values[$fields{'cl_description'}]<br>\n";
                    }
                }

                if ($items{'ckeyword'}[0] eq 'T' && defined($values[$fields{'com_commitmentid'}])) {
                    %lookup_values = get_lookup_values($args{'dbh'},'keyword','keywordid',"description", "keywordid IN (SELECT keywordid FROM $schema.commitmentkeyword WHERE commitmentid=$values[$fields{'com_commitmentid'}]) ORDER BY description");
                    my $keywordcount = 0;
                    foreach my $key (values %lookup_values) {
                        if ($keywordcount == 0) {
                            $outputstring .= "Commitment Keywords:<br>\n";
                        }
                        $keywordcount++;
                        $outputstring .= nbspaces(5) . "$key<br>\n";
                    }
                }

                if ($items{'product'}[0] eq 'T' && defined($values[$fields{'com_commitmentid'}])) {
                    %lookup_values = get_lookup_values($args{'dbh'},'product','productid',"description", "productid IN (SELECT productid FROM $schema.productaffected WHERE commitmentid=$values[$fields{'com_commitmentid'}]) ORDER BY description");
                    my $keywordcount = 0;
                    foreach my $key (values %lookup_values) {
                        if ($keywordcount == 0) {
                            $outputstring .= "<br>Products Affected:<br>\n";
                        }
                        $keywordcount++;
                        $outputstring .= nbspaces(5) . "$key<br>\n";
                    }
                }

                if ($items{'organization'}[0] eq 'T' && defined($values[$fields{'com_commitmentid'}])) {
                    my $sqlqueryorg = "SELECT organizationid,name,address1,address2,city,state,zipcode,country,areacode,phonenumber,extension,";
                    $sqlqueryorg .= "contact,department,division,faxareacode,faxnumber,parentorg FROM $args{'schema'}.organization ";
                    $sqlqueryorg .= "WHERE organizationid IN (SELECT organizationid FROM $args{'schema'}.committedorg ";
                    $sqlqueryorg .= "WHERE commitmentid = $values[$fields{'com_commitmentid'}]) ORDER BY name";
                    my $csrorg = $args{'dbh'}->prepare($sqlqueryorg);
                    $csrorg->execute;
                    my @orgvalues;
                    my $orgcount=0;
                    while (@orgvalues = $csrorg->fetchrow_array) {
                        if ($orgcount == 0) {
                            $outputstring .= "<br>Committed Organization(s):<br>\n";
                        }
                        $orgcount++;

                        if (defined ($items{'organization'}[4]{'details'}) && $items{'organization'}[4]{'details'} eq 'T') {
                            $outputstring .= nbspaces(5) . "$orgvalues[1]<br>\n";
                            if (defined($orgvalues[2])) {$outputstring .= nbspaces(8) . "$orgvalues[2]<br>\n";}
                            if (defined($orgvalues[3])) {$outputstring .= nbspaces(8) . "$orgvalues[3]<br>\n";}
                            my $itemcount=0;
                            if (defined($orgvalues[4])) {
                                $itemcount++;
                                $outputstring .= nbspaces(8) . "$orgvalues[4]";
                            }
                            if (defined($orgvalues[5])) {
                                if ($itemcount == 0) {
                                    $outputstring .= nbspaces(8);
                                } else {
                                    $outputstring .= ", ";
                                }
                                $itemcount++;
                                $outputstring .= "$orgvalues[5] ";
                            }
                            if (defined($orgvalues[6])) {
                                if ($itemcount == 0) {$outputstring .= nbspaces(8);}
                                $itemcount++;
                                $outputstring .= "$orgvalues[6] ";
                            }
                            if (defined($orgvalues[7])) {
                                if ($itemcount == 0) {$outputstring .= nbspaces(8);}
                                $itemcount++;
                                $outputstring .= "$orgvalues[7] ";
                            }
                            if ($itemcount > 0) {$outputstring .= "<br>\n";}
                            if (defined($orgvalues[11])) {
                                $outputstring .= nbspaces(8) . "Contact: $orgvalues[11]<br>\n";
                            }
                            if (defined($orgvalues[12])) {
                                $outputstring .= nbspaces(8) . "Department: $orgvalues[12]<br>\n";
                            }
                            if (defined($orgvalues[13])) {
                                $outputstring .= nbspaces(8) . "Defision: $orgvalues[13]<br>\n";
                            }
                            $itemcount=0;
                            if (defined($orgvalues[8]) || defined($orgvalues[9]) || defined($orgvalues[10])) {
                                $itemcount++;
                                $outputstring .= nbspaces(8) . "Phone: ";
                                $outputstring .= ((defined($orgvalues[8])) ? "($orgvalues[8]) " : "");
                                $outputstring .= ((defined($orgvalues[9])) ? substr($orgvalues[9],0,3) . "-" . substr($orgvalues[9],3,4) . " " : "");
                                $outputstring .= ((defined($orgvalues[10])) ? "ext $orgvalues[10]" : "");
                            }
                            if (defined($orgvalues[14]) || defined($orgvalues[15])) {
                                $itemcount++;
                                $outputstring .= nbspaces(8) . "FAX: ";
                                $outputstring .= ((defined($orgvalues[14])) ? "($orgvalues[14]) " : "");
                                $outputstring .= ((defined($orgvalues[15])) ? substr($orgvalues[15],0,3) . "-" . substr($orgvalues[15],3,4) : "");
                            }
                            if ($itemcount > 0) {$outputstring .= "<br>\n";}
                        } else {
                            $outputstring .= nbspaces(5) . "$orgvalues[1]<br>\n";
                        }
                    }
                    $csrorg->finish;
                }

                if ($items{'response'}[0] eq 'T' && defined($values[$fields{'com_commitmentid'}])) {
                    my $sqlqueryres = "SELECT responseid,text,TO_CHAR(writtendate,$DateFormat),commitmentid,letterid FROM $args{'schema'}.response ";
                    $sqlqueryres .= "WHERE commitmentid = $values[$fields{'com_commitmentid'}] ORDER BY writtendate";
                    my $csrres = $args{'dbh'}->prepare($sqlqueryres);
                    $csrres->execute;
                    my @resvalues;
                    my @letvalues;
                    while (@resvalues = $csrres->fetchrow_array){
                        $outputstring .= "<br>Response written on $resvalues[2]<br>\n";
                        $outputstring .= "<table border=0 cellpadding=0 cellspacing=0>\n";
                        $outputstring .= "<tr><td>" . nbspaces(5) . "</td><td valign=top><font size=-1>Text</font></td>\n";
                        if ($args{'text_limit'} eq 'T') {
                            $outputstring .= "<td><font size=-1>" . getDisplayString($resvalues[1], 100) . "</font></td>\n";
                        } else {
                            $values[$fields{'iss_text'}] =~ s/\n/<br>/g;
                            $values[$fields{'iss_text'}] =~ s/  /&nbsp;&nbsp;/g;
                            $outputstring .= "<td><font size=-1>" . breakUpLongWords($resvalues[1],80) . "</font></td>\n";
                        }
                        if (defined ($items{'response'}[4]{'details'}) && $items{'response'}[4]{'details'} eq 'T') {
                            $outputstring .= "</tr>\n";
                            if (defined($resvalues[4])) {
                                my $sqlquerylet = "SELECT letterid,accessionnum,TO_CHAR(sentdate,$DateFormat),addressee,TO_CHAR(signeddate,$DateFormat),organizationid,signer FROM $args{'schema'}.letter WHERE letterid = $resvalues[4]";
                                $outputstring .= "\n<!-- $sqlquerylet -->\n\n";
                                @letvalues = $dbh->selectrow_array($sqlquerylet);
                                $outputstring .= "<tr><td>" . nbspaces(5) . "</td><td valign=top><font size=-1>Letter Accession #" . nbspaces(3) . "</font></td><td><font size=-1>$letvalues[1]</font></td></tr>\n";
                                if (defined($letvalues[2])) {
                                    $outputstring .= "<tr><td>" . nbspaces(5) . "</td><td valign=top><font size=-1>Sent</font></td><td><font size=-1>$letvalues[2]</font></td></tr>\n";
                                }
                                if (defined($letvalues[3])) {
                                    $outputstring .= "<tr><td>" . nbspaces(5) . "</td><td valign=top><font size=-1>Addressee</font></td><td><font size=-1>$letvalues[3]</font></td></tr>\n";
                                }
                                if (defined($letvalues[5])) {
                                    $outputstring .= "<tr><td>" . nbspaces(5) . "</td><td valign=top><font size=-1>Organization</font></td><td><font size=-1>" . get_value($args{dbh},$args{schema},'organization','name',"organizationid = $letvalues[5]") . "</font></td></tr>\n";
                                }
                                if (defined($letvalues[6])) {
                                    $outputstring .= "<tr><td>" . nbspaces(5) . "</td><td valign=top><font size=-1>Signer</font></td><td><font size=-1>" . get_fullname($args{dbh},$args{schema},$letvalues[6]) . "</font></td></tr>\n";
                                }
                            }
                        }
                        $outputstring .= "</table>\n";
                    }
                    $csrres->finish;
                }




##
##
#################
#################

                print "<!-- keep alive - $count -->\n";

            }
            $csr->finish;
            $outputstring .= "<br><hr><font size=-1>$count Record" . (($count != 1) ? "s" : "") . " Displayed.<br>\n";
        }

    };
    if ($@) {
        $message = errorMessage($dbh,$username,$userid,'','',"generate an $args{'command'}.",$@);
        $message =~ s/\n/\\n/g;
        $message =~ s/'/''/g;
        $outputstring .= "<script language=javascript><!--\n";
        $outputstring .= "    alert('$message')\n";
        $outputstring .= "//--></script>\n";
    }

    return ($outputstring);
}


$dbh = &oncs_connect();
$dbh->{RaiseError} = 1;
$dbh->{LongTruncOk} = 1;   # specify whether to fetch whole text or truncated fraction
$dbh->{LongReadLen} = 10000000;

print $cirscgi->header('text/html');
print <<end;
<html>
<head>
   <script src=$ONCSJavaScriptPath/oncs-utilities.js></script>
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
      function submitForm(script, command) {
          var old_command = document.$form.command.value;
          var old_action = document.$form.action;
          var old_target = document.$form.target;
          document.$form.command.value = command;
          document.$form.action = '$path' + script + '.pl';
          document.$form.target = 'workspace';
          document.$form.submit();
          document.$form.command.value = old_command;
          document.$form.action = old_action;
          document.$form.target = old_target;
      }
      function submitFormNewWindow(script, command) {
          var old_command = document.$form.command.value;
          var old_action = document.$form.action;
          var old_target = document.$form.target;
          var myDate = new Date();
          var winName = myDate.getTime();
          document.$form.command.value = command;
          document.$form.action = '$path' + script + '.pl';
          document.$form.target = winName;
          var newwin = window.open("",winName);
          newwin.creator = self;
          document.$form.submit();
          //newwin.focus();
//          document.$form.command.value = old_command;
//          document.$form.action = old_action;
//          document.$form.target = old_target;
      }
      function submitFormCGIResults(script, command) {
          var old_command = document.$form.command.value;
          var old_action = document.$form.action;
          var old_target = document.$form.target;
          document.$form.command.value = command;
          document.$form.action = '$path' + script + '.pl';
          document.$form.target = 'control';
          document.$form.submit();
//          document.$form.command.value = old_command;
//          document.$form.action = old_action;
//          document.$form.target = old_target;
      }
      function submitReportPage() {
          document.$form.target = '_popup';
          document.$form.submit();
      }
      function selectAllOptions(thng,val) {
          for (index=0; index < thng.length-1;index++) {
              thng.options[index].selected = val;
          }

      }

//#
//##################
//#
      function processFormSubmit() {
          var msg = "";
end
if ($command eq 'adhocsetup' && $items{'issueid'}[6]{$documentid} eq 'T') {
print <<end;
          if (!(isblank(document.$form.issueid.value)) && !(isnumeric(document.$form.issueid.value))) {
              msg += "Issue ID must be a positive number\\n";
          }
end
}
if ($command eq 'adhocsetup' && $items{'sourcedoc'}[6]{$documentid} eq 'T') {
print <<end;
          var msg2 = '';
          if (!(isblank(document.$form.sourcedoc.value))) {
              var msg2 = validate_accession_number(document.$form.sourcedoc.value);
              if (!(isblank(msg2))) {
                  msg += msg2 + "\\n";
              }
          }
end
}
if ($command eq 'adhocsetup' && $items{'isentereddate'}[6]{$documentid} eq 'T') {
print <<end;
          if ((!(isblank(document.$form.isentereddate_start_day.value)) || !(isblank(document.$form.isentereddate_start_month.value)) || !(isblank(document.$form.isentereddate_start_year.value)) || !(isblank(document.$form.isentereddate_end_day.value)) || !(isblank(document.$form.isentereddate_end_month.value)) || !(isblank(document.$form.isentereddate_end_year.value)))) {
              if (((isblank(document.$form.isentereddate_start_day.value)) || (isblank(document.$form.isentereddate_start_month.value)) || (isblank(document.$form.isentereddate_start_year.value)) || (isblank(document.$form.isentereddate_end_day.value)) || (isblank(document.$form.isentereddate_end_month.value)) || (isblank(document.$form.isentereddate_end_year.value)))) {
                  msg += "All date parts must be selected for Entry Date\\n";
              } else {
                  if (document.$form.isentereddate_start_year.value + '-' + lpadzero(document.$form.isentereddate_start_month.value,2) + '-' + lpadzero(document.$form.isentereddate_start_day.value,2) >
                  document.$form.isentereddate_end_year.value + '-' + lpadzero(document.$form.isentereddate_end_month.value,2) + '-' + lpadzero(document.$form.isentereddate_end_day.value,2)) {
                      msg += "Start date can not be after the end date for Entry Date\\n";
                  }
              }
          }
end
}
if ($command eq 'adhocsetup' && $items{'comduedate'}[6]{$documentid} eq 'T') {
print <<end;
          if ((!(isblank(document.$form.comduedate_start_day.value)) || !(isblank(document.$form.comduedate_start_month.value)) || !(isblank(document.$form.comduedate_start_year.value)) || !(isblank(document.$form.comduedate_end_day.value)) || !(isblank(document.$form.comduedate_end_month.value)) || !(isblank(document.$form.comduedate_end_year.value)))) {
              if (((isblank(document.$form.comduedate_start_day.value)) || (isblank(document.$form.comduedate_start_month.value)) || (isblank(document.$form.comduedate_start_year.value)) || (isblank(document.$form.comduedate_end_day.value)) || (isblank(document.$form.comduedate_end_month.value)) || (isblank(document.$form.comduedate_end_year.value)))) {
                  msg += "All date parts must be selected for Commitment Date Due to Commitment Maker\\n";
              } else {
                  if (document.$form.comduedate_start_year.value + '-' + lpadzero(document.$form.comduedate_start_month.value,2) + '-' + lpadzero(document.$form.comduedate_start_day.value,2) >
                  document.$form.comduedate_end_year.value + '-' + lpadzero(document.$form.comduedate_end_month.value,2) + '-' + lpadzero(document.$form.comduedate_end_day.value,2)) {
                      msg += "Start date can not be after the end date for Commitment Date Due to Commitment Maker\\n";
                  }
              }
          }
end
}
if ($command eq 'adhocsetup' && $items{'ccloseddate'}[6]{$documentid} eq 'T') {
print <<end;
          if ((!(isblank(document.$form.ccloseddate_start_day.value)) || !(isblank(document.$form.ccloseddate_start_month.value)) || !(isblank(document.$form.ccloseddate_start_year.value)) || !(isblank(document.$form.ccloseddate_end_day.value)) || !(isblank(document.$form.ccloseddate_end_month.value)) || !(isblank(document.$form.ccloseddate_end_year.value)))) {
              if (((isblank(document.$form.ccloseddate_start_day.value)) || (isblank(document.$form.ccloseddate_start_month.value)) || (isblank(document.$form.ccloseddate_start_year.value)) || (isblank(document.$form.ccloseddate_end_day.value)) || (isblank(document.$form.ccloseddate_end_month.value)) || (isblank(document.$form.ccloseddate_end_year.value)))) {
                  msg += "All date parts must be selected for Commitment Close Date\\n";
              } else {
                  if (document.$form.comduedate_start_year.value + '-' + lpadzero(document.$form.comduedate_start_month.value,2) + '-' + lpadzero(document.$form.comduedate_start_day.value,2) >
                  document.$form.comduedate_end_year.value + '-' + lpadzero(document.$form.comduedate_end_month.value,2) + '-' + lpadzero(document.$form.comduedate_end_day.value,2)) {
                      msg += "Start date can not be after the end date for Commitment Close Date\\n";
                  }
              }
          }
end
}
if ($command eq 'adhocsetup' && $items{'iscategory'}[6]{$documentid} eq 'T') {
print <<end;
              selectAllOptions(document.$form.iscategory,true);
end
}
if ($command eq 'adhocsetup' && $items{'iskeyword'}[6]{$documentid} eq 'T') {
print <<end;
              selectAllOptions(document.$form.iskeyword,true);
end
}
if ($command eq 'adhocsetup' && $items{'ckeyword'}[6]{$documentid} eq 'T') {
print <<end;
              selectAllOptions(document.$form.ckeyword,true);
end
}
if ($command eq 'adhocsetup' && $items{'product'}[6]{$documentid} eq 'T') {
print <<end;
              selectAllOptions(document.$form.product,true);
end
}


print <<end;
          if (msg != "") {
              alert (msg);
          } else {
end


print <<end;
              submitFormCGIResults('$form', 'adhoctest');
end
if ($command eq 'adhocsetup' && $items{'iscategory'}[6]{$documentid} eq 'T') {
print <<end;
              selectAllOptions(document.$form.iscategory,false);
end
}
if ($command eq 'adhocsetup' && $items{'iskeyword'}[6]{$documentid} eq 'T') {
print <<end;
              selectAllOptions(document.$form.iskeyword,false);
end
}
if ($command eq 'adhocsetup' && $items{'ckeyword'}[6]{$documentid} eq 'T') {
print <<end;
              selectAllOptions(document.$form.ckeyword,false);
end
}
if ($command eq 'adhocsetup' && $items{'product'}[6]{$documentid} eq 'T') {
print <<end;
              selectAllOptions(document.$form.product,false);
end
}
print <<end;
          }
      }

//-->
</script>
end
print "</head>\n\n";
#print "<body background=/cms/images/background.gif text=$ONCSFontColor link=#0000ff vlink=#0000ff alink=#0000ff topmargin=0 leftmargin=0><center>\n";
#print "<body background=$ONCSBackground text=$ONCSFontColor link=#0000ff vlink=#0000ff alink=#0000ff topmargin=0 leftmargin=0><center>\n";
print "<body background=$ONCSBackground text=$ONCSFontColor link=#0000ff vlink=#0000ff alink=#0000ff topmargin=0 leftmargin=0><center>\n";
print "<font face=$ONCSFontFace color=$ONCSFontColor>\n";

print "<form name=$form action=$ENV{SCRIPT_NAME} method=post>\n";
print "<input type=hidden name=loginusername value=$username>\n";
print "<input type=hidden name=loginusersid value=$userid>\n";
print "<input type=hidden name=schema value=$schema>\n";
print "<input type=hidden name=command value=$command>\n";
print "<input type=hidden name=id value=$documentid>\n";
if ($command eq 'adhocsetup') {
    print "<br><table border=0 width=750>\n";
    print AdHocSelectionPage(userName => $username, userID => $userid, schema => $schema, dbh => $dbh, type => $documentid, 'items' => \%items);
} elsif ($command eq 'adhoctest' || $command eq 'adhocreport') {

#
##################
#

    # item - issueid
    if (defined($cirscgi->param('issueid_selected'))) {
        $items{'issueid'}[0] = $cirscgi->param('issueid_selected');
        $itemsselected = 'T';
    }
    if ($cirscgi->param('sortorder') eq 'issueid_sort') {
        $items{'issueid'}[1] = 'T';
    }
    if (defined($cirscgi->param('issueid'))) {
        $items{'issueid'}[4]{'id'} = $cirscgi->param('issueid');
    }
    if ($items{'issueid'}[4]{'id'} gt ' ') {
        $items{'issueid'}[5] = 'T';
    }

    ## item - issite
    #if (defined($cirscgi->param('issite_selected'))) {
    #    $items{'issite'}[0] = $cirscgi->param('issite_selected');
    #    $itemsselected = 'T';
    #}
    #if (defined($cirscgi->param('issite'))) {
    #    $items{'issite'}[4]{'id'} = $cirscgi->param('issite');
    #}
    #if ($items{'issite'}[4]{'id'} gt ' ') {
    #    $items{'issite'}[5] = 'T';
    #}

    # item - istext
    if (defined($cirscgi->param('istext_selected'))) {
        $items{'istext'}[0] = $cirscgi->param('istext_selected');
        $itemsselected = 'T';
    }

    # item - isentereddate
    if (defined($cirscgi->param('isentereddate_selected'))) {
        $items{'isentereddate'}[0] = $cirscgi->param('isentereddate_selected');
        $itemsselected = 'T';
    }
    if ($cirscgi->param('sortorder') eq 'isentereddate_sort') {
        $items{'isentereddate'}[1] = 'T';
        $itemsselected = 'T';
    }
    if ($command eq 'adhoctest') {
        if (defined($cirscgi->param('isentereddate_start_month')) && defined($cirscgi->param('isentereddate_start_day')) && defined($cirscgi->param('isentereddate_start_year'))) {
            $items{'isentereddate'}[4]{'startdate'} = $cirscgi->param('isentereddate_start_year') . '-' . lpadzero($cirscgi->param('isentereddate_start_month'),2) . '-' . lpadzero($cirscgi->param('isentereddate_start_day'),2);
        }
        if (defined($cirscgi->param('isentereddate_end_month')) && defined($cirscgi->param('isentereddate_end_day')) && defined($cirscgi->param('isentereddate_end_year'))) {
            $items{'isentereddate'}[4]{'enddate'} = $cirscgi->param('isentereddate_end_year') . '-' . lpadzero($cirscgi->param('isentereddate_end_month'),2) . '-' . lpadzero($cirscgi->param('isentereddate_end_day'),2);
        }
    } else {
        if (defined($cirscgi->param('isentereddate_start'))) {
            $items{'isentereddate'}[4]{'startdate'} = $cirscgi->param('isentereddate_start')
        }
        if (defined($cirscgi->param('isentereddate_end'))) {
            $items{'isentereddate'}[4]{'enddate'} = $cirscgi->param('isentereddate_end')
        }
    }
    if (($items{'isentereddate'}[4]{'startdate'} gt '' && substr($items{'isentereddate'}[4]{'startdate'},0,1) ne '-') ||
           ($items{'isentereddate'}[4]{'enddate'} gt '' && substr($items{'isentereddate'}[4]{'enddate'},0,1) ne '-')) {
        $items{'isentereddate'}[5] = 'T';
    }

    # item - ispage
    if (defined($cirscgi->param('ispage_selected'))) {
        $items{'ispage'}[0] = $cirscgi->param('ispage_selected');
        $itemsselected = 'T';
    }

    # item - sourcedoc
    if (defined($cirscgi->param('sourcedoc_selected'))) {
        $items{'sourcedoc'}[0] = $cirscgi->param('sourcedoc_selected');
        $itemsselected = 'T';
    }
    if ($cirscgi->param('sortorder') eq 'sourcedoc_sort') {
        $items{'sourcedoc'}[1] = 'T';
    }
    if (defined($cirscgi->param('sourcedoc'))) {
        $items{'sourcedoc'}[4]{'id'} = $cirscgi->param('sourcedoc');
    }
    if (defined($cirscgi->param('sddetails'))) {
        $items{'sourcedoc'}[4]{'details'} = $cirscgi->param('sddetails');
    }
    if ($items{'sourcedoc'}[4]{'id'} gt ' ') {
        $items{'sourcedoc'}[5] = 'T';
    }

    # item - iscategory
    if (defined($cirscgi->param('iscategory_selected'))) {
        $items{'iscategory'}[0] = $cirscgi->param('iscategory_selected');
        $itemsselected = 'T';
    }
    if ($cirscgi->param('sortorder') eq 'iscategory_sort') {
        $items{'iscategory'}[1] = 'T';
    }
    if (defined($cirscgi->param('iscategory'))) {
        $items{'iscategory'}[4]{'list'} = [ $cirscgi->param('iscategory') ];
    }
    if (defined( $items{'iscategory'}[4]{'list'}[0] ) && $items{'iscategory'}[4]{'list'}[0] gt "0") {
        $items{'iscategory'}[5] = 'T';
    }

    # item - iskeyword
    if (defined($cirscgi->param('iskeyword_selected'))) {
        $items{'iskeyword'}[0] = $cirscgi->param('iskeyword_selected');
        $itemsselected = 'T';
    }
    if (defined($cirscgi->param('iskeyword'))) {
        $items{'iskeyword'}[4]{'list'} = [ $cirscgi->param('iskeyword') ];
    }
    if (defined($cirscgi->param('iskeyword_boolean'))) {
        $items{'iskeyword'}[4]{'boolean'} = $cirscgi->param('iskeyword_boolean');
    }
    if (defined( $items{'iskeyword'}[4]{'list'}[0] ) && $items{'iskeyword'}[4]{'list'}[0] gt "0") {
        $items{'iskeyword'}[5] = 'T';
    }

    # item - isenteredby
    if (defined($cirscgi->param('isenteredby_selected'))) {
        $items{'isenteredby'}[0] = $cirscgi->param('isenteredby_selected');
        $itemsselected = 'T';
    }
    if (defined($cirscgi->param('isenteredby'))) {
        $items{'isenteredby'}[4]{'id'} = $cirscgi->param('isenteredby');
    }
    if (defined( $items{'isenteredby'}[4]{'id'} ) && $items{'isenteredby'}[4]{'id'} gt "0") {
        $items{'isenteredby'}[5] = 'T';
    }

    # item - commitmentid
    if (defined($cirscgi->param('commitmentid_selected'))) {
        $items{'commitmentid'}[0] = $cirscgi->param('commitmentid_selected');
        $itemsselected = 'T';
    }
    if ($cirscgi->param('sortorder') eq 'commitmentid_sort') {
        $items{'commitmentid'}[1] = 'T';
    }
    if (defined($cirscgi->param('commitmentid'))) {
        $items{'commitmentid'}[4]{'id'} = $cirscgi->param('commitmentid');
    }
    if ($items{'commitmentid'}[4]{'id'} gt ' ') {
        $items{'commitmentid'}[5] = 'T';
    }

    # item - controlaccountid
    if (defined($cirscgi->param('controlaccountid_selected'))) {
        $items{'controlaccountid'}[0] = $cirscgi->param('controlaccountid_selected');
        $itemsselected = 'T';
    }
    if ($cirscgi->param('sortorder') eq 'controlaccountid_sort') {
        $items{'controlaccountid'}[1] = 'T';
    }
    if (defined($cirscgi->param('controlaccountid'))) {
        $items{'controlaccountid'}[4]{'id'} = $cirscgi->param('controlaccountid');
    }
    if ($items{'controlaccountid'}[4]{'id'} gt ' ') {
        $items{'controlaccountid'}[5] = 'T';
    }

    ## item - comsite
    #if (defined($cirscgi->param('comsite_selected'))) {
    #    $items{'comsite'}[0] = $cirscgi->param('comsite_selected');
    #    $itemsselected = 'T';
    #}
    #if (defined($cirscgi->param('comsite'))) {
    #    $items{'comsite'}[4]{'id'} = $cirscgi->param('comsite');
    #}
    #if ($items{'comsite'}[4]{'id'} gt ' ') {
    #    $items{'comsite'}[5] = 'T';
    #}

    ## item - comrole
    #if (defined($cirscgi->param('comrole_selected'))) {
    #    $items{'comrole'}[0] = $cirscgi->param('comrole_selected');
    #    $itemsselected = 'T';
    #}
    #if (defined($cirscgi->param('comrole'))) {
    #    $items{'comrole'}[4]{'id'} = $cirscgi->param('comrole');
    #}
    #if ($items{'comrole'}[4]{'id'} gt ' ') {
    #    $items{'comrole'}[5] = 'T';
    #}

    # item - comduedate
    if (defined($cirscgi->param('comduedate_selected'))) {
        $items{'comduedate'}[0] = $cirscgi->param('comduedate_selected');
        $itemsselected = 'T';
    }
    if ($cirscgi->param('sortorder') eq 'comduedate_sort') {
        $items{'comduedate'}[1] = 'T';
        $itemsselected = 'T';
    }
    if ($command eq 'adhoctest') {
        if (defined($cirscgi->param('comduedate_start_month')) && defined($cirscgi->param('comduedate_start_day')) && defined($cirscgi->param('comduedate_start_year'))) {
            $items{'comduedate'}[4]{'startdate'} = $cirscgi->param('comduedate_start_year') . '-' . lpadzero($cirscgi->param('comduedate_start_month'),2) . '-' . lpadzero($cirscgi->param('comduedate_start_day'),2);
        }
        if (defined($cirscgi->param('comduedate_end_month')) && defined($cirscgi->param('comduedate_end_day')) && defined($cirscgi->param('comduedate_end_year'))) {
            $items{'comduedate'}[4]{'enddate'} = $cirscgi->param('comduedate_end_year') . '-' . lpadzero($cirscgi->param('comduedate_end_month'),2) . '-' . lpadzero($cirscgi->param('comduedate_end_day'),2);
        }
    } else {
        if (defined($cirscgi->param('comduedate_start'))) {
            $items{'comduedate'}[4]{'startdate'} = $cirscgi->param('comduedate_start')
        }
        if (defined($cirscgi->param('comduedate_end'))) {
            $items{'comduedate'}[4]{'enddate'} = $cirscgi->param('comduedate_end')
        }
    }
    if (($items{'comduedate'}[4]{'startdate'} gt '' && substr($items{'comduedate'}[4]{'startdate'},0,1) ne '-') ||
           ($items{'comduedate'}[4]{'enddate'} gt '' && substr($items{'comduedate'}[4]{'enddate'},0,1) ne '-')) {
        $items{'comduedate'}[5] = 'T';
    }

    # item - cfunctionaldisp
    if (defined($cirscgi->param('cfunctionaldisp_selected'))) {
        $items{'cfunctionaldisp'}[0] = $cirscgi->param('cfunctionaldisp_selected');
        $itemsselected = 'T';
    }
    if (defined($cirscgi->param('cfunctionaldisp'))) {
        $items{'cfunctionaldisp'}[4]{'id'} = $cirscgi->param('cfunctionaldisp');
    }
    if (defined( $items{'cfunctionaldisp'}[4]{'id'} ) && $items{'cfunctionaldisp'}[4]{'id'} gt "0") {
        $items{'cfunctionaldisp'}[5] = 'T';
    }

    # item - cestimate
    if (defined($cirscgi->param('cestimate_selected'))) {
        $items{'cestimate'}[0] = $cirscgi->param('cestimate_selected');
        $itemsselected = 'T';
    }

    # item - cfunctionalrec
    if (defined($cirscgi->param('cfunctionalrec_selected'))) {
        $items{'cfunctionalrec'}[0] = $cirscgi->param('cfunctionalrec_selected');
        $itemsselected = 'T';
    }

    # item - ccommitrationale
    if (defined($cirscgi->param('ccommitrationale_selected'))) {
        $items{'ccommitrationale'}[0] = $cirscgi->param('ccommitrationale_selected');
        $itemsselected = 'T';
    }

    # item - capprovalrationale
    if (defined($cirscgi->param('capprovalrationale_selected'))) {
        $items{'capprovalrationale'}[0] = $cirscgi->param('capprovalrationale_selected');
        $itemsselected = 'T';
    }

    # item - ctext
    if (defined($cirscgi->param('ctext_selected'))) {
        $items{'ctext'}[0] = $cirscgi->param('ctext_selected');
        $itemsselected = 'T';
    }

    # item - ccomments
    if (defined($cirscgi->param('ccomments_selected'))) {
        $items{'ccomments'}[0] = $cirscgi->param('ccomments_selected');
        $itemsselected = 'T';
    }

    # item - crejectrationale
    if (defined($cirscgi->param('crejectrationale_selected'))) {
        $items{'crejectrationale'}[0] = $cirscgi->param('crejectrationale_selected');
        $itemsselected = 'T';
    }

    # item - cresubrationale
    if (defined($cirscgi->param('cresubrationale_selected'))) {
        $items{'cresubrationale'}[0] = $cirscgi->param('cresubrationale_selected');
        $itemsselected = 'T';
    }

    # item - cactionstaken
    if (defined($cirscgi->param('cactionstaken_selected'))) {
        $items{'cactionstaken'}[0] = $cirscgi->param('cactionstaken_selected');
        $itemsselected = 'T';
    }

    # item - cactionsummary
    if (defined($cirscgi->param('cactionsummary_selected'))) {
        $items{'cactionsummary'}[0] = $cirscgi->param('cactionsummary_selected');
        $itemsselected = 'T';
    }

    # item - cactionplan
    if (defined($cirscgi->param('cactionplan_selected'))) {
        $items{'cactionplan'}[0] = $cirscgi->param('cactionplan_selected');
        $itemsselected = 'T';
    }

    # item - ccmrecommendation
    if (defined($cirscgi->param('ccmrecommendation_selected'))) {
        $items{'ccmrecommendation'}[0] = $cirscgi->param('ccmrecommendation_selected');
        $itemsselected = 'T';
    }

    # item - coldid
    if (defined($cirscgi->param('coldid_selected'))) {
        $items{'coldid'}[0] = $cirscgi->param('coldid_selected');
        $itemsselected = 'T';
    }
    if ($cirscgi->param('sortorder') eq 'coldid_sort') {
        $items{'coldid'}[1] = 'T';
    }
    if (defined($cirscgi->param('coldid'))) {
        $items{'coldid'}[4]{'id'} = $cirscgi->param('coldid');
    }
    if ($items{'coldid'}[4]{'id'} gt ' ') {
        $items{'coldid'}[5] = 'T';
    }

    # item - ccloseddate
    if (defined($cirscgi->param('ccloseddate_selected'))) {
        $items{'ccloseddate'}[0] = $cirscgi->param('ccloseddate_selected');
        $itemsselected = 'T';
    }
    if ($cirscgi->param('sortorder') eq 'ccloseddate_sort') {
        $items{'ccloseddate'}[1] = 'T';
        $itemsselected = 'T';
    }
    if ($command eq 'adhoctest') {
        if (defined($cirscgi->param('ccloseddate_start_month')) && defined($cirscgi->param('ccloseddate_start_day')) && defined($cirscgi->param('ccloseddate_start_year'))) {
            $items{'ccloseddate'}[4]{'startdate'} = $cirscgi->param('ccloseddate_start_year') . '-' . lpadzero($cirscgi->param('ccloseddate_start_month'),2) . '-' . lpadzero($cirscgi->param('ccloseddate_start_day'),2);
        }
        if (defined($cirscgi->param('ccloseddate_end_month')) && defined($cirscgi->param('ccloseddate_end_day')) && defined($cirscgi->param('ccloseddate_end_year'))) {
            $items{'ccloseddate'}[4]{'enddate'} = $cirscgi->param('ccloseddate_end_year') . '-' . lpadzero($cirscgi->param('ccloseddate_end_month'),2) . '-' . lpadzero($cirscgi->param('ccloseddate_end_day'),2);
        }
    } else {
        if (defined($cirscgi->param('ccloseddate_start'))) {
            $items{'ccloseddate'}[4]{'startdate'} = $cirscgi->param('ccloseddate_start')
        }
        if (defined($cirscgi->param('ccloseddate_end'))) {
            $items{'ccloseddate'}[4]{'enddate'} = $cirscgi->param('ccloseddate_end')
        }
    }
    if (($items{'ccloseddate'}[4]{'startdate'} gt '' && substr($items{'ccloseddate'}[4]{'startdate'},0,1) ne '-') ||
           ($items{'ccloseddate'}[4]{'enddate'} gt '' && substr($items{'ccloseddate'}[4]{'enddate'},0,1) ne '-')) {
        $items{'ccloseddate'}[5] = 'T';
    }

    # item - ccontrolaccountid
    if (defined($cirscgi->param('ccontrolaccountid_selected'))) {
        $items{'ccontrolaccountid'}[0] = $cirscgi->param('ccontrolaccountid_selected');
        $itemsselected = 'T';
    }
    if ($cirscgi->param('sortorder') eq 'ccontrolaccountid_sort') {
        $items{'ccontrolaccountid'}[1] = 'T';
    }
    if (defined($cirscgi->param('ccontrolaccountid'))) {
        $items{'ccontrolaccountid'}[4]{'id'} = $cirscgi->param('ccontrolaccountid');
    }
    if ($items{'ccontrolaccountid'}[4]{'id'} gt ' ') {
        $items{'ccontrolaccountid'}[5] = 'T';
    }

    # item - capprover
    if (defined($cirscgi->param('capprover_selected'))) {
        $items{'capprover'}[0] = $cirscgi->param('capprover_selected');
        $itemsselected = 'T';
    }
    if (defined($cirscgi->param('capprover'))) {
        $items{'capprover'}[4]{'id'} = $cirscgi->param('capprover');
    }
    if (defined( $items{'capprover'}[4]{'id'} ) && $items{'capprover'}[4]{'id'} gt "0") {
        $items{'capprover'}[5] = 'T';
    }

    # item - cupdatedby
    if (defined($cirscgi->param('cupdatedby_selected'))) {
        $items{'cupdatedby'}[0] = $cirscgi->param('cupdatedby_selected');
        $itemsselected = 'T';
    }
    if (defined($cirscgi->param('cupdatedby'))) {
        $items{'cupdatedby'}[4]{'id'} = $cirscgi->param('cupdatedby');
    }
    if (defined( $items{'cupdatedby'}[4]{'id'} ) && $items{'cupdatedby'}[4]{'id'} gt "0") {
        $items{'cupdatedby'}[5] = 'T';
    }

    # item - creplacedby
    if (defined($cirscgi->param('creplacedby_selected'))) {
        $items{'creplacedby'}[0] = $cirscgi->param('creplacedby_selected');
        $itemsselected = 'T';
    }
    if ($cirscgi->param('sortorder') eq 'creplacedby_sort') {
        $items{'creplacedby'}[1] = 'T';
    }
    if (defined($cirscgi->param('creplacedby'))) {
        $items{'creplacedby'}[4]{'id'} = $cirscgi->param('creplacedby');
    }
    if (defined( $items{'creplacedby'}[4]{'id'} ) && $items{'creplacedby'}[4]{'id'} gt "0") {
        $items{'creplacedby'}[5] = 'T';
    }

    # item - cstatusid
    if (defined($cirscgi->param('cstatusid_selected'))) {
        $items{'cstatusid'}[0] = $cirscgi->param('cstatusid_selected');
        $itemsselected = 'T';
    }
    if ($cirscgi->param('sortorder') eq 'cstatusid_sort') {
        $items{'cstatusid'}[1] = 'T';
    }
    if (defined($cirscgi->param('cstatusid'))) {
        $items{'cstatusid'}[4]{'id'} = $cirscgi->param('cstatusid');
    }
    if (defined( $items{'cstatusid'}[4]{'id'} ) && $items{'cstatusid'}[4]{'id'} gt "0") {
        $items{'cstatusid'}[5] = 'T';
    }

    # item - ccommitmentlevel
    if (defined($cirscgi->param('ccommitmentlevel_selected'))) {
        $items{'ccommitmentlevel'}[0] = $cirscgi->param('ccommitmentlevel_selected');
        $itemsselected = 'T';
    }
    if ($cirscgi->param('sortorder') eq 'ccommitmentlevel_sort') {
        $items{'ccommitmentlevel'}[1] = 'T';
    }
    if (defined($cirscgi->param('ccommitmentlevel'))) {
        $items{'ccommitmentlevel'}[4]{'id'} = $cirscgi->param('ccommitmentlevel');
    }
    if (defined( $items{'ccommitmentlevel'}[4]{'id'} ) && $items{'ccommitmentlevel'}[4]{'id'} gt "0") {
        $items{'ccommitmentlevel'}[5] = 'T';
    }

    # item - ckeyword
    if (defined($cirscgi->param('ckeyword_selected'))) {
        $items{'ckeyword'}[0] = $cirscgi->param('ckeyword_selected');
        $itemsselected = 'T';
    }
    if (defined($cirscgi->param('ckeyword'))) {
        $items{'ckeyword'}[4]{'list'} = [ $cirscgi->param('ckeyword') ];
    }
    if (defined($cirscgi->param('ckeyword_boolean'))) {
        $items{'ckeyword'}[4]{'boolean'} = $cirscgi->param('ckeyword_boolean');
    }
    if (defined( $items{'ckeyword'}[4]{'list'}[0] ) && $items{'ckeyword'}[4]{'list'}[0] gt "0") {
        $items{'ckeyword'}[5] = 'T';
    }

    # item - product
    if (defined($cirscgi->param('product_selected'))) {
        $items{'product'}[0] = $cirscgi->param('product_selected');
        $itemsselected = 'T';
    }
    if (defined($cirscgi->param('product'))) {
        $items{'product'}[4]{'list'} = [ $cirscgi->param('product') ];
    }
    if (defined($cirscgi->param('product_boolean'))) {
        $items{'product'}[4]{'boolean'} = $cirscgi->param('product_boolean');
    }
    if (defined( $items{'product'}[4]{'list'}[0] ) && $items{'product'}[4]{'list'}[0] gt "0") {
        $items{'product'}[5] = 'T';
    }

    # item - organization
    if (defined($cirscgi->param('organization_selected'))) {
        $items{'organization'}[0] = $cirscgi->param('organization_selected');
        $itemsselected = 'T';
    }
    if (defined($cirscgi->param('organization'))) {
        $items{'organization'}[4]{'id'} = $cirscgi->param('organization');
    }
    if (defined($cirscgi->param('organization_details'))) {
        $items{'organization'}[4]{'details'} = $cirscgi->param('organization_details');
    }
    if (defined( $items{'organization'}[4]{'id'} ) && $items{'organization'}[4]{'id'} gt "0") {
        $items{'organization'}[5] = 'T';
    }

    # item - response
    if (defined($cirscgi->param('response_selected'))) {
        $items{'response'}[0] = $cirscgi->param('response_selected');
        $itemsselected = 'T';
    }
    if (defined($cirscgi->param('response_details'))) {
        $items{'response'}[4]{'details'} = $cirscgi->param('response_details');
    }



    #
    if ($itemsselected eq 'T') {
        print AdHocReportPage('schema' => $schema, 'dbh' => $dbh, 'command' => $command,
            'reporttitle' => ((defined($cirscgi->param('reporttitle'))) ? $cirscgi->param('reporttitle') : 'Ad Hoc Report'),
            'sortdirection' => $cirscgi->param('sortdirection'), 'report_boolean' => $cirscgi->param('report_boolean'),
            'text_limit' => ((defined($cirscgi->param('text_limit'))) ? $cirscgi->param('text_limit') : 'F'),
            'tables' => \%tables, 'items' => \%items, 'joins' => \@joins);
    } else {
        print "<script language=javascript><!--\n";
        print "    alert('No items selected for report.')\n";
        print "//--></script>\n";
    }

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
&oncs_disconnect($dbh);
exit();
