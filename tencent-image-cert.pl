#!/usr/bin/perl -w

# runs with Strawberry Perl: http://strawberryperl.com/

use strict;
use warnings;
use feature qw(say);
use File::Find;
use File::Basename;
use Cwd;
use POSIX qw(floor);

use List::MoreUtils qw(uniq);

use Time::HiRes qw(time);
use POSIX qw(strftime);

my @content;
my $fileFound;
my $theFile;
my $name;
my $fileDir;
my $ext;
my $filePath;
my $fileName;
my $fileExtn;
my $frameCount;
my $logFile;
my $perlFilenameBase;
my $fh;
my $fileCount;

my $filePathOut;
my $fileNameOut;
my $fileExtnOut;
my $theFileOut;

my $folder380acIMAGE2;
my $folder380acVIDEO;
my $folderToSearch;
my @extnArray;
my @uniqueExtn;
my $createdDirAlready;

# create a log file (same name as this file but with .log extension)
$perlFilenameBase=basename($0);
$perlFilenameBase=~s/\.pl//;
$logFile = "$perlFilenameBase\.log";
open ($fh, '>', $logFile) or die ("Could not open file '$logFile' $!");
say $fh "fileCount, filePath, fileName";
$fileCount=0;
$createdDirAlready = 0;

# should just get images in here
$folder380acIMAGE2 = "H:\\gymfestTencent_TEST_190511\\tencent\\MicroMsg\\380ac\\image2\\";
# should just get videos in here
$folder380acVIDEO = "H:\\gymfestTencent_TEST_190511\\tencent\\MicroMsg\\380ac\\video\\";

$folderToSearch = $folder380acIMAGE2;
#$folderToSearch = $folder380acVIDEO;

# find all files from current and sub directories
find( \&fileWanted, $folderToSearch);
foreach $fileFound (@content) {
    # get filename, directory and extension of the found file
    $fileCount++;
    ($name,$fileDir,$ext) = fileparse($fileFound,'\..*');
    $fileDir =~ s/\//\\/g;
    $filePath="$fileDir";
    $fileName="$name";
    $fileExtn="$ext";
    $theFile=$filePath.$fileName.$fileExtn;
    chomp $fileCount;
    chomp $filePath;
    chomp $fileName;
    chomp $fileExtn;
    #say "$fileCount, $theFile";
    say $fh "$fileCount, $theFile";

    # keep a record of all extensions found
    push @extnArray, $fileExtn;

    # get timestamp (date) for folder creation
    my $t = time;
    my $date = strftime "%Y%m%d%H%M%S", localtime $t;
    $date .= sprintf "%03d", ($t-int($t))*1000; # without rounding

    $filePathOut=$folderToSearch;
    $filePathOut .= "00000_CLEANED_".$date;
    say $filePathOut;
    if (!$createdDirAlready) {
        # create a unique output folder
        unless(-e $filePathOut or mkdir $filePathOut) {
            die "Unable to create $filePathOut\n";
        }
        $createdDirAlready = 1;
    }

}

# find unique values in the array of extensions
@uniqueExtn = uniq @extnArray;
foreach (@uniqueExtn) {
    say $_;
}

close($fh);
exit;

sub fileWanted{
    my $file = $File::Find::name;

    # view all files
    #push @content, $file;
    #return;

    # VIDEO/
    if ($file =~ /\.mp4$/){
        push @content, $file;
    }
    # IMAGE2/
    if ($file =~ /\.jpg$/){
        push @content, $file;
    }
    if ($file =~ /\.png$/){
        push @content, $file;
    }

    # note: MicroMsg/380ac/image2/ and MicroMsg/380ac/video only
    # have .mp4, .jpg by default
    # I may have copied (a screenshot) into WeChat which will be .png

    # MicroMsg/380ac/video
    # Should only have videos, images of same name as a video will be thumbnails (don't save thumbnails)
    # sendXXXXX.jpg will be thumbnails of videos I've sent (don't save)
    # WeChat - "Me" - Settings - General - Photos, Videos & Files -
    #    do not auto-download
    #    do not auto-save photos
    #    do not auto-save videos

    return;
}
