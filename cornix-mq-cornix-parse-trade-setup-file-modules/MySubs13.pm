package MySubs13;

use warnings;
use strict;

sub checkValuesFromConfigFile {
	my $noOfEntries = $_[0];
	my $noOfTargets = $_[1];
	my $highEntry = $_[2];
	my $lowEntry = $_[3];
	my $highTarget = $_[4];
	my $lowTarget = $_[5];
	my $stopLoss = $_[6];
	my $leverage = $_[7];
	my $noDecimalPlacesForEntriesTargetsAndSLs = $_[8];
	my $wantedToRiskAmount = $_[9];

	# number of entries should be between 1 and 10 (Cornix free text maximum is 10)
	if (($noOfEntries<1) or ($noOfEntries>10)) { die "\nerror: noOfEntries should be 10 or less, \n"; }
	
	# number of targets should be between 1 and 10 (Cornix free text maximum is 10)	
	if (($noOfTargets<1) or ($noOfTargets>10)) { die "\nerror: noOfTargets should be 10 or less, \n"; }
	
	# make sure high entry is above the low entry
	if ($highEntry <= $lowEntry) { die "\nerror: highEntry is <= lowEntry\n"; }
	
	# make sure high target is above the low target
	if ($highTarget <= $lowTarget) { die "\nerror: highTarget is <= lowTarget\n"; }
	
	# determine if it's a long or a short trade
	my $isTradeALong;
	if (($highEntry>$highTarget) and ($highEntry>$lowTarget) and ($lowEntry>$highTarget) and ($lowEntry>$lowTarget)) {
		$isTradeALong = 0;
	} elsif (($highEntry<$highTarget) and ($highEntry<$lowTarget) and ($lowEntry<$highTarget) and ($lowEntry<$lowTarget)) {
		$isTradeALong = 1;
	} else {
		die "error: TradeType must be 'long' or 'short'";
	}
	
	# check stop-loss value makes sense
	if (($isTradeALong == 1) and ($stopLoss >= $lowEntry)) {
		die "error: wrong stop-loss placement for a long";
	} elsif (($isTradeALong == 0) and ($stopLoss <= $highEntry)) {
		die "error: wrong stop-loss placement for a short";
	}
	
	# leverage: cannot read "0" from command line, use "-1" for no leverage
	if (($leverage<-1) or ($leverage >20)) { 
		die "error: incorrect leverage (-1 <= lev <=20)";
	}
	
	# decimal places for entries and targets (so can ignore leading zeros in low sat coins)
	if (($noDecimalPlacesForEntriesTargetsAndSLs < 0) or ($noDecimalPlacesForEntriesTargetsAndSLs >10)) {
		die "error: issue with the amount of decimal places";
	}
	
	# the risked amount
	if ($wantedToRiskAmount <= 0) { die "\nerror: wantedToRiskAmount is <= 0\n"; }
	
	return $isTradeALong;
}

1;
