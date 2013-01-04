# Library of utilities routines for the ONCS
#
#
# $Source$
#
# $Revision$
#
# $Date$
#
# $Author$
#
# $Locker$
#
# $Log$
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

@EXPORT = qw (&get_maximum_id &get_next_id &make_username &get_user_info &get_wbs_info &get_org_info
              &get_site_info &get_issue_info &get_sourcedoc_info &lookup_role_by_name &get_commitment_info
              &get_issue_image &get_commitmentlevel_info &get_role_info &get_default_role_values);
@EXPORT_OK = qw(&get_maximum_id &get_next_id &make_username &get_user_info &get_wbs_info &get_org_info
                &get_site_info &get_issue_info &get_sourcedoc_info &lookup_role_by_name &get_commitment_info
                &get_issue_image &get_commitmentlevel_info &get_role_info &get_default_role_values);
%EXPORT_TAGS =(
    Functions => [qw(&get_maximum_id &get_next_id &make_username &get_user_info &get_wbs_info &get_org_info
                     &get_site_info &get_issue_info &get_sourcedoc_info &lookup_role_by_name &get_commitment_info
                     &get_issue_image &get_commitmentlevel_info &get_role_info &get_default_role_values) ]
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
# (%wbshash) = &get_wbs_info( (database handle), ("changerequestnumber . controlaccountid") )
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

################

sub get_maximum_id
  {
  my $dbh=$_[0];
  my $tablename = $_[1];

  # create select
  my $sqlstring = "SELECT MAX(" . $tablename . "id)
                   FROM $SCHEMA.$tablename";

  # create cursor to execute the query
  my $csr=$dbh->prepare($sqlstring);
  my $rv=$csr->execute;

  # max will return 1 row with 1 column which holds the largest value
  my @maxvalue=$csr->fetchrow_array;

  # close the cursor
  my $rc = $csr->finish;

  return ($maxvalue[0]);
  }

###############

sub get_next_id
  {
  my $dbh=$_[0];
  my $tablename = $_[1];

  my $sqlstring;
  my $csr;
  my $rv;
  my @nextvalue;
  my $rc;

  # create select
  $sqlstring = "SELECT $SCHEMA.$tablename" . "ID_SEQ.NEXTVAL FROM DUAL";

  # create cursor to execute the query
  $csr=$dbh->prepare($sqlstring);
  $rv=$csr->execute;

  # select will return 1 row with 1 column which holds the next sequence value.
  @nextvalue=$csr->fetchrow_array;

  # close the cursor
  $rc = $csr->finish;

  return ($nextvalue[0]);
  }

###############

sub make_username
  {
  my $dbh = $_[0];
  my $lastname = uc($_[1]);
  my $firstname = uc($_[2]);

  # remove single quotes from the first and last names
  $lastname =~ s/'//g;
  $firstname =~ s/'//g;

  my $usernamestring = substr($lastname, 0, 7);
  $usernamestring .= substr($firstname, 0, (8 - length($usernamestring)));

  my $usernamestringlength = length($usernamestring);

  # prepare sql query to count names which match
  my $sqlquery = "SELECT COUNT(username)
                  FROM $SCHEMA.users
                  WHERE SUBSTR(username, 1, $usernamestringlength) = '$usernamestring'";

  # make a cursor to extract the count
  my $csr = $dbh->prepare($sqlquery);
  my $rv = $csr->execute;

  my @usernamesuffix = $csr->fetchrow_array;
  $usernamesuffix[0] = '00'.$usernamesuffix[0];

  # discard the cursor
  my $rc = $csr->finish;

  return($usernamestring . substr($usernamesuffix[0], -2));
  }


###########

sub get_user_info
  {
  my $dbh=$_[0];
  my $passedid=$_[1];

  my %usershash;

  # setup a cursor to read the information
  my $sqlquery = "SELECT lastname, firstname, areacode, phonenumber,
               extension, email, isactive, siteid, username, password
               FROM $SCHEMA.users
               WHERE usersid = $passedid";
  #print "$sqlquery<br>\n";
  my $csr = $dbh->prepare($sqlquery);
  my $rv = $csr->execute;

  #A single row will be returned (unless the database fails) we couldn't be
  #here otherwise.
  my @userresults = $csr->fetchrow_array;

  %usershash = (lastname     => $userresults[0], firstname   => $userresults[1],
                areacode     => $userresults[2], phonenumber => $userresults[3],
                extension    => $userresults[4], email       => $userresults[5],
                isactive     => $userresults[6], siteid      => $userresults[7],
                thisusername => $userresults[8], password    => $userresults[9]);

  #discard the 'cursor' we are done with it
  my $rc = $csr->finish;

  return(%usershash);
  }

####################


sub get_wbs_info
  {
  my $dbh=$_[0];
  my $thiswbs=$_[1];

  $thiswbs =~ m/ \. /g;
  my $changerequestnum = $`;
  my $controlaccountid = $';
  #print "$changerequestnum  ,,,, $controlaccountid<br>\n";
  my %wbshash;

  # setup a cursor to read the information
  my $sqlquery = "SELECT description, pointofcontact, isactive
               FROM $SCHEMA.workbreakdownstructure
               WHERE changerequestnum = '$changerequestnum'
               AND   controlaccountid = '$controlaccountid'";
  #print "$sqlquery<br>\n";
  my $csr = $dbh->prepare($sqlquery);
  my $rv = $csr->execute;

  #A single row will be returned (unless the database fails) we couldn't be
  #here otherwise.
  my @wbsresults = $csr->fetchrow_array;

  %wbshash = (changerequestnum => $changerequestnum, controlaccountid => $controlaccountid,
               description      => $wbsresults[0],    pointofcontact   => $wbsresults[1],
              isactive         => $wbsresults[2]);

  #discard the 'cursor' we are done with it
  my $rc = $csr->finish;

  return(%wbshash);
  }

#####################

sub get_org_info
  {
  my $dbh=$_[0];
  my $passedid=$_[1];

  my %orghash;

  # setup a cursor to read the information
  my $sqlquery = "SELECT name, address1, address2, city, state, zipcode, country,
               areacode, phonenumber, extension, contact, department, division,
               faxareacode, faxnumber, parentorg
               FROM $SCHEMA.organization
               WHERE organizationid = $passedid";
  #print "$sqlquery<br>\n";
  my $csr = $dbh->prepare($sqlquery);
  my $rv = $csr->execute;

  #A single row will be returned (unless the database fails) we couldn't be
  #here otherwise.
  my @orgresults = $csr->fetchrow_array;

  %orghash = (name        => $orgresults[ 0], address1    => $orgresults[ 1],
              address2    => $orgresults[ 2], city        => $orgresults[ 3],
              state       => $orgresults[ 4], zipcode     => $orgresults[ 5],
              country     => $orgresults[ 6], areacode    => $orgresults[ 7],
              phonenumber => $orgresults[ 8], extension   => $orgresults[ 9],
              contact     => $orgresults[10], department  => $orgresults[11],
              division    => $orgresults[12], faxareacode => $orgresults[13],
              faxnumber   => $orgresults[14], parentorg   => $orgresults[15]);

  #discard the 'cursor' we are done with it
  my $rc = $csr->finish;

  return(%orghash);
  }


#####################

sub get_site_info
  {
  my $dbh=$_[0];
  my $passedid=$_[1];

  my %sitehash;

  # setup a cursor to read the information
  my $sqlquery = "SELECT name, city, state
               FROM $SCHEMA.site
               WHERE siteid = $passedid";
  #print "$sqlquery<br>\n";
  my $csr = $dbh->prepare($sqlquery);
  my $rv = $csr->execute;

  #A single row will be returned (unless the database fails) we couldn't be
  #here otherwise.
  my @siteresults = $csr->fetchrow_array;

  %sitehash = (name => $siteresults[ 0], city => $siteresults[ 1], state => $siteresults[ 2]);

  #discard the 'cursor' we are done with it
  my $rc = $csr->finish;

  return(%sitehash);
  }


#####################

sub get_issue_info
  {
  my $dbh=$_[0];
  my $passedid=$_[1];

  my %issuehash;

  $dbh->{LongReadLen} = $MaxBytesStored;  #constant from the header file
  # setup a cursor to read the information
  my $sqlquery = "SELECT issue.text, TO_CHAR(issue.entereddate, 'MM/DD/YYYY'),
                  issue.sourcedocid, issue.imagecontenttype, issue.imageextension, 
                  issue.page, ic.issuetypeid, issue.enteredby, issue.primarydiscipline,  
                  issue.secondarydiscipline, issue.categoryid
                  FROM $SCHEMA.issue, $SCHEMA.issueclassify ic
                  WHERE issue.issueid = $passedid AND issue.issueid = ic.issueid";
#  print "$sqlquery<br>\n";
  my $csr = $dbh->prepare($sqlquery);
  my $rv = $csr->execute;

  #A single row will be returned (unless the database fails) we couldn't be
  #here otherwise.
  my @issueresults = $csr->fetchrow_array;

  %issuehash = (text                => $issueresults[ 0], entereddate       => $issueresults[ 1],
                sourcedocid         => $issueresults[ 2],
                imagecontenttype    => $issueresults[ 3], imageextension    => $issueresults[ 4],
                page                => $issueresults[ 5], issuetypeid       => $issueresults[ 6],
                enteredby           => $issueresults[ 7], primarydiscipline => $issueresults[ 8],
                secondarydiscipline => $issueresults[ 9], categoryid        => $issueresults[10]);

  #discard the 'cursor' we are done with it
  my $rc = $csr->finish;

  return(%issuehash);
  }

#####################

sub get_issue_image
  {
  my $dbh=$_[0];
  my $passedid=$_[1];

  my $imagedata;

  $dbh->{LongReadLen} = $MaxBytesStored;  #constant from the header file
  # setup a cursor to read the information
  my $sqlquery = "SELECT image
                  FROM $SCHEMA.issue
                  WHERE issueid = $passedid";
#  print "$sqlquery<br>\n";
  my $csr = $dbh->prepare($sqlquery);
  my $rv = $csr->execute;

  #A single row will be returned (unless the database fails) we couldn't be
  #here otherwise.
  my @issueresults = $csr->fetchrow_array;

  $imagedata = $issueresults[0];

  #discard the 'cursor' we are done with it
  my $rc = $csr->finish;

  return($imagedata);
  }

#####################

sub get_sourcedoc_info
  {
  my $dbh=$_[0];
  my $passedid=$_[1];

  my %sourcedochash;

  # setup a cursor to read the information
  my $sqlquery = "SELECT accessionnum, title, signer, email, areacode, phonenumber,
                  TO_CHAR(documentdate, 'MM/DD/YYYY'), organizationid, categoryid
                  FROM $SCHEMA.sourcedoc
                  WHERE sourcedocid = $passedid";
#  print "$sqlquery<br>\n";
  my $csr = $dbh->prepare($sqlquery);
  my $rv = $csr->execute;

  #A single row will be returned (unless the database fails) we couldn't be
  #here otherwise.
  my @sourcedocresults = $csr->fetchrow_array;

  %sourcedochash = (accessionnum => $sourcedocresults[ 0], title          => $sourcedocresults[ 1],
                    signer       => $sourcedocresults[ 2], email          => $sourcedocresults[ 3],
                    areacode     => $sourcedocresults[ 4], phonenumber    => $sourcedocresults[ 5],
                    documentdate => $sourcedocresults[ 6], organizationid => $sourcedocresults[ 7],
                    categoryid   => $sourcedocresults[ 8]);

  #discard the 'cursor' we are done with it
  my $rc = $csr->finish;

  return(%sourcedochash);
  }

################

sub lookup_role_by_name
  {
  my $dbh=$_[0];
  my $rolename = $_[1];

  # create select
  my $sqlstring = "SELECT roleid
                   FROM $SCHEMA.role
                   WHERE description = '$rolename'";

  # create cursor to execute the query
  my $csr=$dbh->prepare($sqlstring);
  my $rv=$csr->execute;

  # should return 1 row with 1 column which holds the id
  my @roleid=$csr->fetchrow_array;

  # close the cursor
  my $rc = $csr->finish;

  return ($roleid[0]);
  }


#####################

sub get_commitment_info
  {
  my $dbh=$_[0];
  my $passedid=$_[1];

  my %commitmenthash;

  $dbh->{LongReadLen} = $MaxBytesStored;  #constant from the header file
  # setup a cursor to read the information
  my $sqlquery = "SELECT TO_CHAR(duedate, 'MM/DD/YYYY'), statusid,
                  TO_CHAR(commitdate, 'MM/DD/YYYY'), criticalpath, estimate,
                  functionalrecommend, commitmentrationale, text, comments,
                  rejectionrationale, resubmitrationale, actionstaken, 
                  actionsummary, actionplan, cmrecommendation, closeddate, 
                  changerequestnum, controlaccountid, issueid, approver, replacedby,
                  updatedby, commitmentlevelid, oldid, primarydiscipline, secondarydiscipline 
                  FROM $SCHEMA.commitment
                  WHERE commitmentid = $passedid";
#  print "$sqlquery<br>\n";
  my $csr = $dbh->prepare($sqlquery);
  my $rv = $csr->execute;

  #A single row will be returned (unless the database fails) we couldn't be
  #here otherwise.
  my @results = $csr->fetchrow_array;

  %commitmenthash = (duedate             => $results[ 0], statusid            => $results[ 1],
                     commitdate          => $results[ 2], criticalpath        => $results[ 3],
                     estimate            => $results[ 4], functionalrecommend => $results[ 5],
                     commitmentrationale => $results[ 6], text                => $results[ 7],
                     comments            => $results[ 8], rejectionrationale  => $results[ 9],
                     resubmitrationale   => $results[10], actionstaken        => $results[11],
                     actionsummary       => $results[12], actionplan          => $results[13],
                     cmrecommendation    => $results[14], closeddate          => $results[15],
                     changerequestnum    => $results[16], controlaccountid    => $results[17],
                     issueid             => $results[18], approver            => $results[19],
                     replacedby          => $results[20], updatedby           => $results[21],
                     commitmentlevelid   => $results[22], oldid               => $results[23],
                     primarydiscipline   => $results[24], secondarydiscipline => $results[25]);

  #discard the 'cursor' we are done with it
  my $rc = $csr->finish;

  return(%commitmenthash);
  }

  
#####################

sub get_commitmentlevel_info
  {
  my $dbh=$_[0];
  my $passedid=$_[1];

  my %commitmentlevelhash;

  # setup a cursor to read the information
  my $sqlquery = "SELECT description, definition, isactive
               FROM $SCHEMA.commitmentlevel
               WHERE commitmentlevelid = $passedid";
  #print "$sqlquery<br>\n";
  my $csr = $dbh->prepare($sqlquery);
  my $rv = $csr->execute;

  #A single row will be returned (unless the database fails) we couldn't be
  #here otherwise.
  my @commitmentlevelresults = $csr->fetchrow_array;

  %commitmentlevelhash = (description => $commitmentlevelresults[ 0], 
                          definition  => $commitmentlevelresults[ 1],
                          isactive    => $commitmentlevelresults[ 2]);

  #discard the 'cursor' we are done with it
  my $rc = $csr->finish;

  return(%commitmentlevelhash);
  }


#####################

sub get_role_info
  {
  my $dbh=$_[0];
  my $passedid=$_[1];

  my %rolehash;

  # setup a cursor to read the information
  my $sqlquery = "SELECT description, dependson, isactive
               FROM $SCHEMA.role
               WHERE roleid = $passedid";
  #print "$sqlquery<br>\n";
  my $csr = $dbh->prepare($sqlquery);
  my $rv = $csr->execute;

  #A single row will be returned (unless the database fails) we couldn't be
  #here otherwise.
  my @roleresults = $csr->fetchrow_array;

  %rolehash = (description => $roleresults[ 0], 
               dependson  => $roleresults[ 1],
               isactive    => $roleresults[ 2]);

  #discard the 'cursor' we are done with it
  my $rc = $csr->finish;

  return(%rolehash);
  }

#####################

sub get_default_role_values
  {
  my $dbh=$_[0];
  my $roleid=$_[1];
  my $siteid=$_[2];
  my $dependson=$_[3];
  my $dependid=$_[4];
  
  my $roletablename = 'Default' . (($dependson) ? $dependson : 'site') . 'role';

  my %defaultrolehash;

  # setup a cursor to read the information
  my $sqlquery = "SELECT usersid
               FROM $SCHEMA.$roletablename
               WHERE roleid = $roleid AND siteid = $siteid" . (($dependson) ? " AND " . $dependson . "id = $dependid" : '');
  #print "$sqlquery<br>\n";
  my $csr = $dbh->prepare($sqlquery);
  my $rv = $csr->execute;

  #A single row will be returned (unless the database fails) we couldn't be
  #here otherwise.
  my @defaultroleresults = $csr->fetchrow_array;

  %defaultrolehash = (usersid => $defaultroleresults[ 0]);

  #discard the 'cursor' we are done with it
  my $rc = $csr->finish;

  return(%defaultrolehash);
  }


1; #return true