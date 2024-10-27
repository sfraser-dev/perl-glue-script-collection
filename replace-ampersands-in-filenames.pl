#!/usr/bin/perl -w
# 1. Find all files containing an "@" (ampersand) in their filenames from this dir and subdirs; rename filename by replacing "@" with "_AT_".
# 2. Find all .ini files from this dir and subdirs; in these files, replace their references to filenames containing "@" with "_AT_".
use strict;
use warnings;
use feature qw(say);
use File::Find;
use File::Basename;
use File::Copy qw(move);
use Cwd;
use Cwd 'abs_path';

my $fullFileName;
my $foutLog;
my $fh_log;
my @content_at;
my @content_ini;
my @splitter;
my $beforeAt;
my $afterAt;
my $newName;
my @lines;
my @newlines;

# write a log of the changes made
$foutLog = "changedFiles.log";
open ($fh_log, ">", $foutLog) || die "Couldn't open '".$foutLog."'for writing because: ".$!;

# find files with an ampersand (@) in them recursively from this directory
my $filecount=0;
find( \&wantedFilesAt, '.');
say $fh_log "Filenames with an ampersand (@) in their name:";
foreach my $theFile (@content_at) {
	$filecount ++;
    $fullFileName = abs_path($theFile);

    # spilt the filename at the ampersand
    @splitter = split /@/, $fullFileName;
    $beforeAt = $splitter[0];
    $afterAt = $splitter[1];

    # replace ampersand with "_AT_"
    $newName = "$beforeAt"."_AT_"."$afterAt";	
    say $fh_log "$filecount: $theFile";

    # rename the file with "_AT_" instead of "@"
    move $theFile, $newName;
}

# in properties.ini, change lines containing "@" to "_AT_"
$filecount=0;
find( \&wantedFilesIni, '.');
say $fh_log "\nLines in Properties.ini files containing an ampersand (@):";
# Copy each line from the .ini file into an array.
# Find and replace eacg "@" within this array.
# Overwrite the original .ini with the data in the altered array.
foreach my $theFile (@content_ini) {
    # open the file and read lines to array
    open my $fh_ini, "<", $theFile or die "Can't open file: $!\n";
    @lines = <$fh_ini>;
    close $fh_ini;

    # create an array with the altered lines
    foreach(@lines) {
        # write line containing "@" to the log
        if ($_ =~ /@/) {
            $filecount ++;
            say $fh_log "$filecount: $theFile $_";
        }
        # alter the line, store in array
        $_ =~ s/@/_AT_/g;
        push(@newlines,$_);
    }

    # overwrite original file with lines from the altered array
    open $fh_ini, ">", $theFile or die "Can't open file: $!\n";
    print $fh_ini @newlines;
    close $fh_ini;
}
close $fh_log;
exit;

# subroutine to recursively find all files with an ampersand (@) in their name
sub wantedFilesAt {
    if ($File::Find::name =~ /@/){
        push @content_at, $File::Find::name;
    }
    return;
}

# subroutine to recursively find all files with extension .ini
sub wantedFilesIni {
    if ($File::Find::name =~ /roperties.ini/){
        push @content_ini, $File::Find::name;
    }
    return;
}


