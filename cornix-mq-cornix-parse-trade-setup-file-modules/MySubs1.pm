package MySubs1;

use warnings;
use strict;
use POSIX qw(strftime);

sub createOutputFileName {
	my $scriptName = $_[0];
	my $pair = $_[1];
	my $isTradeALong = $_[2];
	my $longOrShortStr;
	$scriptName=~s/\.pl//;
	#$date = strftime "%Y%m%d-%H%M%S", localtime;
	#$date = strftime "%Y%m%d", localtime;
	my $date1 = strftime "%Y%m%d---%H%M", localtime; 
	my $date2 = strftime "%S", localtime;			
	my $date = $date1."_".$date2;		# YYYYMMDD---HM_SS
	my $dateWee = substr($date, 2); 	# YYMMDD---HHMM_SS (use date format 220325 not 20220325)
	my $pairNoSlash = $pair;
	$pairNoSlash =~ s/\///g;
	if ($isTradeALong == 1) {
		$longOrShortStr="long";
	} elsif ($isTradeALong == 0) {
		$longOrShortStr="short";
	} else {
		die "error: trade is neither a long nor a short";
	}
	my $txtFile = "$dateWee---$pairNoSlash-$longOrShortStr\.trade";
	return $txtFile;
}

1;
