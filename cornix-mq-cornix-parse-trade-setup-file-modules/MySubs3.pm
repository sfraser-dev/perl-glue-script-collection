package MySubs3;

use warnings;
use strict;

sub calcAverageEntryPriceForVariableEntriesHit {
	my @strArrEnts=@{$_[0]}; 						# dereference the passed array
	my $numOfEntriesToUseForCalculation=$_[1];
	
	# Assigns arbitary position value for ease of claculation. Based on this arbitary position value, calc number of coins
	# bought at each entry point (using entry price & assigned percentage of position size). Keep a running total of amount of
	# coins bought and a running total paid for these coins (total paid will be the full arbitary value *IF* all entry targets hit).
	# If not all entry targets hit, it will be a different total amount paid.
	# Note: the amount used for the arbitary position value doesn't matter, it'll give the same result
	my $arbitraryPositionValue = 100000;
	my $totalNumberCoinsBought = 0;
	my $totalAmountPaidForCoins = 0;
	my $firstEntryPrice;
	my $totalPercentageOfPositionSizeBought = 0;
	
	my $entryPriceFinal_i;
	for my $i (0 .. ($numOfEntriesToUseForCalculation-1)) {
		# get the values and percentages from the Cornix Entry Tragets: string array 
		my @splitter=split / /, $strArrEnts[$i];	# split line using spaces, [0]=1), [1]=value, [2]=hyphen, [3]=percentage
		my $entryPrice = $splitter[1];
		if ($i == 0) { $firstEntryPrice = $entryPrice; }
		my $percentage = ($splitter[3]);
		$percentage =~ s/%//g;						# remove percentage sign
		$percentage /= 100;							# percenatge as decimal
		$totalPercentageOfPositionSizeBought += $percentage;
		
		# calculate "number of coins obtained" at this entry and percentage (using arbitary position size same as spreadsheet)
		my $amountSpentAtThisEntryPoint =  $arbitraryPositionValue * $percentage;
		my $numberCoinsBoughtAtThisEntryPoint = $amountSpentAtThisEntryPoint / $entryPrice;
		$totalAmountPaidForCoins += $amountSpentAtThisEntryPoint;
		$totalNumberCoinsBought += $numberCoinsBoughtAtThisEntryPoint;
		
		$entryPriceFinal_i = $entryPrice;
	}
	my $averageEntryPrice = $totalAmountPaidForCoins / $totalNumberCoinsBought;
		
	return ($firstEntryPrice, $averageEntryPrice, $totalPercentageOfPositionSizeBought, $entryPriceFinal_i);
}


sub riskSofteningMultiplier {
	# assumes advanced template entries are in the correct order (whether long or shorting), "EvenDistribution" sub does this
	my @strArrEnts=@{$_[0]}; 					# dereference the passed array
	my $stopLoss=$_[1];
	
	my $numEntriesHit = scalar(@strArrEnts);
	my $firstEntryPrice;
	my $avgEntryPrice;
	my $percentageOfPosSizeBoughtSoFar;
	my $dummyVar;
	($firstEntryPrice,$avgEntryPrice,$percentageOfPosSizeBoughtSoFar,$dummyVar) = calcAverageEntryPriceForVariableEntriesHit(\@strArrEnts,$numEntriesHit);
	
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
