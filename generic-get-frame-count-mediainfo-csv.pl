#!/usr/bin/perl -w

# runs with Strawberry Perl: http://strawberryperl.com/

# requires MediaInfo CLI:
# https://mediaarea.net/en/MediaInfo/Download/Windows

use strict;
use warnings;
use feature qw(say);
use File::Find; 
use File::Basename;
use Cwd;
use POSIX qw(floor);

my @content;
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

$perlFilenameBase=basename($0);
$perlFilenameBase=~s/\.pl//;
$logFile = "$perlFilenameBase\.log";
open ($fh, '>', $logFile) or die ("Could not open file '$logFile' $!");
say $fh "fileCount, frameCount, filePath, fileName";

# find all wanted files from current and sub directories
find( \&fileWanted, '.'); 
$fileCount=0;
foreach my $vidName (@content) {
    # get filename, directory and extension of the found video
    $fileCount++;
    ($name,$fileDir,$ext) = fileparse($vidName,'\..*');
    $fileDir =~ s/\//\\/g;
    $filePath="$fileDir";
    $fileName="$name$ext";
    $frameCount = `MediaInfo.exe -f --Inform=Video;%FrameCount% \"$vidName\"`;
    chomp $fileCount;
    chomp $frameCount;
    chomp $filePath;
    chomp $fileName;
    say $fh "$fileCount, $frameCount, $filePath, $fileName";
}
close($fh);
exit;

sub fileWanted {
    if ($File::Find::name =~ /\.mp4$/){
        push @content, $File::Find::name;
    }
    return;
}

