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

# kill any vlc.exe processes that may be running (it'll keep running even if perl command is stopped or console killed)
system("Taskkill /IM vlc.exe /F");
