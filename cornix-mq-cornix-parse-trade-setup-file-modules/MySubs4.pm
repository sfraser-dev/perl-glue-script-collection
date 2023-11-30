package MySubs4;

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

1;
