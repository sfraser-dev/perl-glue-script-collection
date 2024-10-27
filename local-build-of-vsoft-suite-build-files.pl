#!/usr/bin/perl -w

# Runs with Strawberry Perl: http://strawberryperl.com/

# To create a localbuild:
# 1) Run changeVersionNos.pl to change the version numbers in VisualWorks/VersionNo.h and VWShared/AssemblyInfoHelper.cs
# 2) Make a ReleaseDVR build
# 3) Create a XXX/YYY/localbuildZZZZZ/bin folder and a XXX/YYY/localbuildZZZZZ/symbols folder in any directory (full path names are used here)
# 4) Set the $folderToAnalyse, $folderToCopyBin and $folderToCopySymbols parameters below
# 5) Test run this Perl script (with the system copy/xcopy commands commented out: search for "system")
# 6) Run this Perl script to:
#         - copy all DLLs and EXEs from bin/release/ to XXX/YYY/localbuildZZZZZ/bin
#         - copy all SYMBOLs (.pdb) from bin/release/ to XXX/YYY/localbuildZZZZZ/symbols/

use strict;
use warnings;
use feature qw(say);
use File::Find;
use File::Basename;
use Cwd;
use POSIX qw(floor);
use File::Slurp;
use Data::Dumper;

# check existance of folders to analyse and copy to
my $folderToAnalyse     = "F:\\dev6_VitecC9\\GitRepo_I\\VitecC9\\VisualSoft_10.2\\bin\\release";
my $folderToCopyBin     = "F:\\zlocalbuild\\bin";
my $folderToCopySymbols = "F:\\zlocalbuild\\symbols";

# check the destination folder exist
checkFolderExists($folderToAnalyse)     ? 1 : exit;
checkFolderExists($folderToCopyBin)     ? 1 : exit;
checkFolderExists($folderToCopySymbols) ? 1 : exit;

# find all the DLLs, EXEs and PDBs from the folder to analyse (not its sub-folders!)
opendir my $curdir, $folderToAnalyse or die "Cannot open directory: $!";
my @allfiles = readdir $curdir;
closedir $curdir;
my @DLLs;
my @EXEs;
my @PDBs;
foreach (@allfiles){
    if ($_ =~ /\.dll$/) {
        my $fullNameDll = $folderToAnalyse."\\$_";
        my $LB_fullNameDll = $folderToCopyBin."\\$_";
        push(@DLLs, [$fullNameDll, $LB_fullNameDll]);
    }
    if ($_ =~ /\.exe$/) {
        my $fullNameExe = $folderToAnalyse."\\$_";
        my $LB_fullNameExe = $folderToCopyBin."\\$_";
        push(@EXEs, [$fullNameExe, $LB_fullNameExe]);
    }
    if ($_ =~ /\.pdb$/) {
        my $fullNamePdb = $folderToAnalyse."\\$_";
        my $LB_fullNamePdb = $folderToCopySymbols."\\$_";
        push(@PDBs, [$fullNamePdb, $LB_fullNamePdb]);
    }
}

# copy all the DLLs, EXEs and PDBs to the localbuild folder
for (my $i=0; $i<scalar(@DLLs); $i++){
    my $sourcefile = $DLLs[$i][0];
    my $destfile = $DLLs[$i][1];
    system("copy /Y \"$sourcefile\" \"$destfile\"");
    say $destfile;
}
for (my $i=0; $i<scalar(@EXEs); $i++){
    my $sourcefile = $EXEs[$i][0];
    my $destfile = $EXEs[$i][1];
    system("copy /Y \"$sourcefile\" \"$destfile\"");
    say $destfile;
}
for (my $i=0; $i<scalar(@PDBs); $i++){
    my $sourcefile = $PDBs[$i][0];
    my $destfile = $PDBs[$i][1];
    system("copy /Y \"$sourcefile\" \"$destfile\"");
    say $destfile;
}

# find all folders in the folder to analyse
my $rootdir = $folderToAnalyse;
for my $dir (grep { -d "$rootdir/$_" } read_dir($rootdir)) {
    if ($dir =~ /localbuild/){
        # do this incase the "localbuild" folder is in $folderToAnalyse/
        say "WARNING: Not copying the localbuild folder";
        next;
    }
    # copy them all (recursively) to the localbuild folder
    my $sourcefolder = $folderToAnalyse."\\$dir";
    my $destfolder = $folderToCopyBin."\\$dir";
    system("xcopy \"$sourcefolder\" \"$destfolder\" /E /Y /I /Q");
    say $destfolder;
}
exit;

sub checkFolderExists {
    if (@_ != 1){
        say "Error on line: ".__LINE__;
        exit;
    }
    # pass folder name as first argument to this function
    my $folderName = $_[0];
    if (-d $folderName){
        #say "$folderName exists, continuing ...";
        return 1;
    }
    else {
        say "Error: folder '$folderName' doesn't exist";
        return 0;
    }
}
