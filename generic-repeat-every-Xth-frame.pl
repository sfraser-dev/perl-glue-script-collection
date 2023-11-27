#!/usr/bin/perl -w

# runs with Strawberry Perl: http://strawberryperl.com/
# 
# dealing with image files created from a video via:
# >> ffmpeg -i PAL-VIDEO.mp4 pic%09d.jpg
# re-make the video from images:
# >> ffmpeg -r 25 -f image2 -s 720x576 -i zimg%09d.jpg -c:v libx264 -crf 15 -pix_fmt yuv420p zzNewVid.mp4 

use strict;
use warnings;
use feature qw(say);
use File::Find; 
use File::Basename;
use File::Copy qw(copy);
use Cwd;
use POSIX qw(floor);

my @content;
my $fileFound;
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

my $repeatEveryXthFrame;
my $modCount;
my $copyName;
my $numFormat;

# create a log file (same name as this file but with .log extension)
$perlFilenameBase=basename($0);
$perlFilenameBase=~s/\.pl//;
$logFile = "$perlFilenameBase\.log";
open ($fh, '>', $logFile) or die ("Could not open file '$logFile' $!");
say $fh "fileCount, filePath, fileName";

$fileCount=0;
$modCount = 0;
#$repeatEveryXthFrame = 401;
$repeatEveryXthFrame = 3;

# find all files from current and sub directories
find( \&fileWanted, '.'); 
foreach $fileFound (@content) {
    # get filename, directory and extension of the found file
    $fileCount++;
    $modCount++;
    ($name,$fileDir,$ext) = fileparse($fileFound,'\..*');
    $fileDir =~ s/\//\\/g;
    $filePath="$fileDir";
    $fileName="$name$ext";
    chomp $fileCount;
    chomp $filePath;
    chomp $fileName;
    
    # using File::Copy to copy the file
    $numFormat = sprintf("%09d",$fileCount);
    $copyName="zimg".$numFormat.".jpg";
    copy $fileName, $copyName;
    say $fh "$fileCount, $filePath, $copyName";
    say "$fileCount, $filePath, $copyName";
    if ($modCount == $repeatEveryXthFrame) {
        # reset "modulo" count
        $modCount = 0;
        $fileCount++;
        $numFormat = sprintf("%09d",$fileCount);
        $copyName="zimg".$numFormat.".jpg";
        copy $fileName, $copyName;
        say $fh "$fileCount, $filePath, $copyName - repeated/copied";
        say "$fileCount, $filePath, $copyName - repeated/copied";
    }
}

close($fh);
exit;

# will get images in numerical order from "ffmpeg -i VIDEO.mp4 pic%09d.jpg"
sub fileWanted{
    my $file = $File::Find::name;
    if ($file =~ /\.jpg$/){
        push @content, $file;
    }
    return;
}

