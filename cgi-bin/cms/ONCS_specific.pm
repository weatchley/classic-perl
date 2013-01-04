# Library of utilities routines specific to CMS
#
# $Source: /data/dev/rcs/cms/perl/RCS/ONCS_specific.pm,v $
# $Revision: 1.21 $
# $Date: 2003/01/02 23:53:44 $
# $Author: naydenoa $
# $Locker:  $
# $Log: ONCS_specific.pm,v $
# Revision 1.21  2003/01/02 23:53:44  naydenoa
# Added NRC date and DOE manager retrieval to get_commitment_info
# CREQ00023, CREQ00024
#
# Revision 1.20  2002/04/12 23:48:42  naydenoa
# Checkpoint
#
# Revision 1.19  2002/01/29 00:23:19  naydenoa
# Add external ID, manager, liecnsing retrieval for commitment
#
# Revision 1.18  2001/05/08 18:15:20  naydenoa
# Added condition for first/final response on response retrieval
#
# Revision 1.17  2001/02/21 21:46:21  naydenoa
# Added RSS factor to commitment retrieval
#
# Revision 1.16  2001/02/16 23:52:56  naydenoa
# Added retrieval of location and organization fields in get_user_info
#
# Revision 1.15  2001/02/09 17:30:18  naydenoa
# Took out source category from source info retrieval
# Took out secondary discipline from commitment info retrieval
#
# Revision 1.14  2000/12/18 16:59:42  naydenoa
# Fixed bug in closure date retrieval (commitment info sub)
#
# Revision 1.13  2000/12/07 19:05:22  naydenoa
# Added fulfilldate retrieval to commitment_info hash
#
# Revision 1.12  2000/11/02 18:20:03  naydenoa
# Removed test prints
#
# Revision 1.11  2000/10/31 19:43:53  naydenoa
# Took out rationales and comments from get_commitment_info sub
#
# Revision 1.10  2000/10/19 23:31:02  naydenoa
# Added new 'isclosed' column to issue retrieval in get_issue_info
#
# Revision 1.9  2000/09/28 19:49:49  atchleyb
# removed ref to dropped columns in the issue table
#
# Revision 1.8  2000/09/26 00:47:40  atchleyb
# remove ref to depreciated variable
#
# Revision 1.7  2000/07/06 23:52:18  zepedaj
# added debugging command for read_issue_info sub
#
# Revision 1.6  2000/05/19 23:46:08  zepedaj
# Changed code for the final WBS structure
#
# Revision 1.5  2000/05/19 19:13:54  zepedaj
# Modified get_wbs_info for new WBS table structure
#
# Revision 1.4  2000/05/12 17:05:14  zepedaj
# Changed the sort in lookup_response_info
#
# Revision 1.3  2000/05/11 20:52:43  zepedaj
# Added lookup_response_information and lookup_letter_information routines
#
# Revision 1.2  2000/04/25 22:31:48  zepedaj
# fixed commitment routines, added commitment image handling
#
# Revision 1.1  2000/04/11 23:43:37  zepedaj
# Initial revision
#
#

package ONCS_specific;
use strict;
use Carp;
use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS $VERSION $AUTOLOAD);
use vars qw($ONCSUser $ONCSPassword $SCHEMA);
use ONCS_Header qw(:Constants);

use Exporter;
$VERSION = 1.00;

@ISA = qw(Exporter);

@EXPORT = qw (       &get_maximum_id             &get_next_id         
                     &make_username              &get_user_info       
                     &get_wbs_info               &get_org_info
                     &get_site_info              &get_issue_info      
                     &get_sourcedoc_info         &lookup_role_by_name 
                     &get_commitment_info        &get_issue_image 
                     &get_commitmentlevel_info   &get_role_info 
                     &get_default_role_values    &get_products_affected
                     &get_final_image            &lookup_response_information 
                     &lookup_letter_information);
@EXPORT_OK = qw(     &get_maximum_id             &get_next_id 
                     &make_username              &get_user_info 
                     &get_wbs_info               &get_org_info
                     &get_site_info              &get_issue_info 
                     &get_sourcedoc_info         &lookup_role_by_name 
                     &get_commitment_info        &get_issue_image 
                     &get_commitmentlevel_info   &get_role_info 
                     &get_default_role_values    &get_products_affected
                     &get_final_image            &lookup_response_information 
                     &lookup_letter_information);
%EXPORT_TAGS =(
    Functions => [qw(&get_maximum_id             &get_next_id 
                     &make_username              &get_user_info 
                     &get_wbs_info               &get_org_info
                     &get_site_info              &get_issue_info 
                     &get_sourcedoc_info         &lookup_role_by_name 
                     &get_commitment_info        &get_issue_image 
                     &get_commitmentlevel_info   &get_role_info 
                     &get_default_role_values    &get_products_affected
                     &get_final_image            &lookup_response_information 
                     &lookup_letter_information) ]
);

#
# Contents of library:
#
# utilities
#
# 'get_maximum_id'
# ($scalar number) = &get_maximum_id( (database handle), (tablename) )
#    assumes table id is 'tablenameID'
#
# 'get_next_id'
# ($scalar number) = &get_next_id( (database handle), (tablename) )
#    assumes a sequence called 'tablenameID_SEQ'
#
# 'make_username'
# ($username string) = &make_username( (database handle), (last name), (first name) )
#
# 'get_user_info'
# (%userhash) = &get_user_info( (database handle), (usersid) )
#
# 'get_wbs_info'
# (%wbshash) = &get_wbs_info( (database handle), ("controlaccountid") )
#
# 'get_org_info'
# (%orghash) = &get_org_info( (database handle), (organizationid) )
#
# 'get_site_info'
# (%sitehash) = &get_site_info( (database handle), (siteid) )
#
# 'get_issue_info'
# (%issuehash) = &get_issue_info( (database handle), (issueid) )
#
# 'get_issue_image'
# ($imagedata) = &get_issue_image( (database handle), (issueid) )
#
# 'get_sourcedoc_info'
# (%sourcedochash) = &get_sourcedoc_info( (database handle), (sourcedocid) )
#
# 'lookup_role_by_name'
# ($roleid) = &lookup_role_by_name( (database handle), (role name) )
#
# 'get_commitment_info'
# (%commitmenthash) = &get_commitment_info( (database handle), (commitmentid) )
#
# 'get_commitmentlevel_info'
# (%commitmentlevelhash) = &get_commitmentlevel_info( (database handle), (commitmentlevelid) )
#
# 'get_role_info'
# (%rolehash) = &get_role_info( (database handle), (roleid) )
#
# 'get_default_role_values'
# (%rolehash) = &get_default_role_values( (database handle), (roleid), (siteid), (dependson string), dependid )
#
# 'get_products_affected'
# (@productidlist) = &get_products_affected( (database handle), (commitmentid) )
#
# 'get_final_image'
# ($imagedata) = &get_final_image( (database handle), (commitmentid) )
#
# 'lookup_response_information'
# (%responsehash) = &lookup_response_information( (database handle), (commitmentid), (responseid) )
#
# 'lookup_letter_information'
# (%letterhash) = &lookup_letter_information( (database handle), (letterid) )
#

####################
sub get_maximum_id {
####################
    my $dbh=$_[0];	
    my $tablename = $_[1];	
 	
    # create select
    my $sqlstring = "SELECT MAX(" . $tablename . "id)
                     FROM $SCHEMA.$tablename";

    my $csr=$dbh->prepare($sqlstring);
    my $rv=$csr->execute;

    # max will return 1 row with 1 column which holds the largest value
    my @maxvalue=$csr->fetchrow_array;
    my $rc = $csr->finish;

    return ($maxvalue[0]);
}

#################
sub get_next_id {
#################
    my $dbh=$_[0];
    my $tablename = $_[1];

    my $sqlstring;
    my $csr;
    my $rv;
    my @nextvalue;
    my $rc;

    $sqlstring = "SELECT $SCHEMA.$tablename" . "ID_SEQ.NEXTVAL FROM DUAL";

    $csr=$dbh->prepare($sqlstring);
    $rv=$csr->execute;
    @nextvalue=$csr->fetchrow_array;
    $rc = $csr->finish;

    return ($nextvalue[0]);
}

###################
sub make_username {
###################
    my $dbh = $_[0];
    my $lastname = uc($_[1]);
    my $firstname = uc($_[2]);

    # remove single quotes from the first and last names
    $lastname =~ s/'//g;
    $firstname =~ s/'//g;

    my $usernamestring = substr($lastname, 0, 7);
    $usernamestring .= substr($firstname, 0, (8 - length($usernamestring)));

    my $usernamestringlength = length($usernamestring);
 
    my $sqlquery = "SELECT COUNT(username)
                    FROM $SCHEMA.users
                    WHERE SUBSTR(username, 1, $usernamestringlength) = '$usernamestring'";

    my $csr = $dbh->prepare($sqlquery);
    my $rv = $csr->execute;

    my @usernamesuffix = $csr->fetchrow_array;
    $usernamesuffix[0] = '00'.$usernamesuffix[0];
    my $rc = $csr->finish;

    return($usernamestring . substr($usernamesuffix[0], -2));
}

###################
sub get_user_info {
###################
    my $dbh=$_[0];
    my $passedid=$_[1];

    my %usershash;

    # setup a cursor to read the information
    my $sqlquery = "SELECT lastname, firstname, areacode, phonenumber,
                           extension, email, isactive, siteid, 
                           username, password, location, organization
                    FROM $SCHEMA.users
                    WHERE usersid = $passedid";
    my $csr = $dbh->prepare($sqlquery);
    my $rv = $csr->execute;

    #A single row will be returned (unless the database fails) we couldn't be
    #here otherwise.
    my @userresults = $csr->fetchrow_array;

    %usershash = (lastname => $userresults[0], firstname => $userresults[1],
                  areacode => $userresults[2], phonenumber => $userresults[3],
                  extension => $userresults[4], email => $userresults[5],
                  isactive => $userresults[6], siteid => $userresults[7],
                  thisusername => $userresults[8], password => $userresults[9],
                  location => $userresults[10], 
                  organization => $userresults[11]);
    my $rc = $csr->finish;
  
    return(%usershash);
}

##################
sub get_wbs_info {
##################
    my $dbh=$_[0];
    my $controlaccountid=$_[1];

    my %wbshash;
    my $sqlquery = "SELECT description, pointofcontact, isactive
                    FROM $SCHEMA.workbreakdownstructure
                    WHERE controlaccountid = '$controlaccountid'";
    my $csr = $dbh->prepare($sqlquery);
    my $rv = $csr->execute;

    #A single row will be returned (unless the database fails) we couldn't be
    #here otherwise.
    my @wbsresults = $csr->fetchrow_array;

    %wbshash = (controlaccountid => $controlaccountid, 
                description => $wbsresults[0],
                pointofcontact => $wbsresults[1],    
                isactive => $wbsresults[2]);
    my $rc = $csr->finish;

    return(%wbshash);
}

##################
sub get_org_info {
##################
    my $dbh=$_[0];
    my $passedid=$_[1];

    my %orghash;
    my $sqlquery = "SELECT name, address1, address2, city, state, zipcode, 
                           country, areacode, phonenumber, extension, 
                           contact, department, division,
                           faxareacode, faxnumber, parentorg
                    FROM $SCHEMA.organization
                    WHERE organizationid = $passedid";
    my $csr = $dbh->prepare($sqlquery);
    my $rv = $csr->execute;

    #A single row will be returned (unless the database fails) we couldn't be
    #here otherwise.
    my @orgresults = $csr->fetchrow_array;

    %orghash = (name => $orgresults[ 0], address1 => $orgresults[ 1],
                address2 => $orgresults[ 2], city => $orgresults[ 3],
                state => $orgresults[ 4], zipcode => $orgresults[ 5],
                country => $orgresults[ 6], areacode => $orgresults[ 7],
                phonenumber => $orgresults[ 8], extension => $orgresults[ 9],
                contact => $orgresults[10], department => $orgresults[11],
                division => $orgresults[12], faxareacode => $orgresults[13],
                faxnumber => $orgresults[14], parentorg => $orgresults[15]);
    my $rc = $csr->finish;

    return(%orghash);
}

###################
sub get_site_info {
###################
    my $dbh=$_[0];
    my $passedid=$_[1];

    my %sitehash;
    my $sqlquery = "SELECT name, city, state
                    FROM $SCHEMA.site
                    WHERE siteid = $passedid";
    my $csr = $dbh->prepare($sqlquery);
    my $rv = $csr->execute;

    #A single row will be returned (unless the database fails) we couldn't be
    #here otherwise.
    my @siteresults = $csr->fetchrow_array;

    %sitehash = (name => $siteresults[ 0], city => $siteresults[ 1], 
                 state => $siteresults[ 2]);
    my $rc = $csr->finish;

    return(%sitehash);
}

####################
sub get_issue_info {
####################
    my $dbh=$_[0];
    my $passedid=$_[1];

    my %issuehash;
    $dbh->{LongReadLen} = $MaxBytesStored;  #constant from the header file
    my $sqlquery = "SELECT text, TO_CHAR(entereddate, 'MM/DD/YYYY'),
                           sourcedocid, imagecontenttype, imageextension,
                           page, enteredby, 'null', 'null', categoryid,
                           TO_CHAR(dateoccurred, 'MM/DD/YYYY'), 
                           siteid, isclosed
                    FROM $SCHEMA.issue
                    WHERE issueid = $passedid";
    print "<!-- $sqlquery -->\n";
    my $csr = $dbh->prepare($sqlquery);
    my $rv = $csr->execute;

    #A single row will be returned (unless the database fails) we couldn't be
    #here otherwise.
    my @issueresults = $csr->fetchrow_array;

    %issuehash = (text => $issueresults[ 0], entereddate => $issueresults[ 1],
                  sourcedocid => $issueresults[ 2], 
                  imagecontenttype => $issueresults[ 3],
                  imageextension => $issueresults[ 4], 
                  page => $issueresults[ 5],
                  enteredby => $issueresults[ 6], 
                  categoryid => $issueresults[ 9],
                  dateoccurred => $issueresults[10], 
                  siteid => $issueresults[11]);
    my $rc = $csr->finish;

    return(%issuehash);
}

#####################
sub get_issue_image {
#####################
    my $dbh=$_[0];
    my $passedid=$_[1];

    my $imagedata;

    $dbh->{LongReadLen} = $MaxBytesStored;  #constant from the header file
    my $sqlquery = "SELECT image
                    FROM $SCHEMA.issue
                    WHERE issueid = $passedid";
    my $csr = $dbh->prepare($sqlquery);
    my $rv = $csr->execute;

    #A single row will be returned (unless the database fails) we couldn't be
    #here otherwise.
    my @issueresults = $csr->fetchrow_array;

    $imagedata = $issueresults[0];
    my $rc = $csr->finish;

    return($imagedata);
}

########################
sub get_sourcedoc_info {
########################
    my $dbh=$_[0];
    my $passedid=$_[1];

    my %sourcedochash;
    my $sqlquery = "SELECT accessionnum, title, signer, email, areacode, 
                           phonenumber, TO_CHAR(documentdate, 'MM/DD/YYYY'), 
                           organizationid, 'null'
                    FROM $SCHEMA.sourcedoc
                    WHERE sourcedocid = $passedid";
    my $csr = $dbh->prepare($sqlquery);
    my $rv = $csr->execute;

    #A single row will be returned (unless the database fails) we couldn't be
    #here otherwise.
    my @sourcedocresults = $csr->fetchrow_array;

    %sourcedochash = (accessionnum => $sourcedocresults[ 0], 
                      title => $sourcedocresults[ 1],
                      signer => $sourcedocresults[ 2], 
                      email => $sourcedocresults[ 3],
                      areacode => $sourcedocresults[ 4], 
                      phonenumber => $sourcedocresults[ 5],
                      documentdate => $sourcedocresults[ 6], 
                      organizationid => $sourcedocresults[ 7]);
    my $rc = $csr->finish;

    return(%sourcedochash);
}

#########################
sub lookup_role_by_name {
#########################
    my $dbh=$_[0];
    my $rolename = $_[1];

    my $sqlstring = "SELECT roleid FROM $SCHEMA.role WHERE description = '$rolename'";
    my $csr=$dbh->prepare($sqlstring);
    my $rv=$csr->execute;

    # should return 1 row with 1 column which holds the id
    my @roleid=$csr->fetchrow_array;
    my $rc = $csr->finish;

    return ($roleid[0]);
}

#########################
sub get_commitment_info {
#########################
    my $dbh=$_[0];
    my $passedid=$_[1];

    my %commitmenthash;
    $dbh->{LongReadLen} = $MaxBytesStored;  #constant from the header file
    my $sqlquery = "SELECT TO_CHAR(duedate, 'MM/DD/YYYY'), statusid,
                           TO_CHAR(commitdate, 'MM/DD/YYYY'), 'NULL', estimate,
                           functionalrecommend, 'NULL', text, 'null',
                           rejectionrationale, resubmitrationale, actionstaken,
                           actionsummary, actionplan, cmrecommendation, 
                           to_char(closeddate,'MM/DD/YYYY'),
                           controlaccountid, issueid, approver, 'NULL',
                           updatedby, commitmentlevelid, oldid, 
                           primarydiscipline, 'NULL', siteid, 
                           imageextension, imagecontenttype, 'NULL', 
                           to_char(fulfilldate, 'MM/DD/YYYY'), 'NULL', 
                           externalid, lleadid, managerid, doemanagerid,
                           to_char(dateduetonrc,'MM/DD/YYYY')
                    FROM $SCHEMA.commitment
                    WHERE commitmentid = $passedid";
    my $csr = $dbh->prepare($sqlquery);
    my $rv = $csr->execute;

    #A single row will be returned (unless the database fails) we couldn't be
    #here otherwise.
    my @results = $csr->fetchrow_array;
    %commitmenthash = (duedate => $results[ 0], statusid => $results[ 1],
                       commitdate => $results[ 2], estimate => $results[ 4], 
                       functionalrecommend => $results[ 5],
                       text => $results[ 7],
                       rejectionrationale => $results[ 9],
                       resubmitrationale => $results[10], 
                       actionstaken => $results[11],
                       actionsummary => $results[12], 
                       actionplan => $results[13],
                       cmrecommendation => $results[14], 
                       closeddate => $results[15],
                       controlaccountid => $results[16],
                       issueid => $results[17], approver => $results[18],
                       updatedby => $results[20],
                       commitmentlevelid => $results[21], oldid=> $results[22],
                       primarydiscipline => $results[23], 
                       siteid => $results[25], imageextension => $results[26],
                       imagecontenttype => $results[27], 
                       fulfilldate => $results[29], rssfactor => $results[30],
                       externalid => $results[31], lleadid => $results[32],
                       managerid => $results[33],
                       doemanagerid => $results[34],
                       dateduetonrc => $results[35]);
    my $rc = $csr->finish;
 
    return(%commitmenthash);
}

##############################
sub get_commitmentlevel_info {
##############################
    my $dbh=$_[0];
    my $passedid=$_[1];

    my %commitmentlevelhash;
    my $sqlquery = "SELECT description, definition, isactive
                    FROM $SCHEMA.commitmentlevel
                    WHERE commitmentlevelid = $passedid";
    my $csr = $dbh->prepare($sqlquery);
    my $rv = $csr->execute;

    #A single row will be returned (unless the database fails) we couldn't be
    #here otherwise.
    my @commitmentlevelresults = $csr->fetchrow_array;

    %commitmentlevelhash = (description => $commitmentlevelresults[ 0],
                            definition  => $commitmentlevelresults[ 1],
                            isactive    => $commitmentlevelresults[ 2]);
    my $rc = $csr->finish;

    return(%commitmentlevelhash);
}

###################
sub get_role_info {
###################
    my $dbh=$_[0];
    my $passedid=$_[1];

    my %rolehash;
    my $sqlquery = "SELECT description, dependson, isactive
                    FROM $SCHEMA.role
                    WHERE roleid = $passedid";
    my $csr = $dbh->prepare($sqlquery);
    my $rv = $csr->execute;

    #A single row will be returned (unless the database fails) we couldn't be
    #here otherwise.
    my @roleresults = $csr->fetchrow_array;

    %rolehash = (description => $roleresults[ 0],
                 dependson => $roleresults[ 1],
                 isactive => $roleresults[ 2]);
    my $rc = $csr->finish;

    return(%rolehash);
}

#############################
sub get_default_role_values {
#############################
    my $dbh=$_[0];
    my $roleid=$_[1];
    my $siteid=$_[2];
    my $dependson=$_[3];
    my $dependid=$_[4];

    my $roletablename = 'Default' . (($dependson) ? $dependson : 'site') . 'role';
    my %defaultrolehash;
    my $sqlquery = "SELECT usersid
                    FROM $SCHEMA.$roletablename
                    WHERE roleid = $roleid AND 
                          siteid = $siteid" . (($dependson) ? " AND " . $dependson . "id = $dependid" : '');
    my $csr = $dbh->prepare($sqlquery);
    my $rv = $csr->execute;

    #A single row will be returned (unless the database fails) we couldn't be
    #here otherwise.
    my @defaultroleresults = $csr->fetchrow_array;

    %defaultrolehash = (usersid => $defaultroleresults[ 0]);
    my $rc = $csr->finish;

    return(%defaultrolehash);
}

###########################
sub get_products_affected {
###########################
    my $dbh=$_[0];
    my $commitmentid=$_[1];

    my @productarray;
    my $tempproduct;

    my $sqlquery = "SELECT productid
                    FROM $SCHEMA.productaffected
                    WHERE commitmentid = $commitmentid";
    my $csr = $dbh->prepare($sqlquery);
    my $rv = $csr->execute;

    #A list of rows with one element each will be returned.
    while ($tempproduct = ($csr->fetchrow_array)[0]) {
        @productarray = (@productarray, $tempproduct);
    }
    my $rc = $csr->finish;

    return(@productarray);
}

#####################
sub get_final_image {
#####################
    my $dbh=$_[0];
    my $passedid=$_[1];

    my $imagedata;

    $dbh->{LongReadLen} = $MaxBytesStored;  #constant from the header file
    my $sqlquery = "SELECT closingdocimage
                    FROM $SCHEMA.commitment
                    WHERE commitmentid = $passedid";
    my $csr = $dbh->prepare($sqlquery);
    my $rv = $csr->execute;

    #A single row will be returned (unless the database fails) we couldn't be
    #here otherwise.
    my @commitmentresults = $csr->fetchrow_array;
    $imagedata = $commitmentresults[0];
    my $rc = $csr->finish;

    return($imagedata);
}

#################################
sub lookup_response_information {
#################################
    my $dbh=$_[0];
    my $commitmentid=$_[1];
    my $responseid= ($_[2]) ? $_[2] : "";   # optional - If not included, the first match will be returned.
    my $final = $_[3];

    my %responsehash;
    $dbh->{LongReadLen} = $MaxBytesStored;  #constant from the header file
    my $sqlquery = "SELECT resp.responseid, resp.text, 
                           TO_CHAR(resp.writtendate, 'MM/DD/YYYY'),
                           lett.letterid, lett.accessionnum, 
                           TO_CHAR(lett.sentdate, 'MM/DD/YYYY'), 
                           lett.addressee,
                           TO_CHAR(lett.signeddate, 'MM/DD/YYYY'), 
                           lett.organizationid, lett.signer
                    FROM $SCHEMA.response resp, $SCHEMA.letter lett
                    WHERE (resp.letterid = lett.letterid) 
                          AND (resp.commitmentid = $commitmentid)";
    $sqlquery .= ($responseid) ? " AND (resp.responseid = $responseid)" : "";
    $sqlquery .= ($final) ? " and resp.isfirst = 'F'" : " and resp.isfirst = 'T'";
    $sqlquery .= " ORDER BY responseid";
    print "\n\n<!-- $sqlquery -->\n\n";
    my $csr = $dbh->prepare($sqlquery);
    my $rv = $csr->execute;

    #A single row will be returned (unless the database fails) we couldn't be
    #here otherwise.
    my @responseresults = $csr->fetchrow_array;

    %responsehash = (responseid => $responseresults[ 0], 
                     text => $responseresults[ 1],
                     writtendate => $responseresults[ 2], 
                     letterid => $responseresults[ 3],
                     accessionnum => $responseresults[ 4], 
                     sentdate => $responseresults[ 5],
                     addressee => $responseresults[ 6], 
                     signeddate => $responseresults[ 7],
                     organizationid => $responseresults[ 8], 
                     signer => $responseresults[ 9]);
    my $rc = $csr->finish;

    return(%responsehash);
}

###############################
sub lookup_letter_information {
###############################
    my $dbh=$_[0];
    my $letterid=$_[1];

    my %letterhash;
    $dbh->{LongReadLen} = $MaxBytesStored;  #constant from the header file
    my $sqlquery = "SELECT accessionnum, TO_CHAR(sentdate, 'MM/DD/YYYY'), 
                           addressee, TO_CHAR(signeddate, 'MM/DD/YYYY'), 
                           organizationid, signer
                    FROM $SCHEMA.letter lett
                    WHERE (letterid = $letterid)";
    print "\n\n<!-- $sqlquery -->\n\n";
    my $csr = $dbh->prepare($sqlquery);
    my $rv = $csr->execute;

    #A single row will be returned (unless the database fails) we couldn't be
    #here otherwise.
    my @letterresults = $csr->fetchrow_array;

    %letterhash = (accessionnum => $letterresults[ 0], 
                   sentdate => $letterresults[ 1],
                   addressee => $letterresults[ 2], 
                   signeddate => $letterresults[ 3],
                   organizationid => $letterresults[ 4], 
                   signer => $letterresults[ 5]);
    my $rc = $csr->finish;
 
    return(%letterhash);
}

1; #return true
