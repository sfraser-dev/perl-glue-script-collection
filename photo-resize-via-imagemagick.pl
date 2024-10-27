#!/usr/bin/perl -w
#
# Usage: perl photoresize.pl --topdir /path/to/toplevel/dir
#
# This script runs with Strawberry Perl:
# http://strawberryperl.com/
#
# This script requires the ImageMagic "convert" command (Linux)
#
use strict;
use warnings;
use feature qw(say);
use File::Find;
use File::Basename;
use Cwd;
use POSIX qw(floor);
use File::Slurp qw(read_dir); # may need to run: perl -e'use CPAN; install "File::Slurp"'
use File::Spec::Functions qw(catfile);
use Net::Domain qw (hostname hostfqdn hostdomain);
use Getopt::Long;
use Time::Local;
use Data::Dumper;

my $newAppend = "_newSize";
my $fileType = ".jpg";
my @filesFound;  # global array of found videos

# parse the command line arguments
my $topLevelDir = getCommandLineArgs();

# full pathname of all videos found stored in @filesFound
find( \&findFiles, $topLevelDir);

# track changes made and new videos created by in a csv file
my $fout = "changes.csv";
open (my $fh_out, ">", $fout) || die "Couldn't open '".$fout."'for writing because: ".$!;
say $fh_out "Filename";

# process each file found
foreach my $foundFile (@filesFound) {
	# file path and name (relative to the directory that this perl script is in)
    my ($name, $dir, $ext, $dataDir);
    getFileAndDirInfo(\$name,\$dir,\$ext,\$dataDir,\$foundFile);
    # directory that this perl script is in

    my $newExtension = "$newAppend"."$fileType";
    my $inputFileName = $dir.$name.$ext;
    my $outputFileName = $dir.$name.$newExtension;

    # only change originals (by "continuing" foreach loop if input already has the new filename extension)
    next if ($inputFileName =~ /\Q$newAppend\E/);

    system("convert -resize 25% $inputFileName $outputFileName");
    #say "ifn = $inputFileName";  # DEBUG
    #say "ofn = $outputFileName"; # DEBUG

    # write to CSV file
    my $str = sprintf ("$outputFileName");
    say $fh_out $str;
}

close $fh_out;
exit 0;

# subroutine to recursively find all required image files
sub findFiles {
    # expect no arguments, uses globals
    if (@_ != 0){
        say "Error on line: ".__LINE__;
        exit 1;
    }

    if ($File::Find::name =~ /\Q$fileType\E$/){
        push @filesFound, $File::Find::name;
    }
}

# subroutine to get the command line arguments
sub getCommandLineArgs {
    # expect no argumets
    if (@_ != 0) {
        say "Error on line: ".__LINE__;
        exit 1;
    }

    my %args;
    GetOptions(\%args,
        "topdir=s",
    ) or die "Invalid options arguments passed to $0\nUsage is $0 -topdir <topLevelDir>\n"; # die if no -topdir switch
    die "Missing -topdir!" unless $args{topdir}; # die if no argument to the -topdir switch
    # check the directory passed to the -topdir switch exists
    my $topLevelDir = $args{"topdir"};
    if (! -d $topLevelDir) {
        say "Directory $topLevelDir does not exist ... exiting";
        exit 1;
    }
    return $topLevelDir;
}

# subroutine to get the filename and directory information for the found videos
sub getFileAndDirInfo {
    # expect five arguments
    if (@_ != 5){
        say "Error on line: ".__LINE__;
        exit 1;
    }
    my $nameloc;
    my $dirloc;
    my $extloc;
    my $vfloc = $_[4];

    ($nameloc,$dirloc,$extloc) = fileparse($$vfloc,'\..*');
    ${$_[0]} = $nameloc;
    ${$_[1]} = $dirloc;
    ${$_[2]} = $extloc;
}
