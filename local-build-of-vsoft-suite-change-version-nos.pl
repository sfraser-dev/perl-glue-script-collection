#!/usr/bin/perl -w

# Runs with Strawberry Perl: http://strawberryperl.com/

# Change VisualWorks/VersionNo.h and Misc/VWShared/AssemblyInfoHelper.cs
#         - eg/ 10.2.0.1ddmm, where
#             - 10 indicates major
#             - .2 indicates minor
#             - .0 indicates build
#             - .1 indicates a localbuild (revision)
#             - dd indicates the day (revision)
#             - mm indicates the month (revision)
#         - releases will have a X.Y.Z version number, local builds will have X.Y.Z.1ddmm version number
#
# Test by switching the output files between testAIH.txt / testVNO.txt and their originals ($fileToChangeAIH / $fileToChangeVNO): search for "test"

use strict;
use warnings;
use feature qw(say);
use File::Find;
use File::Basename;
use Cwd;
use POSIX qw(floor);
use File::Slurp;
use Data::Dumper;

# set these parameters
#my $vn = "10.2.7.2";
#my $vn = "10.2.7.11402";
my $vn = "10.2.7.11502";
my $folderVSoftTopLevel = "F:\\dev6_VitecC9\\GitRepo_I\\VitecC9\\VisualSoft_10.2";

# split version number into its constituents
my @vnarr = split(/\./,$vn);
my $vn_major = $vnarr[0];
my $vn_minor = $vnarr[1];
my $vn_build = $vnarr[2];
my $vn_revsn = $vnarr[3];

# files to change the version
my $fileToChangeAIH = $folderVSoftTopLevel."\\VWShared\\AssemblyInfoHelper.cs";
my $fileToChangeVNO = $folderVSoftTopLevel."\\VisualWorks\\VersionNo.h";

# check the files to change exist
checkFileExists($fileToChangeAIH) ? 1 : exit;
checkFileExists($fileToChangeVNO) ? 1 : exit;

# read AssemblyHelperInfo.cs and VersionNo.h into arrays
my @AIHarr;
my @VNOarr;
my $handle;
open $handle, '<', $fileToChangeAIH;
chomp(@AIHarr = <$handle>);
close $handle;
open $handle, '<', $fileToChangeVNO;
chomp(@VNOarr = <$handle>);
close $handle;

# adapt version numbers
my @arr;
foreach my $line (@AIHarr){
    if ($line =~ /\bAssemblyVersion\b/){
        @arr = split(/=/,$line);
        $line = $arr[0]." = "."\"".$vn."\";";
        say $line;
    }
    if ($line =~ /\bAssemblyFileVersion\b/){
        @arr = split(/=/,$line);
        $line = $arr[0]." = "."\"".$vn."\";";
        say $line;
    }
}
foreach my $line (@VNOarr){
    if ($line =~ /\bFILEVER\b/){
        @arr = split(/\bFILEVER\b/,$line);
        $line = $arr[0]." FILEVER $vn_major,$vn_minor,$vn_build,$vn_revsn";
        say $line;
    }
    if ($line =~ /\bPRODUCTVER\b/){
        @arr = split(/\bPRODUCTVER\b/,$line);
        $line = $arr[0]." PRODUCTVER $vn_major,$vn_minor,$vn_build,$vn_revsn";
        say $line;
    }
    if ($line =~ /\bSTRFILEVER\b/){
        @arr = split(/\bSTRFILEVER\b/,$line);
        $line = $arr[0]." STRFILEVER \"$vn_major,$vn_minor,$vn_build,$vn_revsn\\0\"";
        say $line;
    }
    if ($line =~ /\bSTRPRODUCTVER\b/){
        @arr = split(/\bSTRPRODUCTVER\b/,$line);
        $line = $arr[0]." STRPRODUCTVER \"$vn_major,$vn_minor,$vn_build,$vn_revsn\\0\"";
        say $line;
    }
}

# write the adapted version numbers back to their files
#open $handle, '>', "testAIH.txt" or die "Cannot open output.txt: $!";
open $handle, '>', $fileToChangeAIH or die "Cannot open output.txt: $!";
foreach (@AIHarr){
    print $handle "$_\n";
}
close $handle;
#open $handle, '>', "testVNO.txt" or die "Cannot open output.txt: $!";
open $handle, '>', $fileToChangeVNO or die "Cannot open output.txt: $!";
foreach (@VNOarr){
    print $handle "$_\n";
}
close $handle;


exit;

sub checkFileExists {
    if (@_ != 1){
        say "Error on line: ".__LINE__;
        exit;
    }
    # pass file name as first argument to this function
    my $fileName = $_[0];
    if (-e $fileName){
        #say "$fileName exists, continuing ...";
        return 1;
    }
    else {
        say "Error: file '$fileName' doesn't exist";
        return 0;
    }
}
