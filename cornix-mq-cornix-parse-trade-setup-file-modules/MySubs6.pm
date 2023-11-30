package MySubs6;

use warnings;
use strict;
use List::Util qw(pairs);

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

1;
