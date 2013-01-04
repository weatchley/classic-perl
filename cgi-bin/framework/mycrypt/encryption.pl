#!/usr/local/bin/perl -w
#
use CGI;

$ENV{SCRIPT_NAME} =~ m%(.*/)(.*)\..*$%;
my $path = $1;
my $form = $2;


###################################################################################################################################
###################################################################################################################################


###################################################################################################################################
sub caesar {
###################################################################################################################################
    my $text = shift;
    my $key = shift;
    
    #key of 0 does nothing
    my $ks = $key % 26 or return $text;
    my $ke = $ks -1;
    
    my ($s, $S, $e, $E);
    $s = chr(ord('a') + $ks);
    $S = chr(ord('A') + $ks);
    $e = chr(ord('a') + $ke);
    $E = chr(ord('A') + $ke);
    
    eval "\$text =~ tr/a-zA-Z/$s-za-$e$S-ZA-$E/;";
    
    return $text;
}


###################################################################################################################################
sub encrypt {
###################################################################################################################################
    my %args = (
          text => '',
          key => '',
          depth => 5,
          @_,
          );
    
    my $outString = '';
    my $testKey = $args{key};
    while (length($testKey) < (length($args{text}) + $args{depth})) {
        $testKey .= $args{key};
    }
    
    for (my $i=0; $i<length($args{text}); $i++) {
        my $temp = substr($args{text},$i,1);
        for (my $j=0; $j<$args{depth}; $j++) {
            my $keySeg = substr($testKey,($i + $j),1);
            $temp = caesar($temp, ($i+1));
            $temp = $temp ^ $keySeg;
        }
        $temp = ord($temp);
        $temp = (sprintf("%03d", $temp));

        $outString .= $temp;
    }
    
    return ($outString);
}


###################################################################################################################################
sub decrypt {
###################################################################################################################################
    my %args = (
          text => '',
          key => '',
          depth => 5,
          @_,
          );
    
    my $outString = '';
    my $testKey = $args{key};
    my $text = '';
    for (my $i=0; $i<length($args{text}); $i += 3) {
        $text .= chr(substr($args{text}, $i, 3));
    }
    while (length($testKey) < (length($text) + $args{depth})) {
        $testKey .= $args{key};
    }
    
    for (my $i=0; $i<length($text); $i++) {
        my $temp = substr($text,$i,1);
        for (my $j=0; $j<$args{depth}; $j++) {
            my $keySeg = substr($testKey,($i + ($args{depth} - $j -1)),1);
            $temp = $temp ^ $keySeg;
            $temp = caesar($temp, ((26-($i+1))%26));
        }
        $outString .= $temp;
    }
    
    return ($outString);
}


###################################################################################################################################
###################################################################################################################################


my $mycgi = new CGI;

my $command = (defined($mycgi->param('command'))) ? $mycgi->param('command') : 'form';
my $inputString = (defined($mycgi->param('inputstring'))) ? $mycgi->param('inputstring') : '';
my $key = (defined($mycgi->param('key'))) ? $mycgi->param('key') : '';
my $keyLength = (defined($mycgi->param('keylength'))) ? $mycgi->param('keylength') : 32;

my $outputstring = '';

if ($command eq 'genkey') {
    my @TestVals = ("0".."9","a".."z");
    my $looptest = "notdone";
    srand (time|$$);
    my $KeyID = "";
    for (my $pos = 0; ($pos < 32); $pos++) {
        $KeyID = $KeyID . $TestVals [rand (36)];
    }
    $key = $KeyID;
    $outputstring = $key;

} elsif ($command eq 'encrypt') {
    $outputstring = encrypt(text => $inputString, key => $key);
} elsif ($command eq 'decrypt') {
    $outputstring = decrypt(text => $inputString, key => $key);
}

print $mycgi->header();
print <<END_OF_BLOCK;
<html>
<head>
<title>Encryption</title>
</head>
<body>
<form name=encryption method=post action=$path$form.pl>

<input type=hidden name=command value='form'>

<h1>My Crypt</h1>
<br>
<table>
<tr><td>Key </td><td><input type=text size=50 name=key value='$key'></td></tr>
<tr><td>Key Length </td><td><input type=text size=2 name=keylength value='$keyLength'></td></tr>
<tr><td>Input String </td><td><input type=text size=50 name=inputstring value='$inputString'></td></tr>
END_OF_BLOCK
if ($command ne 'form') {
    print "<tr><td>Results: </td><td>$outputstring</td></tr>\n";
}
print "<tr><td><input type=button name=doencrypt value='Gen Key' onClick='javascript:$form.command.value=\"genkey\";$form.submit();'></td><td>&nbsp;</td></tr>\n";
print "<tr><td><input type=button name=doencrypt value='Encrypt' onClick='javascript:$form.command.value=\"encrypt\";$form.submit();'></td><td>&nbsp;</td></tr>\n";
print "<tr><td><input type=button name=dodecrypt value='Decrypt' onClick='javascript:$form.command.value=\"decrypt\";$form.submit();'></td><td>&nbsp;</td></tr>\n";
print "</table>\n</form>\n</body>\n</html>\n";
#print STDERR "**** $form ****\n";
