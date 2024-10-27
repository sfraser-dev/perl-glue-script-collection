#!/usr/bin/perl -w
# FFMPEG MP4 video conversion, file re-naming and copying converted MP4 videos to the Dataset folder.

use strict;
use warnings;
use feature qw(say);

# Run FFMPEG conversions and copy results to the Dataset parent folder above.
sub runFfmpegConversion {
    my $id = $_[0];

    if ($id eq "libx264"){
        # Re-encode video using libx264.
        system("ffmpeg -y -i 20131015081438953\@HDPORT.orig.mp4   -c:v libx264 -c:a copy 20131015081438953\@HDPORT.libx264.mp4");
        system("ffmpeg -y -i 20131015081438958\@HDCENTRE.orig.mp4 -c:v libx264 -c:a copy 20131015081438958\@HDCENTRE.libx264.mp4");
        system("ffmpeg -y -i 20131015081439083\@HDSTBD.orig.mp4   -c:v libx264 -c:a copy 20131015081439083\@HDSTBD.libx264.mp4");
    }
    elsif ($id eq "libx264mp3"){
        # Convert audio on libx264 converted videos from ADTS AAC audio to MP3.
        system("ffmpeg -y -i 20131015081438953\@HDPORT.libx264.mp4   -c:v copy -c:a mp3 20131015081438953\@HDPORT.libx264mp3.mp4");
        system("ffmpeg -y -i 20131015081438958\@HDCENTRE.libx264.mp4 -c:v copy -c:a mp3 20131015081438958\@HDCENTRE.libx264mp3.mp4");
        system("ffmpeg -y -i 20131015081439083\@HDSTBD.libx264.mp4   -c:v copy -c:a mp3 20131015081439083\@HDSTBD.libx264mp3.mp4");
    }
    elsif ($id eq "mp3"){
        # Convert audio from  ADTS AAC audio to MP3.
        system("ffmpeg -y -i 20131015081438953\@HDPORT.orig.mp4   -c:v copy -c:a mp3 20131015081438953\@HDPORT.mp3.mp4");
        system("ffmpeg -y -i 20131015081438958\@HDCENTRE.orig.mp4 -c:v copy -c:a mp3 20131015081438958\@HDCENTRE.mp3.mp4");
        system("ffmpeg -y -i 20131015081439083\@HDSTBD.orig.mp4   -c:v copy -c:a mp3 20131015081439083\@HDSTBD.mp3.mp4");
    }
    elsif ($id eq "libvoaac125"){
        # Re-encode audio using libvo_aacenc @ 125kbps
        system("ffmpeg -y -i 20131015081438953\@HDPORT.orig.mp4   -c:v copy -c:a libvo_aacenc -b:a 125k 20131015081438953\@HDPORT.libvoaac125.mp4");
        system("ffmpeg -y -i 20131015081438958\@HDCENTRE.orig.mp4 -c:v copy -c:a libvo_aacenc -b:a 125k 20131015081438958\@HDCENTRE.libvoaac125.mp4");
        system("ffmpeg -y -i 20131015081439083\@HDSTBD.orig.mp4   -c:v copy -c:a libvo_aacenc -b:a 125k 20131015081439083\@HDSTBD.libvoaac125.mp4");
    }
    elsif ($id eq "libvoaac128"){
        # Re-encode audio using libvo_aacenc @ 128kbps
        system("ffmpeg -y -i 20131015081438953\@HDPORT.orig.mp4   -c:v copy -c:a libvo_aacenc -b:a 128k 20131015081438953\@HDPORT.libvoaac128.mp4");
        system("ffmpeg -y -i 20131015081438958\@HDCENTRE.orig.mp4 -c:v copy -c:a libvo_aacenc -b:a 128k 20131015081438958\@HDCENTRE.libvoaac128.mp4");
        system("ffmpeg -y -i 20131015081439083\@HDSTBD.orig.mp4   -c:v copy -c:a libvo_aacenc -b:a 128k 20131015081439083\@HDSTBD.libvoaac128.mp4");
    }
    elsif ($id eq "aac"){
        # Re-encode audio using aac @ 125kbps
        system("ffmpeg -y -i 20131015081438953\@HDPORT.orig.mp4   -c:v copy -c:a aac -strict -2 -b:a 125k 20131015081438953\@HDPORT.strictaac125.mp4");
        system("ffmpeg -y -i 20131015081438958\@HDCENTRE.orig.mp4 -c:v copy -c:a aac -strict -2 -b:a 125k 20131015081438958\@HDCENTRE.strictaac125.mp4");
        system("ffmpeg -y -i 20131015081439083\@HDSTBD.orig.mp4   -c:v copy -c:a aac -strict -2 -b:a 125k 20131015081439083\@HDSTBD.strictaac125.mp4");
    }
    elsif ($id eq "orig"){
        # No conversion needed, just a file copy / re-name.
    }
    else {
        say "Error in selecting which FFMPEG commands to run.";
        exit 1;
    }
}

# Select one processed (or original) video to be copied to the Dataset for use by Review or Edit.
my $searchid = "orig";
#my $searchid = "libx264";
#my $searchid = "libx264mp3";
#my $searchid = "mp3";
#my $searchid = "libvoaac125";
#my $searchid = "libvoaac128";
#my $searchid = "aac";
#runFfmpegConversion($searchid);

# Create an array list of all .mp4 files in the current directory.
opendir(DIR,".");
my @files = grep (/\.mp4$/,readdir(DIR));
closedir(DIR);

# Default Dataset names for port, centre and stbd video files used by Review and Edit.
my $mp4port = "20131015081438953\@HDPORT.mp4";
my $mp4centre = "20131015081438958\@HDCENTRE.mp4";
my $mp4stbd = "20131015081439083\@HDSTBD.mp4";

# Do the video copying. Keep the FFMPEG reformatted files in a different directory
# to the Dataset or the camera choices in Review and Edit will not be HDPORT, HDCENTRE
# and HDSTBD (and this will cause problems as it remembers the last 8 names after "@"
# and before ".mp4" from the filename).
foreach my $file (@files) {
	if ($file =~ m/PORT\.$searchid\./ ) {
		say "copy /Y $file ..\\$mp4port";
		system("copy /Y $file ..\\$mp4port");
	} elsif ($file =~ m/CENTRE\.$searchid\./ ) {
		say "copy /Y $file ..\\$mp4centre";
		system("copy /Y $file ..\\$mp4centre");
	} elsif ($file =~ m/STBD\.$searchid\./ ) {
		say "copy /Y $file ..\\$mp4stbd";
		system("copy /Y $file ..\\$mp4stbd");
	}
}
