package MySubs12;

use warnings;
use strict;

sub getCornixClientName {
	my $clientNum=$_[0];
	my $retStr;
	
	if 		($clientNum == 1) 	{ $retStr = "BM BinFuts (main)"; }
	elsif 	($clientNum == 2) 	{ $retStr = "BM BinSpot (main)"; }	
	elsif 	($clientNum == 3) 	{ $retStr = "BM BybitKB7 Contract InvUSD (main) 260321"; }
	elsif 	($clientNum == 4) 	{ $retStr = "BM BybitKB7 Contract LinUSDT (main) 211128"; }	
	elsif 	($clientNum == 5) 	{ $retStr = "SF BinFuts (main)"; }	
	elsif 	($clientNum == 6) 	{ $retStr = "SF BinSpot (main)"; }	
	elsif 	($clientNum == 7) 	{ $retStr = "SF Bybit Contract InvUSD (main) 210318"; }	
	elsif 	($clientNum == 8) 	{ $retStr = "BM BybitKB7 Contract LinUSDT (main) 281121"; }	
	elsif 	($clientNum == 9) 	{ $retStr = "SF FtxFuturesPerp (main)"; }	
	elsif 	($clientNum == 10) 	{ $retStr = "SF FtxFSpot (main)"; }	
	elsif 	($clientNum == 11) 	{ $retStr = "SF KucoinSpot (main)"; }	
	elsif 	($clientNum == 12) 	{ $retStr = "SF Bybit Contract LinUSDT (main) 281121"; }	
	else 						{ die "error: can't determine Cornix client/exchange name"; }
	
	return $retStr;
}
1;
