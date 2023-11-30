#!/usr/bin/perl
use warnings;
use strict;
use feature qw(say);
use Getopt::Long; # for processing command line args

require "./MySubs1.pm";
require "./MySubs2.pm";
require "./MySubs3.pm";
require "./MySubs5.pm";
require "./MySubs6.pm";
require "./MySubs10.pm";
require "./MySubs11.pm";
require "./MySubs12.pm";
require "./MySubs13.pm";

############################################################################
############################## main ########################################
############################################################################
# get command line arguments
my %args;
GetOptions( \%args,
			'file=s', 	# required: filename
			'ewf=s',	# required: entries weighting factor
			'twf=s',	# required: targets weighting factor
			'aoe=s',	# optional: amount of entries (override config file number of entries)
			'not=s',	# optional: number of targets (override config file number of targets)
			'dev=s'		# optional: dynamic entry value for dynamic risk fixed position size
          ) or die "Invalid command line arguments!";
my $pathToFile = $args{file};
my $weightingFactorEntries = $args{ewf};		# not in the trade config file
my $weightingFactorTargets = $args{twf};		# not in the trade config file
my $numberOfEntriesCommandLine = $args{aoe};	# in the config file, but override config file value if command line value given
my $numberOfTargetsCommandLine = $args{not};	# in the config file, but override config file value if command line value given
my $dynamicEntryValue = $args{dev};				# not in the trade config file (only an optional command line argument)


unless ($args{file}) 	{ die "Missing --file!\n"; }			# --file (-f) FileName 
unless ($args{ewf}) 	{ $weightingFactorEntries=0; }			# --ewf  (-e) entries weighting factor (for spreading percentages)
unless ($args{twf}) 	{ $weightingFactorTargets=0; }			# --twf  (-t) targets weighting factor (for spreading percentages)
unless ($args{aoe}) 	{ $numberOfEntriesCommandLine=0; }		# --aoe  (-a) amount of entries 
unless ($args{not}) 	{ $numberOfTargetsCommandLine=0; }		# --not  (-n) number of targets 
unless ($args{dev}) 	{ $dynamicEntryValue=0; }				# --dev  (-d) dynamic entry value  

# read trade file
my %configHash = MySubs10::readTradeConfigFile($pathToFile);

# if number of entries/targets is given on the command line, override the number of entries/targets given in the config file
if ($numberOfEntriesCommandLine != 0) { $configHash{numberOfEntries} = $numberOfEntriesCommandLine; }
if ($numberOfTargetsCommandLine != 0) { $configHash{numberOfTargets} = $numberOfTargetsCommandLine; }

# check entries and targets make logical sense & determine if trade is a long or a short
my $isTradeALong = MySubs13::checkValuesFromConfigFile(	$configHash{numberOfEntries},
												$configHash{numberOfTargets},
												$configHash{highEntry},
												$configHash{lowEntry},
												$configHash{highTarget},
												$configHash{lowTarget},
												$configHash{stopLoss},
												$configHash{leverage},
												$configHash{noDecimalPlacesForEntriesTargetsAndSLs},
												$configHash{wantedToRiskAmount}
											);
											
# old and simple way of using Cornix Free Text, generate a version of this too as well as the advanced template
my @cornixTemplateSimple = MySubs11::createCornixFreeTextSimpleTemplate($configHash{coinPair},
																	$configHash{leverage},
																	$configHash{highEntry},
																	$configHash{lowEntry},
																	$configHash{highTarget},
																	$configHash{lowTarget},
																	$configHash{stopLoss},
																	$configHash{noDecimalPlacesForEntriesTargetsAndSLs},
																	$configHash{numberOfEntries},
																	$configHash{numberOfTargets},
																	$isTradeALong);

# create the advanced cornix template as an array of strings
my @cornixTemplateAdvanced = MySubs5::createCornixFreeTextAdvancedTemplate($configHash{coinPair},
													MySubs12::getCornixClientName($configHash{client}),
													$configHash{leverage},
													$configHash{numberOfEntries},
													$configHash{highEntry},
													$configHash{lowEntry},
													$configHash{numberOfTargets},
													$configHash{highTarget},
													$configHash{lowTarget},
													$configHash{stopLoss},
													$configHash{noDecimalPlacesForEntriesTargetsAndSLs},
													$configHash{wantedToRiskAmount},
													$isTradeALong,
													$weightingFactorEntries,
													$weightingFactorTargets,
													$dynamicEntryValue);
													
# print templates to screen
say @cornixTemplateSimple;
say @cornixTemplateAdvanced;

# print template to file
my $scriptName = basename($0);
my $fileName = MySubs1::createOutputFileName($scriptName, $configHash{coinPair}, $isTradeALong);
my $fh;
open ($fh, '>', $fileName) or die ("Could not open file '$fileName' $!");
say $fh @cornixTemplateSimple;
say $fh @cornixTemplateAdvanced;
close $fh;
	
