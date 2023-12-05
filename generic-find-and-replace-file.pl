#!/usr/bin/perl -w

# runs with Strawberry Perl: http://strawberryperl.com/

use strict;
use warnings;
use feature qw(say);
use File::Find; 
use File::Basename;
use Cwd;
use POSIX qw(floor);

my @content;
my $counter;

# find all files from current and sub directories
find( \&fileWanted, '.'); 

# replace text
$counter = 0;
foreach my $fileIn (@content) {
    # input file into array
    open my $handleIn, '<', $fileIn or die "Could not open $fileIn: $!";
    chomp (my @linesIn = <$handleIn>);
    close $handleIn;
    my @linesOut;
    # process
    foreach my $line (@linesIn) {
        $line =~ s/\brEd\b/GOLD/i;
        push @linesOut, $line;
    }
    # write processed array to file
    my $fileOut = "$fileIn".".new";    # processed lines to a new file
    #my $fileOut = $fileIn;              # processed lines to the original file
    open my $handleOut, '>', $fileOut or die "Could not open $fileOut: $!";
    foreach (@linesOut) {
        say $handleOut $_;
    }
    close $handleOut;
}

exit;

sub fileWanted{
    my $file = $File::Find::name;
    if ($file =~ /\.temp$/){
        push @content, $file;
    }
}

