#!/usr/local/bin/newperl -w
# utility to check if similar documents contain comments
# identical to the comments for their parent documents

use integer;
use strict;
use CRD_Header qw(:Constants);
use UI_Widgets qw(:Functions);
use DB_Utilities_Lib qw(:Functions);
use Miscellaneous;
use DBI;
use DBD::Oracle qw(:ora_types);
use CGI qw(param);
my $crdcgi = new CGI;
#my $userid = $crdcgi->param("userid");
#my $username = $crdcgi->param("username");
my $schema = $crdcgi->param("schema");
#&checkLogin ($username, $userid, $schema);
$ENV{SCRIPT_NAME} =~ m%(.*/)(.*)\..*$%;
my $path = $1;
my $form = $2;
my $command = defined($crdcgi->param("command")) ? $crdcgi->param("command") : "";
my $bin = defined($crdcgi->param("bin")) ? $crdcgi->param("bin") : "";
my $searchString = defined($crdcgi->param("searchstring")) ? $crdcgi->param("searchstring") : "";
my $results = "<center>";
my $rows = 0;
my $errorstr = "";
my $checked;
my $dbh = &db_connect();
$dbh->{LongTruncOk} = 1;   # specify whether to fetch whole text or truncated fraction 
$dbh->{LongReadLen} = 10000000;

#########################################

print $crdcgi->header('text/html');

print <<end;
  <html>
  <head>
end
print  "</head>\n\n";
print "<body background=$CRDImagePath/background.gif text=$CRDFontColor link=#0000ff vlink=#0000ff alink=#0000ff topmargin=0 leftmargin=0><center>\n";
# print "<!-- command - $command -->\n";
# print "<!-- id - $documentid -->\n";
print "<font face=$CRDFontFace color=$CRDFontColor>\n";
print "<br><table border=0 width=750>\n";
print "<TR><TD>Some sort of header for the report....<BR></TD></TR>\n";
print "<TR><TD><HR></TD></TR>\n";


#################

my $retrieve = $dbh -> prepare ("select id, dupsimid from document where dupsimstatus = 3");
$retrieve -> execute;

while (my @values = $retrieve -> fetchrow_array){

    my ($simdoc, $pardoc) = @values;
    my ($simcount) = $dbh -> selectrow_array ("select count (*) from comments where document = $simdoc");
    my ($parcount) = $dbh -> selectrow_array ("select count (*) from comments where document = $pardoc");
    
    if ($simcount == $parcount){ # number of comment in similar is the same  
	                         # as number of comments in parent
	my $getsimcomment = $dbh -> prepare ("select commentnum, text from comments where document = $simdoc");

# Do we also need to select bin, changeimpact, and startpage???????

	$getsimcomment -> execute;

	while (my @simcomments = $getsimcomment -> fetchrow_array){

	    my ($simcomnum, $simtext) = @simcomments;
	    my ($partext) = $dbh -> selectrow_array ("select text from comments where document = $pardoc and commentnum = $simcomnum");

#	    if ($simtext eq $partext){
#		# Everything is fine (unless we want to check for bins, etc...)
#		print "<TR><TD>Similar document $simdoc/$simcomnum is identical to parent document $pardoc/$simcomnum</TD></TR>\n";
#	    }
#	    else { # 
	    if ($simtext ne $partext){
		# Error: Parent text and child text do not match
		print "<TR><TD>The text of similar document $simdoc/$simcomnum does not match the text of original document $pardoc/$simcomnum</TD></TR>\n";
	    }
	}
    }
    else {
	# Error: The number of comments in the similar document 
        # is not the same as the number of comments in the 
        # orignal document
	print "<TR><TD>The number of comments in similar document $simdoc does not match the number of comments in original document $pardoc</TD></TR>\n";
    }
}
print "</table>\n";
# print &BuildPrintCommentResponse($username,$userid,$schema,$path);
print "</font>\n</center>\n";
print "<script language=javascript>\n<!--\nvar mytext ='$errorstr';\nalert(unescape(mytext));\n//-->\n</script>\n" if ($errorstr);
print "</body>\n</html>\n";
&db_disconnect($dbh);
exit();


