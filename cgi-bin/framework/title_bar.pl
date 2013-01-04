#!/usr/local/bin/perl -w
#
# title bar
#
# $Source$
# $Revision$
# $Date$
# $Author$
# $Locker$
# $Log$
#
#

# get all required libraries and modules
use SharedHeader qw(:Constants);

use UI_title_bar;

use CGI;
use strict;

my $mycgi = new CGI;

# tell the browser that this is an html page using the header method
#print $mycgi->header('text/html');

$ENV{SCRIPT_NAME} =~ m%(.*/)(.*)\..*$%;
my $path = $1;
my $form = $2;

my $schema = (defined($mycgi->param("schema"))) ? $mycgi->param("schema") : $SCHEMA;

my $title = ((defined($mycgi->param('title'))) ? $mycgi->param('title') : "++");

my $username = ((defined($mycgi->param('username'))) ? $mycgi->param('username') : "None");
my $userid = ((defined($mycgi->param('userid'))) ? $mycgi->param('userid') : "None");

print &displayPage(schema => $schema, title => $title, username => $username, userid => $userid);

