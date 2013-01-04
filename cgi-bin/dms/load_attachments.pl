#!/usr/local/bin/perl -w
#
# $Source: /data/dev/rcs/dms/perl/RCS/load_attachments.pl,v $
#
# $Revision: 1.2 $
#
# $Date: 2002/11/23 00:16:31 $
#
# $Author: munroeb $
#
# $Locker:  $
#
# $Log: load_attachments.pl,v $
# Revision 1.2  2002/11/23 00:16:31  munroeb
# not in production, never checked into dev!  what is up with that?
#
# Revision 1.1  2002/11/23 00:14:27  munroeb
# Initial revision
#
#
#

use integer;
use strict;
use DMS_Header qw(:Constants);
use UI_Widgets qw(:Functions);
use DB_Utilities_Lib qw(:Functions);
use DBI;
use DBD::Oracle qw(:ora_types);
use CGI qw(param);
use File::Find;
use File::Basename;
my @DIRLIST = ("$DMSFullDocPath/attachments" );
my %mimeTypes = (
    'doc' => "application/msword",
    'dot' => "application/msword",
    'rtf' => "application/msword",
    'xls' => "application/vnd.ms-excel",
    'txt' => "text/plain",
    'ppt' => "application/vnd.ms-powerpoint",
    'pdf' => "application/pdf",
    'docdot' => "application/msword"
);

my $dmscgi = new CGI;
my $dbh = &db_connect();
$| = 1;
my $schema = $SCHEMA;


###################################################################################################################################
sub processFile {
###################################################################################################################################
    # do not process directories
    if (-d) {
    } else {
        my ($base, $dir, $ext) = fileparse($File::Find::name, '\..*');
        #print "Name: $File::Find::name, <br>\nBase: $base, <br>\nDir: $dir, <br>\nExt: $ext<br><br>\n\n";
        my $fileName = $base . $ext;
        my $newFileName = $fileName;
        $newFileName =~ s/&//g;
        $newFileName =~ s/ /_/g;
        chop ($dir);
        my $dID = substr($dir, (rindex($dir,'/')+1));
        $mimeTypes{$ext} = $ext;
        print "Decision ID: $dID, <br>File: <br>$fileName<br>$newFileName";
        #print "<br>$File::Find::name";
        print "<br><br>\n\n";

        open FH1, "<$File::Find::name";
        my $val = "";
        my $rc = read(FH1, $val, 100000000);
        close FH1;

        # load new image into database
        $ext =~ s/\.//g;
        my $mime = $mimeTypes{$ext};
        my $sqlcode = "INSERT INTO $schema.attachments (attachmentid, decisionid, mimetype, attachment, filename) ";
        $sqlcode .= "VALUES ($schema.attachment_id.NEXTVAL,'$dID', '$mime', ?, '$newFileName')";
        print "\n<!-- EXT: $ext, BASE: $base, SQL: $sqlcode -->\n";
        my $csr = $dbh->prepare($sqlcode);
        $csr->bind_param(1, $val, { ora_type=>ORA_BLOB, ora_field=>'attachment'});
        my $status=$csr->execute;
        $dbh->commit;
        $csr->finish;
        undef $val;
    }
}


###################################################################################################################################
###################################################################################################################################
print $dmscgi->header('text/html');
print <<end;
<html>
<head>
</head>
end
my $border = 0;
print "<body background=$DMSImagePath/background.gif text=$DMSFontColor link=#0000ff vlink=#0000ff alink=#0000ff topmargin=0 leftmargin=0>\n";

eval {
    find(\&processFile, @DIRLIST);
};

if ($@) {
    my $message = errorMessage($dbh,'guest',0,$schema,"insert attachments.",$@);
    print doAlertBox( text => $message);
}

print "<br>Extentions<br>\n";
for my $key (sort keys %mimeTypes) {
    print "$key<br>\n";
}


print "</body>\n</html>\n";
db_disconnect($dbh);
exit();
