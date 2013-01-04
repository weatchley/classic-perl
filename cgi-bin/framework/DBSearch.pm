# DB search functions
#
# $Source$
#
# $Revision$
#
# $Date$
#
# $Author$
#
# $Locker$
#
# $Log$
#
#
#
#

package DBSearch;
#
# get all required libraries and modules
use strict;
use SharedHeader qw(:Constants);
use DBShared qw(:Functions);
use DBI;
use DBD::Oracle qw(:ora_types);
use Tie::IxHash;

use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS $VERSION $AUTOLOAD);
#use vars qw ();
use integer;

use Exporter;
$VERSION = 1.00;

@ISA = qw(Exporter);

@EXPORT = qw ();
@EXPORT_OK = qw(
    );
%EXPORT_TAGS =( 
    Functions => [qw(
    )]
);


###################################################################################################################################
sub matchFound {                                                                                                                  #
###################################################################################################################################
   my %args = (
      @_,
   );
   my $out;
   if (defined($args{text})) {
       if ($args{case} gt "") {
          $out = ($args{text} =~ m/$args{searchString}/) ? 1 : 0;
       } else {
          $out = ($args{text} =~ m/$args{searchString}/i) ? 1 : 0;
       }
   } else {
       $out = 0;
   }
   return ($out);
}




###################################################################################################################################
###################################################################################################################################




1; #return true
