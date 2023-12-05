# runs with Strawberry Perl: http://strawberryperl.com/

# runs with Strawberry Perl: http://strawberryperl.com/
# Uses hash tables (%folder1 and %folder2) to store unique elements instead
# of arrays, and it checks for differences manually without using Array::Utils.

use strict;
use warnings;
use feature qw(say);
use File::Find; 
use File::Basename;

my @content1;
my @content2;
my $fileFound;
my $theFile;
my $name;
my $fileDir;
my $ext;
my $filePath;
my $fileName;
my $logFile;
my $perlFilenameBase;
my $fh;
my $fileCount;

# create a log file (same name as this file but with .log extension)
$perlFilenameBase = basename($0);
$perlFilenameBase =~ s/\.pl//;
$logFile = "$perlFilenameBase\.log";
open ($fh, '>', $logFile) or die ("Could not open file '$logFile' $!");
say $fh "fileCount, filePath, fileName";
$fileCount = 0;

# find all files from current and subdirectories
my @paths;

my $path1 = "C:\\Users\\toepo\\local\\git-weebucket\\perl-glue-script-collection\\test1\\";
my %folder1;
find(\&fileWanted1, $path1);
foreach $fileFound (@content1) {
    # get filename, directory and extension of the found file
    $fileCount++;
    ($name, $fileDir, $ext) = fileparse($fileFound, '\..*');
    $fileDir =~ s/\//\\/g;
    $filePath = "$fileDir";
    $fileName = "$name$ext";
    $theFile = $filePath.$fileName;
    chomp $fileCount;
    chomp $filePath;
    chomp $fileName;
    say $fh "$fileCount, $fileName";
    $folder1{$fileName} = 1;
}

say $fh "-------------------------------";

my %folder2;
my $path2 = "C:\\Users\\toepo\\local\\git-weebucket\\perl-glue-script-collection\\test2\\";
find(\&fileWanted2, $path2);
foreach $fileFound (@content2) {
    # get filename, directory and extension of the found file
    $fileCount++;
    ($name, $fileDir, $ext) = fileparse($fileFound, '\..*');
    $fileDir =~ s/\//\\/g;
    $filePath = "$fileDir";
    $fileName = "$name$ext";
    $theFile = $filePath.$fileName;
    chomp $fileCount;
    chomp $filePath;
    chomp $fileName;
    say $fh "$fileCount, $fileName";
    $folder2{$fileName} = 1;
}

say $fh "----------- differences --------------------";
my @theDiff = grep { !$folder1{$_} } keys %folder2;
foreach my $fileDiff (@theDiff) {
    say $fh $fileDiff;
    say $fileDiff;
}

close($fh);
exit;

sub fileWanted1 {
    my $file = $File::Find::name;
    push @content1, $file;
    return;
}

sub fileWanted2 {
    my $file = $File::Find::name;
    push @content2, $file;
    return;
}

