package MySubs11;

use warnings;
use strict;

sub createCornixFreeTextSimpleTemplate {
	my $pair=$_[0];
	my $leverage=$_[1];
	my $highEntry=$_[2];
	my $lowEntry=$_[3];
	my $highTarget=$_[4];
	my $lowTarget=$_[5];
	my $stopLoss=$_[6];
	my $noDecimalPlacesForEntriesTargetsAndSLs=$_[7];
	my $noOfEntries=$_[8];
	my $noOfTargets=$_[9];
	my $isTradeALong=$_[10];
	my @simpleTemplate; 

	push (@simpleTemplate, "########################### simple template\n");
	push(@simpleTemplate,"$pair\n");
	#if ($leverage >= 1) { push (@simpleTemplate, sprintf("leverage isolated %sx\n",$leverage)); }
	if ($leverage >= 1) { push (@simpleTemplate, sprintf("leverage cross %sx\n",$leverage)); }

	# note: Need to set up each Cornix client (bot configuration - trading) with desired entry and target distributions
	# note: Need to do this for each individual client, there is no global setting for this
	my $sl = MySubs7::formatToVariableNumberOfDecimalPlaces($stopLoss,$noDecimalPlacesForEntriesTargetsAndSLs);
	
	# Set weighting factors set to 0 (Cornix Free Text simple mode cannot set percentage weighting factors at all)
	# Cornix Free Text simple mode can only setsentry, target and stop-loss VALUES, it cannot set weighting factor percentages
	# Only in Cornix Free Text advanced mode (when choose to edit trade) can we set weighting factor percentages 
	my $weightingFactorEntries=0;
	my $weightingFactorTargets=0;
	my @strArrEntries = MySubs6::HeavyWeightingAtEntryOrStoploss("entries",$noOfEntries,$highEntry,$lowEntry,$isTradeALong,$weightingFactorEntries,$noDecimalPlacesForEntriesTargetsAndSLs);
	my @strArrTargets = MySubs6::HeavyWeightingAtEntryOrStoploss("targets",$noOfTargets,$highTarget,$lowTarget,$isTradeALong,$weightingFactorTargets,$noDecimalPlacesForEntriesTargetsAndSLs);
	
	my @entryVals;
	my @targetVals;
	# get all the entry values
	for my $i (0 .. $#strArrEntries) {
		my @splitter=split / /, $strArrEntries[$i];	# split line using spaces, [0]=1), [1]=value, [2]=hyphen, [3]=percentage
		my $val = ($splitter[1]);
		push(@entryVals, MySubs7::formatToVariableNumberOfDecimalPlaces($val,$noDecimalPlacesForEntriesTargetsAndSLs));
	}
	# get all the target values
	for my $i (0 .. $#strArrTargets) {
		my @splitter=split / /, $strArrTargets[$i];	# split line using spaces, [0]=1), [1]=value, [2]=hyphen, [3]=percentage
		my $val = ($splitter[1]);
		push(@targetVals, $val);
	}

	# push all the entry values onto the simpleTemplate
	push(@simpleTemplate, "enter ");
	for my $i (0 .. $#entryVals) {
		push(@simpleTemplate,"$entryVals[$i] ");
	}
	# push all the target values onto the simpleTemplate
	push(@simpleTemplate, "\nstop $sl\n");
	push(@simpleTemplate, "targets ");
	for my $i (0 .. $#targetVals) {
		push(@simpleTemplate, "$targetVals[$i] ");
	}
	
	return @simpleTemplate;
}
1;
