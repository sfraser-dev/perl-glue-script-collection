#!/usr/bin/perl -w

# runs with Strawberry Perl: http://strawberryperl.com/

# requires MediaInfo CLI:
# https://mediaarea.net/en/MediaInfo/Download/Windows

# requires FFprobe (comes with static build of FFmpeg):
# https://ffmpeg.zeranoe.com/builds/

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
my $vidDurMI;
my $vidDurFF;
my $logFile;
my $perlFilenameBase;
my $fh;
my $fileCount;
my @probeInfo;
my @splitter;

$perlFilenameBase=basename($0);
$perlFilenameBase=~s/\.pl//;
$logFile = "$perlFilenameBase\.log";
open ($fh, '>', $logFile) or die ("Could not open file '$logFile' $!");
say $fh "fileCount, vidDurMI, vidDurFF, filePath, fileName";

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
    $vidDurMI = `MediaInfo.exe -f --Inform=Video;%Duration% \"$vidName\"`;
    @probeInfo = `ffprobe -v quiet -show_format \"$vidName\"`;
    foreach my $probeLine (@probeInfo){
        if ($probeLine =~ /duration/){
            @splitter = split(/=/, $probeLine);
            $vidDurFF = $splitter[1];
        }
    }
    chomp $fileCount;
    chomp $vidDurMI;
    chomp $vidDurFF;
    chomp $filePath;
    chomp $fileName;
    $vidDurMI = $vidDurMI/1000;
    say $fh "$fileCount, $vidDurMI, $vidDurFF$filePath, $fileName";
}
close($fh);
exit;

sub fileWanted {
    if ($File::Find::name =~ /\.m4v$/){
        push @content, $File::Find::name;
    }
    return;
}

