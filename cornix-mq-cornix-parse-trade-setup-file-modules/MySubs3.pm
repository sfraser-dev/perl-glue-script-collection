package MySubs3;

use warnings;
use strict;

require "./MySubs4.pm";

sub riskSofteningMultiplier {
	# assumes advanced template entries are in the correct order (whether long or shorting), "EvenDistribution" sub does this
	my @strArrEnts=@{$_[0]}; 					# dereference the passed array
	my $stopLoss=$_[1];
	
	my $numEntriesHit = scalar(@strArrEnts);
	my $firstEntryPrice;
	my $avgEntryPrice;
	my $percentageOfPosSizeBoughtSoFar;
	my $dummyVar;
	($firstEntryPrice,$avgEntryPrice,$percentageOfPosSizeBoughtSoFar,$dummyVar) = MySubs4::calcAverageEntryPriceForVariableEntriesHit(\@strArrEnts,$numEntriesHit);
	
	# calculate risk percentatge based on just the first entry (entry1), risk percentage based on average entry and a
	# risk-softening-multiplier (the risk-softening-multiplier is just for entry1 calculation)
	#
	# What is risk-softening-multiplier? I would use TradingView's RR tool to get the SL distance from the FIRST entry;
	# I would then use this risk percentage to calculate my total position size. When I started layering multiple bids below
	# the FirstEntry, I kept using ONLY the first entry to calcualte my risk - my risk WASN'T this much as I would have an average
	# bid entry below this due to layering my bids. The risk-softening-multiplier accounts for this. If I wanted to risk $100 on 
	# a trade and used only the first entry to calculate this risk (but actually had layered bids), my risk-softening-multiplier
	# might be something like 0.75, thus my actual risk would only be $100*0.75 = $75. I never used to layer bids so this was a simple
	# way for me implement it initially - easy for me to update my journal properly and quickly if I calcualed my risk using only
	# the first entry but actually had layered bids.
	my $riskPercentageBasedOnEntry1 = (abs($firstEntryPrice-$stopLoss))/$firstEntryPrice;
	my $riskPercentageBasedOnAvgEntry = (abs($avgEntryPrice-$stopLoss))/$avgEntryPrice;
	my $riskSoftMult = $riskPercentageBasedOnAvgEntry / $riskPercentageBasedOnEntry1;

	return ($riskSoftMult, $riskPercentageBasedOnEntry1,$riskPercentageBasedOnAvgEntry);	
}

1;
