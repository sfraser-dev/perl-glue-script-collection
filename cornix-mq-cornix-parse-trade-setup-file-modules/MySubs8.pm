package MySubs8;

use warnings;
use strict;

############################################################################
############################################################################
sub calcRiskAddedAtEachEntry {
	my @strArrEnts=@{$_[0]}; 						# dereference the passed array
	my $noOfEntries=$_[1];
	my $stopLoss=$_[2];
	my $fullPositionSize=$_[3];
	my $wantedToRiskAmount=$_[4];
	
	my $totalRiskSoFar=0;
	my @retArr;
	
	for my $i (0 .. ($noOfEntries-1)) {
		# get the values and percentages from the Cornix Entry Tragets: string array 
		my @splitter=split / /, $strArrEnts[$i];	# split line using spaces, [0]=1), [1]=value, [2]=hyphen, [3]=percentage
		my $entryPrice = $splitter[1];
		my $percentage = ($splitter[3]);
		$percentage =~ s/%//g;						# remove percentage sign
		$percentage /= 100;							# percenatge as decimal
		
		my $entryNo=$i+1;
		my $thisEntryPositionSize=$fullPositionSize*$percentage;
		my $thisRiskedPercentage = (abs($entryPrice-$stopLoss))/$entryPrice;
		my $thisRiskedAmount = $thisEntryPositionSize*$thisRiskedPercentage;
		
		$totalRiskSoFar += $thisRiskedAmount;
		my $amountStillLeftToRisk = $wantedToRiskAmount - $totalRiskSoFar;
		my $str1=sprintf("entry %d: riskAmountAddedHere=\$%.2f, totRiskNow=\$%.2f (\$%0.2f-\$%0.2f=\$%0.2f still to risk)",
										$entryNo,$thisRiskedAmount,$totalRiskSoFar, $wantedToRiskAmount, $totalRiskSoFar, $amountStillLeftToRisk);
		push(@retArr,$str1);
	}
	return @retArr;
}

1;
