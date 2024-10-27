#!/usr/bin/perl -w
#
# Usage: perl changeVidDuration.pl --topdir /path/to/toplevel/dir
#
# This script runs with Strawberry Perl:
# http://strawberryperl.com/
#
# This script requires MediaInfo CLI (Command Line Interface):
# https://mediaarea.net/en/MediaInfo/Download/Windows
#
# This script needs FFmpeg & FFprobe installed in your system / directory.
# Static FFmpeg & FFprobes builds can be obtained from:
# https://ffmpeg.zeranoe.com/builds/
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
my @vidsFound;  # global array of found videos

# parse the command line arguments
my $topLevelDir = getCommandLineArgs();

# full pathname of all videos found stored in @vidsFound
find( \&findOriginalAsfVideos, '.');

my %dataDirDurations;
###******** calculating video durations in each dataset by parsing the folder names for the timestamps (ie: "DATA_xxxxxx", no use if there are gaps)
#%dataDirDurations = parseFolderName($topLevelDir);
###******** calculating video durations using the raw survey csv
%dataDirDurations = readRawSurvey(\@vidsFound);

# track changes made and new videos created by in a csv file
my $fout = "videoDurationData.csv";
open (my $fh_out, ">", $fout) || die "Couldn't open '".$fout."'for writing because: ".$!;
say $fh_out "Filename,Old Duration (secs),Old Framerate (fps),New Duration (secs),New Framerate (fps),Comment";

# process each video file found
foreach my $videoFile (@vidsFound) {
	# file path and name (relative to the directory that this perl script is in)
    my ($name, $dir, $ext, $dataDir);
    getFileAndDirInfoOfFoundVids(\$name,\$dir,\$ext,\$dataDir,\$videoFile);
    # directory that this perl script is in
	my $filePath = cwd();

    my $newExtension = "$newAppend"."$videoType";
    my $inputFileName = $filePath."/".$dataDir."/".$name.$ext;
    my $outputFileName = $filePath."/".$dataDir."/".$name.$newExtension;
    say "inputFileName = $inputFileName"; # DEBUG

    # only change durations of original video files (by "continuing" foreach loop if input video already has the new filename extension)
    next if ($inputFileName =~ /\Q$newAppend\E/);

	# Video duration (ms)
    my $durationV;
    $durationV = `mediainfo --Inform=Video;%Duration% $videoFile`;
    # sometimes, mediainfo doesn't return a value for the video duration, use FFprobe instead
    if ($durationV !~ /[0-9]/) {
        say "\n\nusing FFprobe to get video duration ...\n\n\n";
        $durationV = `ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 $videoFile`;
        $durationV *= 1000;
    }
	$durationV = sprintf "%.2f", $durationV;
	chomp $durationV;
    say "video duration = $durationV ms"; # DEBUG
	 
	# Video bitrate in bytes per second
	my $bitrate = `mediainfo --Output=Video;%BitRate% $videoFile`;
    chomp $bitrate;
	if (length($bitrate) >0) {
		$bitrate = $bitrate/1024/1024; # convert to Megabytes
		$bitrate = sprintf "%.2f", $bitrate;
	}
	 
	# Video frames per second
	my $framerate = `mediainfo --Output=Video;%FrameRate% $videoFile`;
    if ($framerate !~ /[0-9]/) {
        # sometimes, mediainfo doesn't return a value for the framerate, use FFprobe instead
        say  "\n\nusing FFprobe to get framesrate ...\n\n\n";
        $framerate = `ffprobe -v 0 -of compact=p=0 -select_streams 0 -show_entries stream=r_frame_rate $videoFile`;
        my @fratecomment = split /=/, $framerate;
        my @fraction = split /\//, $fratecomment[1];
        my $numerator = $fraction[0];
        my $denominator = $fraction[1];
        if ($numerator == 0 || $denominator == 0){
            $framerate = 0;
        }
        else {
            $framerate = $numerator / $denominator;
        }
    }
    # sometimes, FFprobe doesn't return a value for the framerate, read from the Properties.ini file instead
    if ($framerate !~ /[0-9]/ || $framerate == 0) {
        my $iniFile = $dir . "Properties.ini";
        open my $info, $iniFile or die "Could not open $iniFile: $!";
        while (my $line = <$info>) {
            if ($line =~ /\QVideoProfile=\E/){
                my @spl = split /\_/, $line;
                $framerate = $spl[3];;
                $framerate =~ s/fps//g;
            }
        }
        close $info;
    }
	chomp $framerate;
	$framerate = sprintf "%.2f", $framerate;

    # Number of video frames
	my $framecount = `mediainfo --Output=Video;%FrameCount% $videoFile`;
    $framecount = sprintf "%.2f", $framecount;
	chomp $framecount;
	
    # retrieve the duration of the videos in this dataset from the hash
    if (! exists $dataDirDurations{$dataDir}) {
        say "Cannot estimate the duration of videos in dataset $dataDir ... skipping (is this the final dataset)";
        my $currentVideoDurationSecs = $durationV / 1000;
        my $currentFpsRate = $framerate;
        my $str = sprintf ("$inputFileName,%.2f,%.2f,--,--,skipped (last dataset)",$currentVideoDurationSecs,$currentFpsRate);
        say $fh_out $str;
        next;
    }
    my $targetVideoDurationSecs;
    $targetVideoDurationSecs = $dataDirDurations{$dataDir};

    # recalculate new framerate
    my $currentVideoDurationSecs = $durationV / 1000;
    my $currentFpsRate = $framerate;
    my $denominator = $targetVideoDurationSecs / $currentVideoDurationSecs;
    my $targetFpsRate = $currentFpsRate / $denominator;
    my $currentBitrate = $bitrate."M";
    my $currentNumberOfFrames = $framecount;

    # write to CSV file
    my $str = sprintf ("$outputFileName,%.2f,%.2f,%.2f,%.2f",$currentVideoDurationSecs,$currentFpsRate,$targetVideoDurationSecs,$targetFpsRate);
    say $fh_out $str;

    # use FFmpeg to reencode video at new framerate to get the target duration
    system("ffmpeg -r $targetFpsRate -y -i $inputFileName -b:v $currentBitrate $outputFileName");
}

close $fh_out;
exit 0;

# subroutine to recursively find all required video files
sub findOriginalAsfVideos {
    # expect no arguments, uses globals
    if (@_ != 0){
        say "Error on line: ".__LINE__;
        exit 1;
    }

    if ($File::Find::name =~ /\Q$videoType\E$/){
        push @vidsFound, $File::Find::name;
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
sub getFileAndDirInfoOfFoundVids {
    # expect five arguments
    if (@_ != 5){
        say "Error on line: ".__LINE__;
        exit 1;
    }
    my $nameloc;
    my $dirloc;
    my $extloc;
    my $datadirloc;
    my $vfloc = $_[4];

    ($nameloc,$dirloc,$extloc) = fileparse($$vfloc,'\..*');
    # $dir will exist as ./DATA_2017xxxx/, ie: the dataset name starts at the 3rd character
    $datadirloc = substr $dirloc, 2;
    $datadirloc =~ s/\///g;
    $datadirloc =~ s/\\//g;
    ${$_[0]} = $nameloc;
    ${$_[1]} = $dirloc;
    ${$_[2]} = $extloc;
    ${$_[3]} = $datadirloc;
}

# subroutine to get the video durations in each dataset from the raw survey data csv
sub readRawSurvey {
    # expect one argument
    if (@_ != 1){
        say "Error on line: ".__LINE__;
        exit 1;
    }
    # input array argument passed by reference, de-reference it
    my @allVidsFound = @{$_[0]};

    my %dataDirDurations;
    foreach my $vf (@allVidsFound) {
        my ($nameloc, $dirloc, $extloc, $dataDirLoc);
        getFileAndDirInfoOfFoundVids(\$nameloc,\$dirloc,\$extloc,\$dataDirLoc,\$vf);

        if (! exists $dataDirDurations{$dataDirLoc}) {
            my $timestamp = substr $dataDirLoc, 5;
            my $rawSurveyFile = $dirloc . $timestamp . "\@original.csv";
            open (FOO, $rawSurveyFile) or die "Could not open $rawSurveyFile$!";
            my @wholefile = <FOO>;
            close FOO;
            my $lastline = pop(@wholefile);
            my @splLastLine = split /,/, $lastline;
            my @timeColon = split /:/, $splLastLine[0];
            my $rsd_hh = $timeColon[0];
            my $rsd_mm = $timeColon[1];
            my $rsd_ss = $timeColon[2];
            my $totalSecs = ($rsd_hh * 60 * 60) + ($rsd_mm * 60) + $rsd_ss;
            $dataDirDurations{$dataDirLoc} = $totalSecs;
        }
    }
    #print Dumper(\%dataDirDurations); # DEBUG
    return %dataDirDurations;
}

# wrapper subroutine for getting the video durations by parsing successive dataset folder names
sub parseFolderName {
    # expect one arguments
    if (@_ != 1){
        say "Error on line: ".__LINE__;
        exit 1;
    }
    my $toplevdir = $_[0];
    my @dataDirs = parseFolder_findAllDatasetsDATA_($toplevdir);
    my @dataDirsFormatted = parseFolder_formatAllDatasets(\@dataDirs);
    my %dataDirDurations = parseFolder_getDataDirsDurations(\@dataDirsFormatted);
    return %dataDirDurations;
}

# subroutine to find all the "DATA_xxxxx" folders / datasets
sub parseFolder_findAllDatasetsDATA_{
    # expect one argument
    if (@_ != 1) {
        say "Error on line: ".__LINE__;
        exit 1;
    }
    my $topLevelDir = $_[0];

    my @subDirs = grep { -d } map { catfile $topLevelDir, $_ } read_dir $topLevelDir;
    my @dataDirs;
    # keep a list of just the DATA_2017xxxx directories
    foreach (@subDirs) {
        if ($_ =~ /\QDATA_\E/) {
            push(@dataDirs, $_);
        }
    }
    @dataDirs = sort(@dataDirs); # sorts according to ASCII table
    return @dataDirs;
}

# subroutine to get the timestamp information from each DATA_2017xxxxx DIR; store results in a formatted array
sub parseFolder_formatAllDatasets {
    # expect one argument
    if (@_ != 1) {
        say "Error on line: ".__LINE__;
        exit 1;
    }
    # input array argument passed by reference, de-reference it
    my @dataDirArr = @{$_[0]};

    my @dataDirsFormatted;
    foreach (@dataDirArr) {
        my @split = split /\QDATA_\E/, $_, 2;
        my $timestamp = $split[1];
        my $year    = substr $timestamp, 0, 4;
        my $month   = substr $timestamp, 4, 2;
        my $day     = substr $timestamp, 6, 2;
        my $hour    = substr $timestamp, 8, 2;
        my $min     = substr $timestamp, 10, 2;
        my $sec     = substr $timestamp, 12, 2;
        my $ms      = substr $timestamp, 14, 3;
        push(@dataDirsFormatted, "$split[0]DATA_$timestamp::$year::$month::$day::$hour::$min::$sec::$ms");
    }
    return @dataDirsFormatted;
}

# subroutine to return the durations of the videos in each dataset as a hash (eg: DATA_xxxx0 => 31 mins; DATA_xxxx1 => 29 mins)
sub parseFolder_getDataDirsDurations {
    # expect one argument
    if (@_ != 1){
        say "Error on line: ".__LINE__;
        exit 1;
    }
    my @dataDirsFormatted = @{$_[0]};

    # calculate the time taken for each dataset based on the timestamps of consecutive datasets; store results in a hash
    my $numberDataDirs = scalar @dataDirsFormatted;
    my $splLen;
    my %dataDirDurations;
    for (my $i=0; $i<($numberDataDirs-1); $i++){
        my $strCur = $dataDirsFormatted[$i];
        my $strNxt = $dataDirsFormatted[$i+1];
        my @splCur = split/\Q::\E/, $strCur;
        my @splNxt = split/\Q::\E/, $strNxt;
        my $splLenCur = scalar @splCur;
        my $splLenNxt = scalar @splNxt;
        if ($splLenCur != $splLenNxt) {
            say "Error in lengths of formatted data directories ... exiting";
            exit 1;
        }
        else {
            $splLen = $splLenCur;
        }
        my $dataSetNameCur = substr $splCur[0], -22;
        my $dataSetNameNxt = substr $splNxt[0], -22;
        my $msCur       = $splCur[$splLen-1];
        my $secCur      = $splCur[$splLen-2];
        my $minCur      = $splCur[$splLen-3];
        my $hourCur     = $splCur[$splLen-4];
        my $dayCur      = $splCur[$splLen-5];
        my $monthCur    = $splCur[$splLen-6];
        my $yearCur     = $splCur[$splLen-7];
        my $msNxt       = $splNxt[$splLen-1];
        my $secNxt      = $splNxt[$splLen-2];
        my $minNxt      = $splNxt[$splLen-3];
        my $hourNxt     = $splNxt[$splLen-4];
        my $dayNxt      = $splNxt[$splLen-5];
        my $monthNxt    = $splNxt[$splLen-6];
        my $yearNxt     = $splNxt[$splLen-7];
        # find the number of seconds since the epoch (using Time::Local)
        my $cur_epochSecs = timegm($secCur,$minCur,$hourCur,$dayCur,$monthCur-1,$yearCur);
        my $nxt_epochSecs = timegm($secNxt,$minNxt,$hourNxt,$dayNxt,$monthNxt-1,$yearNxt);
        # add in the milliseconds
        $cur_epochSecs = $cur_epochSecs . "." . $msCur;
        $nxt_epochSecs = $nxt_epochSecs . "." . $msNxt;
        # calculate the time taken (secs) for each dataset (based on the timestamps)
        my $curNxtTimeDiffSecs = $nxt_epochSecs - $cur_epochSecs;
        # store the DATA_2017xxxx name and the duration of its videos as a hash
        $dataDirDurations{$dataSetNameCur} = $curNxtTimeDiffSecs;
    }
    # print Dumper(\%dataDirDurations); # DEBUG
    return %dataDirDurations;
}
