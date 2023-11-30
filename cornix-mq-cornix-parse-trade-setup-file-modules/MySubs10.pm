package MySubs10;

use warnings;
use strict;

sub readTradeConfigFile {
	# Cornix: max entries 10, only 1 SL allowed, max targets 10
	my $pathToFile = $_[0];
	my %dataHash = 	( 'coinPair' => "xxx/usdt",
					'client' => 999999,
					'leverage' => 999999,
					'numberOfEntries' => 0,
					'highEntry' => 0,
					'lowEntry' => 0,
					'stopLoss' => 0,
					'numberOfTargets' => 0,
					'lowTarget' => 0,
					'highTarget' => 0,
					'noDecimalPlacesForEntriesTargetsAndSLs' => 0,
					'wantedToRiskAmount' => 999999
				);
	open my $info, $pathToFile or die "Could not open $pathToFile: $!";
	while( my $line = <$info>) { 
		my $temp = $line;
		$temp =~ s/^\s+|\s+$//g;	# remove leading and trailing whitespace
		if ($temp =~ /^#/) {		# is first character a '#' (ie: a comment)?
			next;
		}
		if ($line =~ m/coinPair/) {
			my @splitter = split(/=/,$line);
			my $val = $splitter[1];
			$val =~ s/^\s+|\s+$//g;		# remove white space from start and end of variables
			$dataHash{coinPair}=$val;
		}
		if ($line =~ m/client/) { 
			my @splitter = split(/=/,$line);
			my $val = $splitter[1];
			$val =~ s/^\s+|\s+$//g;		# remove white space from start and end of variables
			$dataHash{client}=$val;
		}
		if ($line =~ m/leverage/) {
			my @splitter = split(/=/,$line);
			my $val = $splitter[1];
			$val =~ s/^\s+|\s+$//g;		# remove white space from start and end of variables
			if ($val<1 ) { $val = 0; }	# no leverage wanted, don't include leverage line in the template 
			$dataHash{leverage}=$val;
		}
		if ($line =~ m/numberOfEntries/) {
			my @splitter = split(/=/,$line);
			my $val = $splitter[1];
			$val =~ s/^\s+|\s+$//g;		# remove white space from start and end of variables
			$dataHash{numberOfEntries}=$val;
		}
		if ($line =~ m/highEntry/) {
			my @splitter = split(/=/,$line);
			my $val = $splitter[1];
			$val =~ s/^\s+|\s+$//g;		# remove white space from start and end of variables
			$dataHash{highEntry}=$val;
		}
		if ($line =~ m/lowEntry/) { 
			my @splitter = split(/=/,$line);
			my $val = $splitter[1];
			$val =~ s/^\s+|\s+$//g;		# remove white space from start and end of variables
			$dataHash{lowEntry}=$val;
		}
		if ($line =~ m/stopLoss/) { 
			my @splitter = split(/=/,$line);
			my $val = $splitter[1];
			$val =~ s/^\s+|\s+$//g;		# remove white space from start and end of variables
			$dataHash{stopLoss}=$val;
		}
		if ($line =~ m/numberOfTargets/) { 
			my @splitter = split(/=/,$line);
			my $val = $splitter[1];
			$val =~ s/^\s+|\s+$//g;		# remove white space from start and end of variables
			$dataHash{numberOfTargets}=$val;
		}
		if ($line =~ m/lowTarget/) { 
			my @splitter = split(/=/,$line);
			my $val = $splitter[1];
			$val =~ s/^\s+|\s+$//g;		# remove white space from start and end of variables
			$dataHash{lowTarget}=$val;
		}
		if ($line =~ m/highTarget/) { 
			my @splitter = split(/=/,$line);
			my $val = $splitter[1];
			$val =~ s/^\s+|\s+$//g;		# remove white space from start and end of variables
			$dataHash{highTarget}=$val;
		}
		if ($line =~ m/numDecimalPlacesForCoinPrices/) { 
			my @splitter = split(/=/,$line);
			my $val = $splitter[1];
			$val =~ s/^\s+|\s+$//g;		# remove white space from start and end of variables
			$dataHash{noDecimalPlacesForEntriesTargetsAndSLs}=$val;
		}
		if ($line =~ m/wantedToRiskAmount/) { 
			my @splitter = split(/=/,$line);
			my $val = $splitter[1];
			$val =~ s/^\s+|\s+$//g;		# remove white space from start and end of variables
			$dataHash{wantedToRiskAmount}=$val;
		}
	}
	close $info;
	return %dataHash;
}
1;
