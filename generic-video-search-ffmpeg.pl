#!/usr/bin/perl -w

# Strawberry Perl can be downloaded from:
# http://strawberryperl.com/

# Need to install FFmpeg in your system / directory.
# A static FFmpeg build can be obtained from:
# https://ffmpeg.zeranoe.com/builds/

use strict;
use warnings;
use feature qw(say);
use File::Find; 
use File::Basename;
use Cwd;
use POSIX qw(floor);

my $name;
my $fileDir;
my $ext;
my @content;
my $originalFileNameFullPath;
my $convertedFileNameFullPath;
my $strData;
my @allArr;
my @splitter;

# top level folder of containing videos to be fixed; this folder must exist (subdirs in this folder also searched)
my $vidOriginalsFolder = "F:\\VIDEO_FIX\\mpegToH264";  # use double-backslashes ('\\') in the pathname

if (-d $vidOriginalsFolder){
    say "converting .mpg videos in folder '$vidOriginalsFolder' and it's sub-folders";
}
else {
    say "Error: folder '$vidOriginalsFolder' doesn't exist, please point to the folder containing the videos to be converted.";
    exit;
}

# find the video files from the names directory and it's sub-directories
find( \&fileWanted, $vidOriginalsFolder); 

# keep a log of all the video files to be converted
foreach my $vidName (@content) {
    # get filename, directory and extension of the found video
    ($name,$fileDir,$ext) = fileparse($vidName,'\..*');
    $fileDir =~ s/\//\\/g;
    $originalFileNameFullPath="$fileDir$name$ext";
    $convertedFileNameFullPath="$fileDir$name\.mp4";
    $strData = $originalFileNameFullPath."===".$convertedFileNameFullPath;
    # full paths of videos to be converted stored in an array
    push(@allArr, $strData);
}

# read pathnames from the array and run FFmpeg to convert
foreach (@allArr){
    @splitter = split(/===/, $_);
    $originalFileNameFullPath=$splitter[0];
    $convertedFileNameFullPath=$splitter[1];
    system("ffmpeg -i $originalFileNameFullPath -f mp4 $convertedFileNameFullPath");
}

# find files with ".mpg" at the end of their names
sub fileWanted {
    if ($File::Find::name =~ /\.mpg$/){
        push @content, $File::Find::name;
    }
    return;
}

