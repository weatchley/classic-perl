#!/usr/local/bin/perl -w

#use integer;
use strict;


sub caesar {
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


sub encrypt {
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


sub decrypt {
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


my $key1 = "fuer9mhessiz4qb168vp92gnj0cexcfs";
my $key = "17ygrfi7mgfjx6bwddjim8x91j6e4mjs";
my $text = "This is a test string ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz`1234567890-=[];',./\\~!@#$%^&*()_+{}:\"<>?|";
my $text2 = "stuff";
print "Input string: \n'$text'\n";
my $encr = encrypt(text => $text, key => $key);
#$encr = encrypt(text => $encr, key => $key);
print "Encrypted string: '$encr'\n";
my $decr = decrypt(text => $encr, key => $key);
#$decr = decrypt(text => $decr, key => $key);
print "Decrypted string: \n'$decr'\n";

exit();
