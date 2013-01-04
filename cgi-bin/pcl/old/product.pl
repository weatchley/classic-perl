#!/usr/local/bin/perl -w
#
# $Source: /data/dev/rcs/scm/perl/RCS/product.pl,v $
#
# $Revision: 1.3 $
#
# $Date: 2002/09/27 00:07:20 $
#
# $Author: starkeyj $
#
# $Locker: starkeyj $
#
# $Log: product.pl,v $
# Revision 1.3  2002/09/27 00:07:20  starkeyj
# deprecated.... superceded by UIProducts, products, and DBProducts
#
# Revision 1.2  2002/09/19 01:30:54  starkeyj
# started creating the 'create product' form
#
# Revision 1.1  2002/09/17 20:38:21  starkeyj
# Initial revision
#
#
#
#

use strict;
use integer;
use SharedHeader qw(:Constants);
use CGI qw(param);
use DBShared qw(:Functions);
#use UI_Widgets qw(:Functions);
use UI_Product qw(:Functions);
use Tie::IxHash;
use DBI;
use DBD::Oracle qw(:ora_types);

my $mycgi = new CGI;
my $schema = (defined($mycgi->param("schema"))) ? $mycgi->param("schema") : $ENV{'SCHEMA'};
#print STDERR "$schema\n";
$ENV{SCRIPT_NAME} =~ m%(.*/)(.*)\..*$%;
my $path = $1;
my $form = $2;
my $urllocation;
my $command = (defined ($mycgi -> param("command"))) ? $mycgi -> param("command") : "browse";
my $username = (defined($mycgi->param("username"))) ? $mycgi->param("username") : "";
my $password = (defined($mycgi->param("password"))) ? $mycgi->param("password") : "";
my $userid = (defined($mycgi->param("userid"))) ? $mycgi->param("userid") : "";
my $projectID = defined($mycgi->param("projectID")) ? $mycgi->param("projectID") : 0;
my $error = "";
my $origschema = (defined($mycgi->param("origschema"))) ? $mycgi->param("origschema") : "PCL"; 
my $dbh = &db_connect(server => "ydoradev");

#&checkLogin ($username, $userid, $schema);

#########
if ($command eq 'create_product') {
    my %args = (
        title => 'Procedure Management',
        displayTitle => 'T',
        @_,
    );
	print &productFormHeader($userid,$username,$schema);
   print &doCreateProductForm(dbh => $dbh,userid => $userid);
}
#########
elsif ($command eq 'create_new_product') {
	#my $projectID = defined($mycgi->param("projectID")) ? $mycgi->param("projectID") : 0;
	print &productFormHeader($userid,$username,$schema,$projectID);
   print &createNewProduct($dbh,$userid,$username);
}
#########
elsif ($command eq 'create_new_version') {
	print &productFormHeader($userid,$username,$schema);
   print &createNewVersion($dbh,$userid,$username);
}
#########
elsif ($command eq 'release_product') {
	print &productFormHeader($userid,$username,$schema);
   print &releaseProduct($dbh,$userid,$username);
}

&db_disconnect($dbh);   

