#!/usr/local/bin/newperl -w

#
# CGI utility for reading a password for CMS
#
# $Source: /usr/local/www/gov.ymp.intradev/rcs/cms/perl/RCS/oracle_connect.pl,v $
# $Revision: 1.4 $
# $Date: 2007/11/23 18:49:06 $
# $Author: atchleyb $
# $Locker:  $
# $Log: oracle_connect.pl,v $
# Revision 1.4  2007/11/23 18:49:06  atchleyb
# CR 31 - removed hardcoded path to root
#
# Revision 1.3  2000/07/25 00:25:17  atchleyb
# changed path for .init file
#
# Revision 1.2  2000/07/06 23:53:08  munroeb
# finished mods to perl scripts.
#
# Revision 1.1  2000/05/19 23:25:13  zepedaj
# Initial revision
#
#

use vars qw ($EGID $GID);
my $CMSProductionStatus = ($ENV{SERVER_STATE} ne "PRODUCTION") ? 0 : 1;
#my $SYSPathRoot = ($CMSProductionStatus) ? "/usr/local/www/gov.ymp.intranet" : "/usr/local/www/gov.ymp.intradev";
my $SYSPathRoot = $ENV{PATH_TO_ROOT};
my $password;
my $filepath = "$SYSPathRoot/data/apps/cms/.init";
my $temp = $EGID;
$EGID = $GID;
if (open (FH, "<$filepath"))
  {
  $password = <FH>;
  chomp $password;
  close (FH);
}
$EGID = $temp;

print "$password\n";
