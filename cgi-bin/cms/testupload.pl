#!/usr/local/bin/newperl -w

use CGI;
#use strict;

$ENV{SCRIPT_NAME} =~ m%(.*/)(.*)\..*$%;
my $path = $1;
my $form = $2;

my $filename;
my $filedata;
my $type;

my $testcgi = new CGI;

print $testcgi->header('text/html');
print <<ENDOFBLOCK;
<html>
<head>
<title>Test File Upload</title>
</head>
<body>
ENDOFBLOCK


if (defined($testcgi->param('processdata'))) {
    $filename = $testcgi->param('image');
    $filedata='';
    while (<$filename>) {
        $filedata .= $_;
    }
    $type = $testcgi->uploadInfo($filename)->{'Content-Type'};
    print "<b>File Name: </b> $filename<br>\n";
    print "<b>File Type:</b> $type<br>\n";
    print "<b>File Data:</b><pre> $filedata</pre><br>\n";
} else {
    print <<ENDOFBLOCK;
    
    <table><tr><td>
    <form name=$form enctype='multipart/form-data' method=post action=$form.pl><br>
    </td></tr><tr><td>
    <input type=hidden name=processdata value=1><br>
    </td></tr><tr><td>
    <input type=file name=image size=50 maxlength=256><br>
    </td></tr><tr><td>
    <input type=button name=mysubmit onClick="document.$form.submit();" value=Submit><br> 
    </td></tr><tr><td>
    </form>
    </td></tr></table>
    
    
ENDOFBLOCK
}

print <<ENDOFBLOCK;

</body>
</html>

ENDOFBLOCK
