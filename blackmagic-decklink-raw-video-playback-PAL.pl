#!/usr/bin/perl -w

# Converting to raw SD for playback on Blackmagic software on Decklink card

# runs with Strawberry Perl: http://strawberryperl.com/

# requires FFmpeg:
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

# Get the input video name
if (@ARGV < 1){
    say "ERROR: Must input video file to be converted";
    exit;
}
my $vidIn = $ARGV[0];

# Get name for output video
($name,$fileDir,$ext) = fileparse($vidIn,'\..*');
$fileDir =~ s/\//\\/g;
my $vidOut = "$name\.avi";

# convert to PAL DVD
system("ffmpeg -y -i $vidIn -c:v rawvideo -pix_fmt uyvy422 -target pal-dvd -an tempPalDVD.avi");
# convert to rawvideo format stripping out only the video stream (no DVD packet stream)
sleep 2;
system("ffmpeg -y -i tempPalDVD.avi -c:v rawvideo -pix_fmt uyvy422 -map 0:v:0 $vidOut");
# cleanup
sleep 2;
system("del /f /q tempPalDVD.avi");
