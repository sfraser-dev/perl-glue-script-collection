#!/usr/bin/perl -w
use strict;
use warnings;
use feature qw(say);
use Win32::DriveInfo;

my @drives = Win32::DriveInfo::DrivesInUse();
say "List of drives with and without VisualWorks directories:";
foreach my $i (@drives) {
    # Search for drives with a VisualWorks directory
    if (-d "$i:\\VisualWorks") {
        say "Logging: $i:\\VisualWorks";
    }
    else {
        say "Non-logging $i:\\";
    }
}

