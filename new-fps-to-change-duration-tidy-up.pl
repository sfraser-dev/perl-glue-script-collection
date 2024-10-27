#!/usr/bin/perl -w
#
# This script runs with Strawberry Perl:
# http://strawberryperl.com/
#
use strict;
use warnings;
use feature qw(say);
use File::Find;
use File::Basename;
use Cwd;
use POSIX qw(floor);
use File::Slurp qw(read_dir);
use File::Spec::Functions qw(catfile);
use Net::Domain qw (hostname hostfqdn hostdomain);
use Getopt::Long;
use Time::Local;
use Data::Dumper;

my $newAppend = "_newDuration";
my $videoType = ".asf";

my @content;

find( \&findOriginalAsfVideos, '.');

# process each video file found
foreach my $videoFile (@content) {
    print "deleting $videoFile ... ";
    unlink $videoFile; # deletes the file
    say " done";
}

exit 0;

# subroutine to recursively find all required video files
sub findOriginalAsfVideos {
    if ($File::Find::name =~ /\Q$newAppend$videoType\E$/){
        push @content, $File::Find::name;
    }
    return;
}
