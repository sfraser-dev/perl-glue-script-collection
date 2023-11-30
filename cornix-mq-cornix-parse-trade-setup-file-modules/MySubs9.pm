package MySubs9;

use warnings;
use strict;

sub fixedRiskDynamicPositionSize {
	my @strArrEnts=@{$_[0]}; 						# dereference the passed array
	my $stopLoss=$_[1];
	my $fullPositionSize_entry1=$_[2];
	my $fullPositionSize_avgEnt=$_[3];
	my $wantedToRiskAmount=$_[4];
	my $dynamicEntryValue=$_[5];
	my $isTradeALong=$_[6];
	
	# check that the new dynamic entry value occurs only while trade is currently in profit
	my $firstEntryPrice;
	my $avgEntryPrice;
	my $percentageOfPosSizeBoughtSoFar;
	my $dummyVar;
	# run calcAverageEntryPriceForVariableEntriesHit() once to get the first entry price so checks can be run
	($firstEntryPrice,$avgEntryPrice,$percentageOfPosSizeBoughtSoFar,$dummyVar) = calcAverageEntryPriceForVariableEntriesHit(\@strArrEnts,1);
	if ( ( $isTradeALong==1) && ($dynamicEntryValue <= $firstEntryPrice) ) { 	# long
		die "fixed risk dynamic position size error for long trade!\n";
	}
	if ( ($isTradeALong!=1) && ($dynamicEntryValue >= $firstEntryPrice) ){		# short
		die "fixed risk dynamic position size error for short trade!\n";
	}
		
	my @dataEnt1;
	my @dataAvgEnt;
	my $numEntriesToProcess = scalar(@strArrEnts);
	my $percentageBoughtSoFar_previous_ent1 = 0;
	my $theCurrentEntryPrice;
	my $riskedAmountSoFar_ent1 = 0;
	# get stats for all possible entry targets hit so fixed risk dynamic position size can be calculated
	for my $i (1 .. $numEntriesToProcess) {
		($firstEntryPrice,$avgEntryPrice,$percentageOfPosSizeBoughtSoFar,$theCurrentEntryPrice) = 
															calcAverageEntryPriceForVariableEntriesHit(\@strArrEnts,$i);
		# calculate current risk percentage based on hit entries and stop-loss
		my $riskPercentageBasedOnEntry1 = (abs($firstEntryPrice-$stopLoss))/$firstEntryPrice;
		my $riskPercentageBasedOnAvgEntry = (abs($avgEntryPrice-$stopLoss))/$avgEntryPrice;
		# calculate new risk percentage based on adding to position at the current price (not moving stop-loss)
		my $riskPercentage_new_frdps = (abs($dynamicEntryValue-$stopLoss))/$dynamicEntryValue;	
		
		# entry1-only: calculate the new position size required for fixed risk dynamic position sizing	
		# entry1-only: need the percentage of total postion size bought here (to calculate the position size at the current entry)
		my $percentageBoughtHere_ent1 = $percentageOfPosSizeBoughtSoFar - $percentageBoughtSoFar_previous_ent1;
		$percentageBoughtSoFar_previous_ent1 += $percentageBoughtHere_ent1;
		# entry1-only: calculate cumulative amount risked so far
		my $positionSizeHere_ent1 = $fullPositionSize_entry1 * $percentageBoughtHere_ent1;
		my $percentageRiskedHere_ent1 = (abs($theCurrentEntryPrice-$stopLoss))/$theCurrentEntryPrice;
		my $riskedAmountHere_ent1 = $positionSizeHere_ent1 * $percentageRiskedHere_ent1;
		$riskedAmountSoFar_ent1 += $riskedAmountHere_ent1;	
		# can now finally calculate the new position size required for fixed risk dynamic position sizing
		my $newAmountToRisk_ent1 = $wantedToRiskAmount - $riskedAmountSoFar_ent1;
		my $newPositionSize_ent1 = $newAmountToRisk_ent1 / $riskPercentage_new_frdps;
		# entry1-only: output the data
		my $currentTotalRisk_ent1 = $riskedAmountSoFar_ent1 + $newAmountToRisk_ent1;
		my $e1=sprintf("%dentriesHit: totRiskNow=\$%.2f, newPosSize \$%.0f ",$i,$riskedAmountSoFar_ent1,$newPositionSize_ent1);
		my $e2=sprintf("at price \$%.4f adds \$%.2f of risk (totRisk now \$%.0f, ",$dynamicEntryValue,$newAmountToRisk_ent1,$currentTotalRisk_ent1);
		my $e3=sprintf("SL=\$%.4f)\n",$stopLoss);
		my $e4=$e1.$e2.$e3;
		push(@dataEnt1,$e4);
		
		# average-entry: calculate the new position size required for fixed risk dynamic position sizing
		my $riskedAmountSoFar_avgEnt = $fullPositionSize_avgEnt * $percentageOfPosSizeBoughtSoFar * $riskPercentageBasedOnAvgEntry;
		my $newAmountToRisk_avgEnt = $wantedToRiskAmount - $riskedAmountSoFar_avgEnt;
		my $newPositionSize_avgEnt = $newAmountToRisk_avgEnt / $riskPercentage_new_frdps;
		# average-entry: output the data
		my $currentTotalRisk_avgEnt = $riskedAmountSoFar_avgEnt + $newAmountToRisk_avgEnt;
		my $a1=sprintf("%dentriesHit: totRiskNow=\$%.2f, newPosSize \$%.0f ",$i,$riskedAmountSoFar_avgEnt,$newPositionSize_avgEnt);
		my $a2=sprintf("at price \$%.4f adds \$%.2f of risk (totRisk now \$%.0f, ",$dynamicEntryValue,$newAmountToRisk_avgEnt,$currentTotalRisk_avgEnt);
		my $a3=sprintf("SL=\$%.4f)\n",$stopLoss);
		my $a4=$a1.$a2.$a3;
		push(@dataAvgEnt,$a4);
	}
	
	return @dataEnt1, @dataAvgEnt;
}

1;
