package MySubs2;

use warnings;
use strict;

sub EvenDistribution {
	my $entriesOrTargets=$_[0];
	my $noOfEntriesOrTargetsWanted=$_[1];
	my $high=$_[2];
	my $low=$_[3];
	my $isTradeALong=$_[4];
	my $noDecimalPlacesForEntriesTargetsAndSLs=$_[5];
	my @strArr;
	
	# deal with only 1 entry (use "high" values, not the "low" values)
	if ($noOfEntriesOrTargetsWanted == 1) {
		push(@strArr,"1) $high - 100%\n");
		return @strArr;
	}
	
	# calc the entry/target values based on high, low and numberEntries given
	my $highLowDiff = $high - $low;
	my $entryIncrement = $highLowDiff / ($noOfEntriesOrTargetsWanted-1);
	my @entryOrTargetValsArr;
	# put entries or targets in the correct order based on whether longing or shorting
	if ($entriesOrTargets eq "entries") {
		# long entries (putting in "correct" order, long entries start high and get lower)
		if ($isTradeALong == 1) {
			for(my $i=0; $i<$noOfEntriesOrTargetsWanted; $i++){
				push (@entryOrTargetValsArr, $high-($entryIncrement*$i));
			}
		}
		# short entries (putting in "correct" order, short entries start low and get higher)
		elsif ($isTradeALong == 0) {
			for(my $i=0; $i<$noOfEntriesOrTargetsWanted; $i++){
				push (@entryOrTargetValsArr, $low+($entryIncrement*$i));
			}
		} 
		else {
			die "error: need to declare trade either a long or a short when generating entries";
		}
	}
	elsif ($entriesOrTargets eq "targets") {
		# long targets (putting in "correct" order, long targets start low and get higher)
		if ($isTradeALong == 1) {
			for(my $i=0; $i<$noOfEntriesOrTargetsWanted; $i++){
				push (@entryOrTargetValsArr, $low+($entryIncrement*$i));
			}
		}
		# short targets (putting in "correct" order, short targets start high and get lower)
		elsif ($isTradeALong == 0) {
			for(my $i=0; $i<$noOfEntriesOrTargetsWanted; $i++){
				push (@entryOrTargetValsArr, $high-($entryIncrement*$i));
			}
		} 
		else {
			die "error: need to declare trade either a long or a short when generating targets";
		}
	}
	else {
		die "error: need to declare if generating entries or targets";
	}
	
	# get the percentage values 
	my $percentageIncrement = 100/$noOfEntriesOrTargetsWanted;
	# floor the percentage values to integers
	my $percentIncrementBase = int($percentageIncrement);
	my @percentageArr;
	my $sum=0;
	for(my $i=0; $i<$noOfEntriesOrTargetsWanted; $i++){
		push (@percentageArr, $percentIncrementBase);
		$sum+=$percentIncrementBase;
	}
	
	# brute force the percentages to have a total of 100
	if ($sum<100){
		my $toAdd=100-$sum;
		my $arraySize=@percentageArr;
		for (my $i=0; $i<$toAdd; $i++){
			$percentageArr[$i]+=1;
		}
	}
	
	# print out the entries / targets and their percentage allocations
	for my $i (0 .. $#entryOrTargetValsArr){
		my $loc = $i+1;
		my $val = formatToVariableNumberOfDecimalPlaces($entryOrTargetValsArr[$i],$noDecimalPlacesForEntriesTargetsAndSLs);
		my $perc = $percentageArr[$i];
		push(@strArr,"$loc) $val - $perc%\n");
	}
	
	return @strArr;
}

1;
