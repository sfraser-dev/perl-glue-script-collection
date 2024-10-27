#!/usr/bin/perl -w

# Strawberry Perl can be downloaded from:
# http://strawberryperl.com/

# Need to install FFmpeg in your system / directory.
# A static FFmpeg build can be obtained from:
# https://ffmpeg.zeranoe.com/builds/

# Summary:
# 1.0 go through current and sub-dirs, make a copy (".bak") of all Properties.ini files
# 2.0 go through current and sub-dirs, find all ".mpg" videos
# 2.1 if, for "videoX.mpg", MP4 conversion successful (ie: "videoX.mp4" file exists), update Properties.ini info for "videoX.mpg" to "videoX.mp4"
# 2.2 if, for "videoX.mpg", MP4 conversion successful (ie: "videoX.mp4" file exists), delete the original "videoX.mpg" to save space

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
my @vidFilenameArr;
my @iniFilenameArr;
my $propIni;
my $propIniBak;
my $originalFileNameFullPath;
my $convertedFileNameFullPath;
my $strData;
my @vidNames;
my @splitter;
my $curVidName;
my $iniFile;

# find all "Properties.ini" (INI) files from the current directory and it's sub-directories; store results in @iniFilenameArr
find( \&fileWantedINI, '.');
# for the current directory and it's sub-directories, make a copy / backup of the INI files
foreach my $propIniLoop (@iniFilenameArr){
    # get file location information for the INI file
    ($name,$fileDir,$ext) = fileparse($propIniLoop,'\..*');
    $fileDir =~ s/\//\\/g;
    $propIni = "$fileDir$name$ext";
    # create backup filename for the INI file
    $propIniBak="$fileDir$name\.bak";
    # make a backup of the INI file
    system("copy /y $propIni $propIniBak");
}

# find all ".mpg" video files from the current directory and it's sub-directories; store results in @vidFilenameArr
find( \&fileWantedMPG, '.'); 
# keep a log of the videos to be converted, their new converted names and their locations / paths
foreach my $vidName (@vidFilenameArr) {
    # get filename, directory and extension of the found video
    ($name,$fileDir,$ext) = fileparse($vidName,'\..*');
    $fileDir =~ s/\//\\/g;
    $originalFileNameFullPath="$fileDir$name$ext";
    $convertedFileNameFullPath="$fileDir$name\.mp4";
    $strData = $originalFileNameFullPath."===".$convertedFileNameFullPath."===".$name."===".$fileDir;
    # full paths of videos to be converted stored in an array
    push(@vidNames, $strData);
}

# 1. read the ".mpg" path-names from the array
# 2. convert ".mpg" files to ".mp4" with FFmpeg
# 3. if "mp4" conversion successful, delete the original ".mpg" files (keeping only the ".mp4" files)
# 4. if "mp4" conversion successful, update the video extensions in the INI files to ".mp4"
foreach (@vidNames){
    @splitter = split(/===/, $_);
    $originalFileNameFullPath=$splitter[0];
    $convertedFileNameFullPath=$splitter[1];
    $curVidName=$splitter[2];
    $fileDir=$splitter[3];
    $iniFile = "$splitter[3]"."Properties.ini";

    # FFmpeg convert ".mpg" to ".mp4" at 5Mbps
    system("ffmpeg -i $originalFileNameFullPath -c:v libx264 -b:v 5000k -c:a aac -b:a 128k $convertedFileNameFullPath");
    # if the ".mp4" file doesn't exist, move on to next video in the array
    if (! -f $convertedFileNameFullPath){
        next;
    }
    # sleep before deleting the original
    say "sleeping ...";
    sleep 2;
    say "deleting ...";
    system("del /f /q $originalFileNameFullPath");
    sleep 1;

    # copy the contents of the INI file to a Perl array for processing
    open my $fileIn, '<', $iniFile or die "Could not open $iniFile: $!";
    chomp(my @linesInArr = <$fileIn>);
    close($fileIn);
    # go throught the Perl array and substitute extension ".mpg" to ".mp4" for the current video only
    foreach my $theLine (@linesInArr){
        if ( ($theLine =~ /$curVidName/) && ($theLine =~ /\.mpg$/) ){
            $theLine =~ s/\.mpg/\.mp4/;
        }
    }
    # write the updated / adapted Perl array back to the INI file
    open my $fileOut, '>', $iniFile or die "Could not open $iniFile: $!";
    foreach (@linesInArr){
        say $fileOut $_;
    }
    close($fileOut);
}

# find files with ".mpg" at the end of their names
sub fileWantedMPG {
    if ($File::Find::name =~ /\.mpg$/){
        push @vidFilenameArr, $File::Find::name;
    }
    return;
}

# find "Properties.ini" files
sub fileWantedINI {
    if ($File::Find::name =~ /Properties.ini/){
        push @iniFilenameArr, $File::Find::name;
    }
    return;
}
