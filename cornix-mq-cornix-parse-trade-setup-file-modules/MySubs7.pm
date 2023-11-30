package MySubs7;

use warnings;
use strict;

sub formatToVariableNumberOfDecimalPlaces {
	my $valIn = $_[0];
	my $decimalPlaces = $_[1];
	
	# sprintf("%.Xf",str) where X is variable
	my $temp = "%.$decimalPlaces"."f";			
	my $valOut = sprintf($temp, $valIn);
	
	return $valOut;
}
1;
