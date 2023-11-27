#!/usr/bin/perl -w

# runs with Strawberry Perl: http://strawberryperl.com/

use strict;
use warnings;
use feature qw(say);
use File::Find; 
use File::Basename;
use Cwd;
use POSIX qw(floor);

my @content;
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
find( \&fileWanted, '.'); 
foreach $fileFound (@content) {
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
    say $fh "$fileCount, $theFile";
    # don't use system("del xx"), use "unlink" to delete 
    # (also File::Copy / "rename" to copy / move ), makes code more OS portable
    unlink $theFile; 
}

close($fh);
exit;

sub fileWanted{
    my $file = $File::Find::name;
    if ($file =~ /\.scc$/){
        push @content, $file;
    }
    if ($file =~ /\.vspscc$/){
        push @content, $file;
    }
    return;
}

