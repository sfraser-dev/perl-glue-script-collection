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
my $fileCount;
my $frameCount;
my $newName;

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

    # HD
    if ($fileName =~ /_Ch1/){
        say "Ch1: $fileCount, $frameCount, $filePath, $fileName";
        $newName = substr($fileName, 0, -4) . ".mpg";
        say "$newName";
        system("ffmpeg -y -i $fileName -c:v mpeg2video -b:v 20M -c:a mp2 -b:a 128k -f mpeg $newName");
    }

    # SD
    if ($fileName =~ /_Ch2/){
        say "Ch2: $fileCount, $frameCount, $filePath, $fileName";
        $newName = substr($fileName, 0, -4) . ".mpg";
        say "$newName";
        system("ffmpeg -y -i $fileName -c:v mpeg2video -b:v 5M -c:a mp2 -b:a 128k -f mpeg $newName");;
    }
    if ($fileName =~ /_Ch3/){
        say "Ch3: $fileCount, $frameCount, $filePath, $fileName";
        $newName = substr($fileName, 0, -4) . ".mpg";
        say "$newName";
        system("ffmpeg -y -i $fileName -c:v mpeg2video -b:v 5M -c:a mp2 -b:a 128k -f mpeg $newName");
    }


}
exit;

sub fileWanted {
    if ($File::Find::name =~ /\.mp4$/){
        push @content, $File::Find::name;
    }
    return;
}
