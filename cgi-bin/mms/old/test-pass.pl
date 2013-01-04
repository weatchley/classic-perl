#!/usr/local/bin/perl -w

#use integer;
use strict;

###################################################################################################################################
sub getValueHash {  # routine to get initial CGI values and return in a hash
###################################################################################################################################
    my %args = (
        valueList => (),
        @_,
    );
    
    my %valueHash = ();
    my @valueArray = $args{valueList};

#    foreach my $item (@valueArray) {
#        $valueHash{$item} = $item;
#    }
    %valueHash = (test => 'test');
    
    return (%valueHash);
}

###################################################################################################################################
###################################################################################################################################

my %hash1 = (
    val1 => 'val1',
    val2 => 'val2',
    );

my %hash2 = getValueHash(valueList => ('Test1', 'Test2', 'Test3'));
my %hash3 = (%hash1, getValueHash(valueList => ('Test1', 'Test2', 'Test3')), (
    val3 => 'val3',
    val4 => 'val4',
    ));

foreach my $key (sort keys %hash3) {
    print $key . ":" . $hash3{$key} ."\n";
}


exit();
