#!/usr/bin/perl -w

# runs with Strawberry Perl: http://strawberryperl.com/

# requires FFmpeg, the static build of FFmpeg can be found here:
# https://ffmpeg.zeranoe.com/builds/

use strict;
use warnings;
use feature qw(say);
use File::Find;
use File::Basename;
use Cwd;
use Net::Domain qw (hostname hostfqdn hostdomain);

my $name;
my $dir;
my $ext;
my $filePath;
my $filePathName;
my @videoFilesFound;

# Get a list of all videos. This takes time so tell the user
find( \&hdvVideo, '.');

foreach my $videoFile (@videoFilesFound) {
	# file path and name
	($name,$dir,$ext) = fileparse($videoFile,'\..*');
	$filePath = cwd();
    $filePath .= "/";
	my $originalName = "$filePath$name$ext";

    (my $tmpName1 = $originalName) =~ s/\[//g ;
    (my $tmpName2 = $tmpName1) =~ s/\]//g ;
    (my $outputName = $tmpName2) =~ s/\s/\_/g ;

    $outputName = substr($outputName,0,-4);
    $outputName .= ".mp4";

    say $originalName;
    say $outputName;
    my $command = `ffmpeg -y -i "$originalName" -vf "scale=iw*sar:ih,setsar=1" -crf 28 -c:a aac -b:a 80k -ac 1 -movflags +faststart $outputName`;
}

sub hdvVideo {
    if ($File::Find::name =~ /\.hdv$/){
        push @videoFilesFound, $File::Find::name;
    }
    return;
}
