#!/usr/local/bin/newperl -w

# CGI for Displaying documents for the CRD
#
# $Source: /data/dev/rcs/crd/perl/RCS/display_image.pl,v $
#
# $Revision: 1.19 $
#
# $Date: 2001/11/06 22:51:52 $
#
# $Author: atchleyb $
#
# $Locker:  $
#
# $Log: display_image.pl,v $
# Revision 1.19  2001/11/06 22:51:52  atchleyb
# changed alert box code to handle single quotes
#
# Revision 1.18  2000/12/15 18:42:41  atchleyb
# added data verification to test if commentid contained the string "undefined"
#
# Revision 1.17  2000/04/24 21:26:56  atchleyb
# moidified to display new images in a new window
#
# Revision 1.16  2000/04/14 20:45:27  atchleyb
# Modified to always load image to disk from db or o drive
# Modified to have the user confirm that they wish to view images over one megabyte in size.
#
# Revision 1.15  2000/02/10 17:30:18  atchleyb
# removed form-verify.pl
#
# Revision 1.14  2000/01/14 23:40:09  atchleyb
# replaced all references to EIS with $crdtype
# changed file paths to use $CRDFullDocPath
# changed getbracketedimage to file_utilities.pl
#
# Revision 1.13  1999/12/02 19:44:20  atchleyb
# fixed an invalid errormessage
#
# Revision 1.12  1999/12/02 19:06:46  atchleyb
# modified to display scanned image if bracketed image not available
#
# Revision 1.11  1999/10/27 17:06:08  atchleyb
# removed header_bar function
#
# Revision 1.10  1999/10/08 16:03:11  atchleyb
# reenabled code to goto bookmarked comment in pdf file
#
# Revision 1.9  1999/10/01 22:55:52  atchleyb
# changed display scanned section to not put '-scanned' in the file name.
#
# Revision 1.8  1999/09/28 16:51:22  atchleyb
# modified to use a temp directory instead of the main documents directory for scanned images
#
# Revision 1.7  1999/09/02 23:26:55  atchleyb
# commented out all raiseerror lines
#
# Revision 1.6  1999/08/09 20:33:00  atchleyb
# changed location of check_login function
#
# Revision 1.5  1999/08/04 22:40:05  atchleyb
# added raiseerror for eval blocks
#
# Revision 1.4  1999/08/02 22:52:01  atchleyb
# fixed prob with newline in error message
#
# Revision 1.3  1999/08/02 21:31:49  atchleyb
# updated error handling, now using errorMessage routine
#
# Revision 1.2  1999/08/02 02:37:33  mccartym
# Reversed order of parameters on call to headerBar()
#
# Revision 1.1  1999/07/30 20:29:10  atchleyb
# Initial revision
#
#
#
use strict;
#use integer;
#
$| = 1;
#
# get all required libraries and modules
use CRD_Header qw(:Constants);
use UI_Widgets qw(:Functions);
use DB_Utilities_Lib qw(:Functions);

use DBI;
use DBD::Oracle qw(:ora_types);
use CGI;

# create cgi object for processing
my $crdcgi = new CGI;

# change any environment variables here
# set schema name
my $schema = $crdcgi->param("schema");

# Get username from the previous form for use later
my $username = $crdcgi->param("username");
my $userid = $crdcgi->param("userid");
&checkLogin ($username, $userid, $schema);

# tell the browser that this is an html page using the header method
print $crdcgi->header('text/html');

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
###################################################################################################################################

# output page header
print "<html>\n";
print "<head>\n";
print "<title>CRD Display Document</title>\n";
print "<!-- include external javascript code -->\n";
print "   <script src=$CRDJavaScriptPath/utilities.js></script>\n";
#print "   <script src=$CRDJavaScriptPath/widgets.js></script>\n";
print " \n";
print "<!-- declare javascript functions unique to this form -->\n";
print " \n";
print "</head>\n";
print "<body background=$CRDImagePath/background.gif text=#000099 link=#0000ff vlink=#0000ff alink=#0000ff topmargin=0 leftmargin=0>\n";

# set default font atributes
print "<font face=\"$CRDFontFace\" color=$CRDFontColor>\n";

my $command='';
my $documentid='';
my $commentid='';
my $version='';
my $sqlquery='';
my $csr;
my $status;
my @values;
my $filepath = $CRDFullDocPath;
my $remote_path='';
my $filename='';
my $localfilename='';
my $fullfilename='';
my $filedata='';
my $message='';
my $urllocation='';
my @fileStats;

# Connect to the oracle database and generate an object 'handle' to the database
my $dbh = db_connect();

# set up form for whole page
print "<br><center>\n";
print "<table border=0 width=750><tr><td>\n";

# setup form for the page (use filename_form as name of form)
print "<form name=myform action=$ENV{SCRIPT_NAME} method=post>\n";
# use a hidden field to tell the next cgi what to do
print "<input type=hidden name=command value=mycommand>\n";
# use hidden fields to keep track of the user.  Populate them with the username and the userid
print "<input type=hidden name=username value=$username>\n";
print "<input type=hidden name=userid value=$userid>\n";
print "<input type=hidden name=schema value=$schema>\n";

$command = $crdcgi->param('command');
if (!(defined($command))) { $command='none'; }
if ($command eq "pdf" || $command eq "redline") {
    $documentid = $crdcgi->param('documentid');
    $commentid = $crdcgi->param('commentid');
    if ($command eq 'pdf') {
        $filename = "$CRDType" . lpadzero($documentid,6) . ".pdf";
    } elsif ($command eq 'redline') {
        $version = $crdcgi->param('version');
        $filename = "$CRDType" . lpadzero($documentid,6) . "-" . lpadzero($commentid, 4) . "-" . lpadzero($version, 3) . ".doc";
    }
    print "<input type=hidden name=filename value=$filename>\n";
    # get file from db and save it on the server
    $dbh->{LongReadLen} = 100000000;
    if ($command eq 'pdf') {
        $sqlquery = "SELECT image FROM $schema.document WHERE id = $documentid";
    } else {
        $sqlquery = "SELECT redlinedtext FROM $schema.response_version WHERE (document = $documentid) AND (commentnum = $commentid) AND (version = $version)";
    }
    eval {
        $csr = $dbh->prepare($sqlquery);
        $status = $csr->execute;
        @values = $csr->fetchrow_array;
        $csr->finish;
    };
    if ($status && $#values >=0 && defined($values[0]) && !($@)) {
        # save read file to webserver
        $filedata = $values[0];
        if (open (FH2, "| ./File_Utilities.pl --command=writeFile --fullFilePath=$CRDFullDocPath/$filename --protection=0777")) {
            print FH2 $filedata;
            close (FH2);
            @fileStats = stat "$CRDFullDocPath/$filename";
            #$status = chmod 0775, "$CRDFullDocPath/$filename";
            
            # display the file
            $urllocation = "$CRDDocPath/$filename";
            if($command eq 'pdf' && defined($commentid) && $commentid ne 'undefined') { $urllocation .= "#$commentid"; }
            
        } else {
            $message = errorMessage($dbh,$username,$userid,$schema,"write display image $filename to server.",$@);
        }
    } else {
        #$message = "Not found in the database";
        if ($command eq "pdf") {
            $command = "scanned";
        } else {
            $message = errorMessage($dbh,$username,$userid,$schema,"display image $filename, not found in database.",$@);
        }
    }


}
if ($command eq "pdf" || $command eq "redline") {
  # do nothing
} elsif ($command eq "scanned") {
    # display a scanned image ---------------------------------------
    $documentid = $crdcgi->param('id');
    if (defined($documentid)) {
        if ($documentid <= 0) {
            $documentid = $crdcgi->param('documentid');
        }
    } else {
        $documentid = $crdcgi->param('documentid');
    }

    $filename = "$CRDType" . lpadzero($documentid,6) . ".pdf";
    $localfilename = "$CRDType" . lpadzero($documentid,6) . ".pdf";
    if ($CRDProductionStatus == 0) {
        $remote_path = $CRDType . "_CD_Images\\\\DevScanned";
    } else {
        $remote_path = $CRDType . "_CD_Images\\\\Scanned";
    }
    $CRDDocPath =~ s/bracketed/scanned/;
    $CRDFullDocPath =~ s/bracketed/scanned/;
    #$status = getBracketedImageFile(remote_path=>$remote_path,local_path=>"$CRDFullDocPath/temp",image_file=>$filename,local_file=>$localfilename);
    if (open (FH2, "./File_Utilities.pl --command=sambaCopy --localPath=$CRDFullDocPath --remotePath=$remote_path --imageFile=$filename --localFile=$localfilename --protection=0777 |")) {
        $status = <FH2>;
        close FH2;
        if ($status == 1) {
            $fullfilename = $filepath . "/temp/" . $localfilename;
            #chmod 0777, "$CRDFullDocPath/$localfilename";
            # display the file
            @fileStats = stat "$CRDFullDocPath/$localfilename";
            $urllocation = "$CRDDocPath/$localfilename";
        } elsif ($status == 0) {
            $message = "Error, Scanned image not found for $CRDType" . lpadzero($documentid,6);
            log_error ($dbh,$schema,$userid,$message);
        } else {
            $message = "Error, Problem getting scanned image for $CRDType" . lpadzero($documentid,6);
            log_error ($dbh,$schema,$userid,$message);
        }
    } else {
        $message = "Error, Problem getting scanned image for $CRDType" . lpadzero($documentid,6);
        log_error ($dbh,$schema,$userid,$message);
    }

    
} else {
    $message = "Invalid Command: $command";
}

 
#=============================================================================================================

# display any messages generated by the script
print "<script language=javascript><!--\n";
if (defined($message) && $message gt " ") {
    print doAlertBox( text => $message, includeScriptTags => 'F');
}

# send the frame to the requested url
if (defined ($urllocation) && $urllocation gt ' ') {
    # close connection to the oracle database
    db_disconnect($dbh);
    print "   var newurl ='$urllocation';\n";
    print "   var myDate = new Date();\n";
    print "   var winName = myDate.getTime();\n";
    print "   if ($fileStats[7] >= 1048576) {\n";
    print "       if (confirm('Image is " . int($fileStats[7]*100/1048576)/100.0 . "MB, do you wish to display it?')) {\n";
    print "           var newwin = window.open(\"\",winName);\n";
    print "           newwin.creator = self;\n";
    print "           newwin.location=newurl;\n";
    print "       }\n";
    print "   } else {\n";
    print "       var newwin = window.open(\"\",winName);\n";
    print "       newwin.creator = self;\n";
    print "       newwin.location=newurl;\n";
    print "   }\n";

} else {
    db_disconnect($dbh);

    print "   self.close();\n";
}
print "//--></script>\n";

#=============================================================================================================





print "</form>\n";


print "<br><br>\n";

# close table for whole page
print "</td></tr></table></center>\n";

# end font atributes for page
print "</font>\n";

# close connection to the oracle database
db_disconnect($dbh);

print $crdcgi->end_html;
