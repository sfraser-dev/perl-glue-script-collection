#!/usr/bin/perl -w

# runs with Strawberry Perl: http://strawberryperl.com/

use strict;
use warnings;
use feature qw(say);
use File::Find;
use File::Basename;
use Cwd;
use POSIX qw(floor);
use File::Slurp;

my @contentVcxProj;
my @contentCsProj;
my $name;
my $fileDir;
my $ext;
my $filePath;
my $fileName;
my $folderToAnalyse;
my $fullPathname;

$folderToAnalyse = "F:\\dev3\\GitRepo_F\\vss2016_10p2_vstudio2015";
checkFolderExists($folderToAnalyse) ? 1 : exit;

# find all the vcx project files from the folder (and its sub-folders) to analyse
say "\n\n\n******* VCXPROJS *******\n\n";
find( \&vcxProjWanted, $folderToAnalyse);
analyseFiles(\@contentVcxProj);

# find all the cs project files from the folder (and its sub-folders) to analyse
say "\n\n\n******* CSPROJS *******\n\n";
find( \&csProjWanted, $folderToAnalyse);
analyseFiles(\@contentCsProj);

exit;

sub analyseFiles {
    # expect two argument
    if (@_ != 1){
        say "Error on line: ".__LINE__;
        exit;
    }
    # input array argument passed by reference, de-reference it
    my @foundProjFiles = @{$_[0]};
    my @arrOfProjFilePaths;

    foreach my $found (@foundProjFiles) {
        # get filename, directory and extension of the found video
        ($name,$fileDir,$ext) = fileparse($found,'\..*');
        $fileDir =~ s/\//\\/g;
        $filePath="$fileDir";
        $fileName="$name$ext";
        chomp $filePath;
        chomp $fileName;
        $fullPathname = $filePath.$fileName;

        push(@arrOfProjFilePaths, $fullPathname);
    }

    foreach my $file (@arrOfProjFilePaths) {
        my @afile = read_file($file);
        foreach my $line (@afile){
            if ($line =~ /\<TargetFrameworkVersion\>v4.5.1/){
                #$line =~ s/\<TargetFrameworkVersion\>v4.6.1/\<TargetFrameworkVersion\>v4.5.1/g;
                say "$file:\n$line";
            }
        }
        write_file($file, @afile);
    }
}

sub vcxProjWanted {
    # expect zero arguments
    if (@_ != 0){
        say "Error on line: ".__LINE__;
        exit;
    }
    if ($File::Find::name =~ /\.vcxproj$/){
        push @contentVcxProj, $File::Find::name;
    }
    return;
}

sub csProjWanted {
    # expect zero arguments
    if (@_ != 0){
        say "Error on line: ".__LINE__;
        exit;
    }
    if ($File::Find::name =~ /\.csproj$/){
        push @contentCsProj, $File::Find::name;
    }
    return;
}

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
