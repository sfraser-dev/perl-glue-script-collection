#!/usr/bin/perl -w

# runs with Strawberry Perl: http://strawberryperl.com/

use strict;
use warnings;
use feature qw(say);
use File::Find; 
use File::Basename;
use Cwd;
use POSIX qw(floor);
use Array::Utils qw(:all); # install via: cpan Array::Utils

my @content1;
my @content2;
my $fileFound;
my $theFile;
my $name;
my $fileDir;
my $ext;
my $filePath;
my $fileName;
my $frameCount;
my $logFile;
my $perlFilenameBase;
my $fh;
my $fileCount;

# create a log file (same name as this file but with .log extension)
$perlFilenameBase=basename($0);
$perlFilenameBase=~s/\.pl//;
$logFile = "$perlFilenameBase\.log";
open ($fh, '>', $logFile) or die ("Could not open file '$logFile' $!");
say $fh "fileCount, filePath, fileName";
$fileCount=0;

# find all files from current and sub directories
my @paths;

my $path1 = "F:\\dev7_2016_10p4\\GitRepo_J\\vss2016_10p4_vstudio2015\\bin\\release\\DorsaLista\\";
my @folder1;
find( \&fileWanted1, $path1); 
foreach $fileFound (@content1) {
    # get filename, directory and extension of the found file
    $fileCount++;
    ($name,$fileDir,$ext) = fileparse($fileFound,'\..*');
    $fileDir =~ s/\//\\/g;
    $filePath="$fileDir";
    $fileName="$name$ext";
    $theFile=$filePath.$fileName;
    chomp $fileCount;
    chomp $filePath;
    chomp $fileName;
    say $fh "$fileCount, $fileName";
    push @folder1, $fileName;
}


say $fh "-------------------------------";

my @folder2;
my $path2 = "C:\\VitecC9SDK\\VM4C9_1_05_03\\extractHere\\DL_vm4c9sdk_v01.05.03Copy\\bin\\DorsaLista";
find( \&fileWanted2, $path2); 
foreach $fileFound (@content2) {
    # get filename, directory and extension of the found file
    $fileCount++;
    ($name,$fileDir,$ext) = fileparse($fileFound,'\..*');
    $fileDir =~ s/\//\\/g;
    $filePath="$fileDir";
    $fileName="$name$ext";
    $theFile=$filePath.$fileName;
    chomp $fileCount;
    chomp $filePath;
    chomp $fileName;
    say $fh "$fileCount, $fileName";
    push @folder2, $fileName;
}


say $fh "----------- differences --------------------";
my @theDiff = array_diff(@folder1, @folder2);
foreach my $fileDiff (@theDiff) {
    say $fh $fileDiff;
    say $fileDiff;
}

close($fh);
exit;

sub fileWanted1{
    my $file = $File::Find::name;
    push @content1, $file;
    return;
}

sub fileWanted2{
    my $file = $File::Find::name;
    push @content2, $file;
    return;
}

