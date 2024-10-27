#!/usr/bin/perl -w
#
## runs with Strawberry Perl: http://strawberryperl.com/
#
## need SSH key to have been set up on linux and BitBucket (see email: "bitbucket download whole repo"

use strict;
use warnings;
use feature qw(say);
use File::Find;
use File::Basename;
use Cwd;
use Net::Domain qw (hostname hostfqdn hostdomain);
use Data::Dumper qw(Dumper);

my @repoNames = getRepoNames();
print Dumper \@repoNames;
my $arrLength = @repoNames;
say "There are $arrLength repositories in this account\n";
cloneAllUnclonedRepos(\@repoNames);
#pullAllRepos(\@repoNames);
exit;

sub pullAllRepos {
    # expect one argument
    if (@_ != 1) {
        say "Error on line ".__LINE__;
        exit;
    }
    # input array passed by reference, de-reference it
    my @rNames= @{$_[0]};

    foreach my $element (@rNames) {
        if ( -d $element ) {
            say "pulling repo $element";
            chdir($element) or die "cannot change: $!\n";
            system("git pull");
            chdir("..") or die "cannot change: $!\n";
        }
        else {
            say "repository $element doesn't exist, cannot pull it!";
        }
    }
}

sub cloneAllUnclonedRepos {
    # expect one argument
    if (@_ != 1) {
        say "Error on line ".__LINE__;
        exit;
    }
    # input array passed by reference, de-reference it
    my @rNames= @{$_[0]};

    # clone each repostitory that hasn't been cloned yet
    my $counter = 1;
    foreach my $element (@rNames) {
        if ( ! -d $element ) {
            say "$counter: cloning repository $element";
            system("git clone ssh://git\@bitbucket.org/weebucket/$element.git");
        }
        else {
            say "$counter: repository $element exists already ... not cloning";
        }
        $counter++;
    }
}

sub getRepoNames {
    # expect one argument
    if (@_ != 0) {
        say "Error on line ".__LINE__;
        exit;
    }

    # access bitbucket api
    system("curl -u weebucket https://api.bitbucket.org/1.0/users/weebucket > repoAllInfo.txt");

    # read all contents of the file into a string
    open(FILE, 'repoAllInfo.txt') or die "Can't open file for reading [$!]\n";
    my $document = <FILE>;
    close (FILE);
    #print $document;

    # encase the name of each repository with "REPONAME"and newlines
    my $doc2 = $document;
    $doc2 =~ s/"name": "/\nREPONAME/g;
    $doc2 =~ s/", "language"/REPONAME\n/g;
    # put each repo name on a line by itself (encased in "REPONAME")
    my @arr1 = split /\n/, $doc2;

    # create an array with the name of all the repositories on my bitbucket
    my @rNames;
    foreach my $element (@arr1){
        if ($element =~ /REPONAME/) {
            $element =~ s/REPONAME//g;
            push @rNames, $element;
        }
    }
    #print Dumper \@refNames;
    return @rNames;
}
