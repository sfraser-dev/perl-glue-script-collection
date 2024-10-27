#!/usr/bin/perl -w

# Runs with Strawberry Perl: http://strawberryperl.com/

use strict;
use warnings;
use feature qw(say);
use File::Find;
use File::Basename;
use Cwd;
use POSIX qw(floor);
use File::Slurp;
use Data::Dumper;

# display incoming RTSP stream and and write it to file
my $dest="out.mp4";
#system("vlc -vvv --file-caching=3000 --live-caching=3000 \"rtsp://\@:8556/stream\" --sout=\"#duplicate{dst=display,dst=std{access=file{no-append,no-format},mux='mp4',dst='$dest'}}\"");

#system("vlc -vvv --live-caching=300 \"rtsp:\/\/\@:8556/mystream.stream\"");

# the ampersand needs to be escaped
system("vlc -vvv --live-caching=300 \"rtsp://\@:8554/stream\"");
