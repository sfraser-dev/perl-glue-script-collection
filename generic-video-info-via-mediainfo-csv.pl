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
my $logFile;
my $perlFilenameBase;
my $fh;
my $genDuration;
my $genBitrate;
my $vidFormat;
my $vidWidth;
my $vidHeight;
my $vidResolution;
my $fileCount;
my $vidFrameCount;
my $vidFrameRate;
my $vidDuration;
my $vidBitrate;

$perlFilenameBase=basename($0);
$perlFilenameBase=~s/\.pl//;
$logFile = "$perlFilenameBase\.csv";
open ($fh, '>', $logFile) or die ("Could not open file '$logFile' $!");
say $fh "media count, media path, media name, media duration (secs), media bitrate (kbps), video format, video resolution, video bitrate (kbps), video frame rate (fps), video frame count, video duration (secs)";

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
    $genDuration= `MediaInfo.exe -f --Inform=General;%Duration% \"$vidName\"`;
    $genBitrate= `MediaInfo.exe -f --Inform=General;%BitRate% \"$vidName\"`;
    $vidFormat = `MediaInfo.exe -f --Inform=Video;%Format% \"$vidName\"`;
    $vidWidth = `MediaInfo.exe -f --Inform=Video;%Width% \"$vidName\"`;
    $vidHeight = `MediaInfo.exe -f --Inform=Video;%Height% \"$vidName\"`;
    $vidBitrate= `MediaInfo.exe -f --Inform=Video;%BitRate% \"$vidName\"`;
    $vidFrameRate = `MediaInfo.exe -f --Inform=Video;%FrameRate% \"$vidName\"`;
    $vidFrameCount = `MediaInfo.exe -f --Inform=Video;%FrameCount% \"$vidName\"`;
    $vidDuration = `MediaInfo.exe -f --Inform=Video;%Duration% \"$vidName\"`;
    chomp $fileCount;
    chomp $filePath;
    chomp $fileName;
    chomp $genDuration;
    chomp $genBitrate;
    chomp $vidFormat;
    chomp $vidWidth;
    chomp $vidHeight;
    chomp $vidBitrate;
    chomp $vidFrameRate;
    chomp $vidFrameCount;
    chomp $vidDuration;
    $genDuration=$genDuration/1000;
    $vidResolution = $vidWidth."x".$vidHeight;
    $vidDuration=$vidDuration/1000;
    say $fh "$fileCount, $filePath, $fileName, $genDuration, $genBitrate, $vidFormat, $vidResolution, $vidBitrate, $vidFrameRate, $vidFrameCount, $vidDuration";
}
close($fh);
exit;

sub fileWanted {
    if ($File::Find::name =~ /\.mp4$/){
        push @content, $File::Find::name;
    }
    return;
}

