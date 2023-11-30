package MySubs5;

use warnings;
use strict;

require "./MySubs6.pm";
require "./MySubs7.pm";
require "./MySubs8.pm";

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
	my @strArrEntries = MySubs6::HeavyWeightingAtEntryOrStoploss("entries",$noOfEntries,$highEntry,$lowEntry,$isTradeALong,$weightingFactorEntries,$noDecimalPlacesForEntriesTargetsAndSLs);
	foreach $strRead (@strArrEntries) {
		push(@template,$strRead);
	}
	
	# take profit targets
	push (@template,"\n");
	push (@template,"Take-Profit Targets:\n");
	my @strArrTargets = MySubs6::HeavyWeightingAtEntryOrStoploss("targets",$noOfTargets,$highTarget,$lowTarget,$isTradeALong,$weightingFactorTargets,$noDecimalPlacesForEntriesTargetsAndSLs);
	foreach $strRead (@strArrTargets) {
		push(@template,$strRead);
	}

	# stop-loss
	my $sl = MySubs7::formatToVariableNumberOfDecimalPlaces($stopLoss, $noDecimalPlacesForEntriesTargetsAndSLs);
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
	
	my @dollarsRiskedAtEachEntry_ent1 = MySubs8::calcRiskAddedAtEachEntry (\@strArrEntries,$noOfEntries,$stopLoss,$positionSizeEntry1,$wantedToRiskAmount*$riskSoftMult);
	my @dollarsRiskedAtEachEntry_avgEnt = MySubs8::calcRiskAddedAtEachEntry (\@strArrEntries,$noOfEntries,$stopLoss,$positionSizeAverageEntry,$wantedToRiskAmount);
	
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
