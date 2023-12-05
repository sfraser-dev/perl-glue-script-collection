package MySubs5;

use warnings;
use strict;
use List::Util qw(pairs);

require "./MySubs2.pm";
require "./MySubs3.pm";

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


sub formatToVariableNumberOfDecimalPlaces {
	my $valIn = $_[0];
	my $decimalPlaces = $_[1];
	
	# sprintf("%.Xf",str) where X is variable
	my $temp = "%.$decimalPlaces"."f";			
	my $valOut = sprintf($temp, $valIn);
	
	return $valOut;
}

sub HeavyWeightingAtEntryOrStoploss {
	my $entriesOrTargetsStr=$_[0];
	my $noOfEntries=$_[1];
	my $high=$_[2];
	my $low=$_[3];
	my $isTradeALong=$_[4];
	my $weightingFactor=$_[5];
	my $noDecimalPlacesForEntriesTargetsAndSLs=$_[6];
	my @strArr;
	
	# run EvenDistribution calculation first
	@strArr = MySubs2::EvenDistribution($entriesOrTargetsStr,$noOfEntries,$high,$low,$isTradeALong,$noDecimalPlacesForEntriesTargetsAndSLs);
	
	# get the percentages from @strArr
	my @percentages;
	for my $i (0 .. $#strArr) {
		my @splitter=split / /, $strArr[$i];	# split line using spaces, [0]=1), [1]=value, [2]=hyphen, [3]=percentage
		my $percentage = ($splitter[3]);
		$percentage =~ s/%//g;					# remove percentage sign
		push (@percentages, $percentage);
	}
	
	# is there an odd or even number of percentages?
	my $arrLengthPerc = @percentages;
	my $mod = $arrLengthPerc % 2;
	my $isEven;
	if ($mod == 0) {
		$isEven = 1;
	} elsif ($mod == 1) {
		$isEven = 0;
	} else {
		die "error: modulus calculation error";
	}
	
	# create an array of percentage "pairs" (next to each other in the array)
	my @temp;						
	for(my $i = 0; $i < (int($arrLengthPerc/2)); $i++){
		push(@temp, $i);
		push(@temp, ($arrLengthPerc-1-$i));
	}
	# convert this array into a "pairs value" index array
	my @indexPairs = pairs @temp;
	
	### array indexes, length 6 (even length)
	# 00 01 02 03 04 05
	### values
	# 10 10 10 10 10 10		initial array values 
	# 12 12 12 08 08 08		iteration 1 (weighting factor 2)
	# 14 14 12 08 06 06		iteration 2 (weighting factor 2)
	# 16 14 12 08 06 04		iteration 3 (weighting factor 2)
	### index pairs
	# 0,5 (0...length-1)
	# 1,4 (1...length-2)
	# 2,3 (2...length-3)
	#########################################
	### array indexes, length 5 (odd length)
	# 00 01 02 03 04 
	### values
	# 10 10 10 10 10		initial array values 
	# 12 12 10 08 08		iteration 1 (weighting factor 2)
	# 14 12 10 08 06		iteration 2 (weighting factor 2)
	### index pairs
	# 0,4 (0...length-1)
	# 1,3 (1...length-2)
	
	# entries: positive values are the more "disciplined" weightings
	# entries: positive weightingFactor values weight towards the stop-loss
	# entries: negative weightingFactor values weight towards the entry
	# targets: positive values is the more "disciplined" weightings
	# targets: positive weightingFactor values weight towards the furthest away target
	# targets: negative weightingFactor values weight towards the closest target
	for(my $x = 0; $x < (int($arrLengthPerc/2)); $x++){
		for(my $i = 0; $i < (int($arrLengthPerc/2))-$x; $i++){
			# my $ii = $indexPairs[$i]->key;
			my $p = $indexPairs[$i]->value;
			$percentages[$i]-=$weightingFactor;
			$percentages[$p]+=$weightingFactor;	
		}
	}

	# update strArr with the new weighted percentages
	my @strArrNewPercentages;
	for my $i (0 .. $#strArr) {
		my @splitter=split / /, $strArr[$i];	# split line using spaces, [0]=1), [1]=value, [2]=hyphen, [3]=percentage
		my $num = ($splitter[0]);
		my $val = ($splitter[1]);
		my $hash = ($splitter[2]);
		my $per = ($splitter[3]);
		$per = sprintf("%.2f", $percentages[$i]);
		if ($per <= 0) { die "error: percentage weighting is zero or less"; }
		my $newline = $num." ".$val." ".$hash." "."$per%\n";
		push(@strArrNewPercentages, $newline);
	}
			
	return @strArrNewPercentages;
}


sub createCornixFreeTextAdvancedTemplate {
	my $pair = $_[0];
	my $clientSelected = $_[1];
	my $leverage = $_[2];
	my $noOfEntries = $_[3];
	my $highEntry = $_[4];
	my $lowEntry = $_[5];
	my $noOfTargets = $_[6];
	my $highTarget = $_[7];
	my $lowTarget = $_[8];
	my $stopLoss = $_[9];
	my $noDecimalPlacesForEntriesTargetsAndSLs = $_[10];
	my $wantedToRiskAmount = $_[11];
	my $isTradeALong = $_[12];
	my $weightingFactorEntries = $_[13];
	my $weightingFactorTargets = $_[14];
	my $dynamicEntryValue = $_[15];
	my @template;
	my $strRead;
	my $riskSoftMult;
	my $riskPercentageBasedOnEntry1;
	my $riskPercentageBasedOnAvgEntry;
		
	push (@template, "########################### advanced template\n");
	
	# coin pairs
	push (@template, "$pair\n");
	
	# Cornix client
	push (@template, "Client: $clientSelected\n");
	
	# long or short trade
	if ($isTradeALong==1) 		{ push (@template, "Trade Type: Regular (Long)\n"); }
	elsif ($isTradeALong==0) 	{ push (@template, "Trade Type: Regular (Short)\n"); }
	else 						{ die "error: cannot determine if trade is a long or a short for writing template"; }
	
	# amount of leverage to use (if any at all, "-1" means no leverage)
	#if ($leverage >= 1) 		{ push (@template, "Leverage: Isolated ($leverage.0X)\n"); }
	if ($leverage >= 1) 		{ push (@template, "Leverage: Cross ($leverage.0X)\n"); }
	
	# entry targets
	push (@template,"\n");
	push (@template,"Entry Targets:\n");
	my @strArrEntries = HeavyWeightingAtEntryOrStoploss("entries",$noOfEntries,$highEntry,$lowEntry,$isTradeALong,$weightingFactorEntries,$noDecimalPlacesForEntriesTargetsAndSLs);
	foreach $strRead (@strArrEntries) {
		push(@template,$strRead);
	}
	
	# take profit targets
	push (@template,"\n");
	push (@template,"Take-Profit Targets:\n");
	my @strArrTargets = HeavyWeightingAtEntryOrStoploss("targets",$noOfTargets,$highTarget,$lowTarget,$isTradeALong,$weightingFactorTargets,$noDecimalPlacesForEntriesTargetsAndSLs);
	foreach $strRead (@strArrTargets) {
		push(@template,$strRead);
	}

	# stop-loss
	my $sl = formatToVariableNumberOfDecimalPlaces($stopLoss, $noDecimalPlacesForEntriesTargetsAndSLs);
	push (@template,"\n");
	push (@template,"Stop Targets:\n1) $sl - 100%\n");
	push (@template,"\n");
	
	# trailing configuration
	my $trailingLine01 = "Trailing Configuration:";
	my $trailingLine02 = "Entry: Percentage (0.0%)";
	my $trailingLine03 = "Take-Profit: Percentage (0.0%)";
	#my $trailingLine04 = "Stop: Breakeven -\n Trigger: Target (1)";
	my $trailingLine04 = "Stop: Without";
	push (@template,"$trailingLine01\n$trailingLine02\n$trailingLine03\n$trailingLine04\n\n");
	
	# risk softening multiplier (just for risk based on only entry1) and risk percentages (risked amount is based on entry and stop-loss)
	($riskSoftMult,$riskPercentageBasedOnEntry1,$riskPercentageBasedOnAvgEntry) = MySubs3::riskSofteningMultiplier(\@strArrEntries, $stopLoss); # passing array as reference
	
	# position sizes required for the wanted risk (calc for both enrty1 and average-entry)
	my $positionSizeEntry1 = $wantedToRiskAmount/$riskPercentageBasedOnEntry1;
	my $positionSizeAverageEntry = $wantedToRiskAmount/$riskPercentageBasedOnAvgEntry;
	
	my @dollarsRiskedAtEachEntry_ent1 = calcRiskAddedAtEachEntry (\@strArrEntries,$noOfEntries,$stopLoss,$positionSizeEntry1,$wantedToRiskAmount*$riskSoftMult);
	my @dollarsRiskedAtEachEntry_avgEnt = calcRiskAddedAtEachEntry (\@strArrEntries,$noOfEntries,$stopLoss,$positionSizeAverageEntry,$wantedToRiskAmount);
	
	# fixed risk dynamic position size calculation
	my @temp_arraysConcatenatedReturnedFromSub;
	my @frdps_dataEnt1;
	my @frdps_dataAvgEnt;
	if ($dynamicEntryValue != 0) {  
		@temp_arraysConcatenatedReturnedFromSub = fixedRiskDynamicPositionSize(\@strArrEntries,$stopLoss, # passing array as references
														$positionSizeEntry1,$positionSizeAverageEntry,$wantedToRiskAmount,
														$dynamicEntryValue,$isTradeALong); 
		for my $i (0 .. ($noOfEntries-1)) {
			$frdps_dataEnt1[$i]=$temp_arraysConcatenatedReturnedFromSub[$i];
			$frdps_dataAvgEnt[$i]=$temp_arraysConcatenatedReturnedFromSub[$noOfEntries+$i];
		}
	}		
	
	# # show position size needed for required risk percentage (based only on entry1)
	###### commenting out risk-softening-multiplier output information, never using it just now
	# my $tempEnt1 = "########################### risk based only on entry 1\n";
	# my $tempEnt2 = sprintf("riskPercentageBasedOnEntry1 = %.4f\n",$riskPercentageBasedOnEntry1);
	# my $tempEnt3 = sprintf("riskSoftMult = %.4f\n",$riskSoftMult);
	# my $reducedRisk = $wantedToRiskAmount*$riskSoftMult;
	# my $tempEnt4 = "position size of \$".sprintf("%.2f",$positionSizeEntry1)." is needed to risk \$".sprintf("%.2f",$reducedRisk);
	# my $tempEnt5 = sprintf("; softened risk is \$%0.2f (\$%0.2f * %0.4f)\n",$reducedRisk,$wantedToRiskAmount,$riskSoftMult);
	# push (@template,$tempEnt1);
	# push (@template,$tempEnt2);
	# push (@template,$tempEnt3);
	# push (@template,$tempEnt4);
	# push (@template,$tempEnt5);	
	# # risk added at each entry (based only on entry1)
	# for my $i (0 .. ($noOfEntries-1)) {
		# my $str = sprintf("%s\n",$dollarsRiskedAtEachEntry_ent1[$i]);
		# push(@template,$str);
	# }
	# my $softenedRisk = $wantedToRiskAmount*$riskSoftMult;
	# my $tempEnt6 = sprintf("riskSoftMult: \$%.2f * %.4f = \$%.2f\n\n",$wantedToRiskAmount,$riskSoftMult,$softenedRisk);
	# push (@template,$tempEnt6);

	# show position size needed for required risk percentage (based average entry)
	my $tempAvg1 = "########################### risk based on average entry\n";
	my $tempAvg2 = sprintf("riskPercentageBasedOnAvgEntry = %.4f\n",$riskPercentageBasedOnAvgEntry);
	my $tempAvg3 = "position size of \$".sprintf("%.2f",$positionSizeAverageEntry)." is needed to risk \$".sprintf("%.2f",$wantedToRiskAmount)."\n";
	push (@template,$tempAvg1);
	push (@template,$tempAvg2);
	push (@template,$tempAvg3);
	# risk added at each entry (based only on avgEntry)
	for my $i (0 .. ($noOfEntries-1)) {
		my $str = sprintf("%s\n",$dollarsRiskedAtEachEntry_avgEnt[$i]);
		push(@template,$str);
	}
	
	# Optional: show fixed risk dynamic position sizes 
	if ($dynamicEntryValue != 0) {
		# entry1
		push(@template,"\n########################### fixed risk dynamic position size\n");
		push (@template,"### only on entry 1\n");
		for my $i (0 .. ($noOfEntries-1)) {
			push (@template,$frdps_dataEnt1[$i]);
		}
		average entry
		push (@template,"### average entry\n");
		for my $i (0 .. ($noOfEntries-1)) {
			push (@template,$frdps_dataAvgEnt[$i]);
		}
	}
	
	return @template;
}

1;
