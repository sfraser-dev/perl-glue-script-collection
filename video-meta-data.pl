#!/usr/bin/perl -w
use strict;
use warnings;
use feature qw(say);
use File::Find;
use File::Basename;
use Cwd;
use Net::Domain qw (hostname hostfqdn hostdomain);

my $name;
my $dir;
my $ext;
my $filePath;
my $fileDataset;
my $fileSubProject;
my $filePathName;
my @content;
my $fout;
my $fh_out;
my @diskarray;
my $disk;
my $vwprojectspath;
my $hostname = `hostname`;
my $durationF = "";		        # File duration
my $durationV = "";		        # Video duration
my $durationA = "";		        # Audio duration
my $formatFile = "";		    # File container: MPEG-PS, MPEG-TS, MPEG-4 or Windows Media
my $formatVid = "";		        # Video format: MPEG Video, AVC, WVP2 or VC-1
my $formatVidVer = "";		    # Video format version: Version 2 for MPEG-2, else blank
my $formatA = "";		        # Audio format: MPEG Audio, AAC LC, or WMA2
my $formatAP = "";		        # Audio format profile: [MPEG] Layer 2, LC, L1 or L2
my $streamSizeV;		        # Video size, absolute and as proportion of file size
my $streamSizeA;		        # Audio size, absolute and as proportion of file size
my $bitrate = "";		        # Video bitrate in bytes per second
my $framerate = "";		        # Video frames per second
my $framecount= "";		        # Number of video frames
my $width = "";			        # Video resolution - width
my $height = "";		        # Video resolution - height
my $aspect = "";		        # Video resolution - aspect ratio
my $scantype = "";		        # Progressive or Interlaced
my $volumeMean = "";            # Find the mean volume
my $volumeMax = "";             # Find the maximum volume
my $fileCreatedDate = "";	    # The time the file was created in the file system

# Create a file using the hostname of the PC
chomp $hostname;
$fout = "VideoMetaData_$hostname.csv";
open ($fh_out, ">", $fout) || die "Couldn't open '".$fout."'for writing because: ".$!;

# Write a file header
say $fh_out "Project path,Filename,File Duration,Video Duration,Audio Duration,File Format,Video Format,Audio Format,Video Stream Size,Audio Stream Size,Video Bit Rate,Width x Height,Aspect Ratio,Frame Rate,Frame Count,Scan Type,Mean Volume (dB),Max Volume (dB),File Created Date";

# Get a list of all videos. This takes time so tell the user
say "Building a list of video files.  This may take a few minutes...";
find( \&vsVideo, '.');

# Get the metadata of each video file in the list of found files
foreach my $videoFile (@content) {
	# file path and name
	($name,$dir,$ext) = fileparse($videoFile,'\..*');
	$filePath = cwd();
	$fileSubProject = substr $dir, 2;
	$fileDataset = "$fileSubProject";
	$filePathName = "$fileDataset$name$ext";
	$durationF = ""; 	        # File duration
	$durationV = "";	        # Video duration
	$durationA = "";	        # Audio duration
	$formatFile = "";	        # File container: MPEG-PS, MPEG-TS, MPEG-4 or Windows Media
	$formatVid = "";	        # Video format: MPEG Video, AVC, WVP2 or VC-1
	$formatVidVer = "";	        # Video format version: Version 2 for MPEG-2, else blank
	$formatA = "";		        # Audio format: MPEG Audio, AAC LC, or WMA2
	$formatAP = "";		        # Audio format profile: [MPEG] Layer 2, LC, L1 or L2
	$streamSizeV = "";	        # Video size, absolute and as proportion of file size
	$streamSizeA = "";	        # Audio size, absolute and as proportion of file size
	$bitrate = "";		        # Video bitrate in bytes per second
	$framerate = "";	        # Video frames per second
	$framecount= "";	        # Number of video frames
	$width = "";		        # Video resolution - width
	$height = "";		        # Video resolution - height
	$aspect = "";		        # Video resolution - aspect ratio
	$scantype = "";		        # Progressive or Interlaced
    $fileCreatedDate = "";	    # The time the file was created in the file system
	
	#say "Examining $videoFile";

	#Get meta data using MediaInfoCLI
	#
	# File duration
	$durationF = `mediainfo --Output=General;%Duration/String3% $videoFile`;
	chomp $durationF;
	#
	# Video duration
	$durationV = `mediainfo --Output=Video;%Duration/String3% $videoFile`;
	chomp $durationV;
	#
	# Audio duration
	$durationA = `mediainfo --Output=Audio;%Duration/String3% $videoFile`;
	chomp $durationA;
	#
    # Mean and maximum volumes
    my $tempVolFile =  "tempVolInfo.txt";
    system(`ffmpeg -i $videoFile -af volumedetect -f null > $tempVolFile 2>&1 \/dev\/null`);
    open my $volHandle, '<', $tempVolFile;
    chomp(my @volumeinfo = <$volHandle>);
    foreach my $volumeinfoLine (@volumeinfo){
        if ( ($volumeinfoLine =~ m/Parsed_volumedetect/) && ($volumeinfoLine =~ m/mean_volume/) ){
            my @volSplit = split(/mean_volume: /, $volumeinfoLine);
            my $volume_dB = $volSplit[1];
            my @dbSplit = split(/ dB/, $volume_dB);
            $volumeMean = $dbSplit[0];
        }
        if ( ($volumeinfoLine =~ m/Parsed_volumedetect/) && ($volumeinfoLine =~ m/max_volume/) ){
            my @volSplit = split(/max_volume: /, $volumeinfoLine);
            my $volume_dB = $volSplit[1];
            my @dbSplit = split(/ dB/, $volume_dB);
            $volumeMax = $dbSplit[0];
        }
    }
    chomp $volumeMean;
    chomp $volumeMax;
    close $volHandle;
    system("del /F $tempVolFile");
    #
	# File container: MPEG-PS, MPEG-TS, MPEG-4 or Windows Media
	$formatFile = `mediainfo --Output=General;%Format% $videoFile`;
	chomp $formatFile;
	#
	# Video format: MPEG Video, MPEG-4 Visual, AVC, WVP2 or VC-1
	$formatVid = `mediainfo --Output=Video;%Format% $videoFile`;
	chomp $formatVid;
	#
	# Video format version: Version 2 for MPEG-2, else blank
	$formatVidVer = `mediainfo --Output=Video;%Format_Version% $videoFile`;
	chomp $formatVidVer;
	#
	# Audio format: MPEG Audio, AAC LC, or WMA2
	$formatA = `mediainfo --Output=Audio;%Format% $videoFile`;
	chomp $formatA;
	#
	# Audio format profile: [MPEG] Layer 2, LC, L1 or L2
	$formatAP = `mediainfo --Output=Audio;%Format_Profile% $videoFile`;
	chomp $formatAP;
	#
	# Video size, absolute and as proportion of file size
	$streamSizeV = `mediainfo --Output=Video;%StreamSize/String% $videoFile`;
	chomp $streamSizeV;
	#
	# Audio size absolute and as proportion of file size
	$streamSizeA = `mediainfo --Output=Audio;%StreamSize/String% $videoFile`;
	chomp $streamSizeA;
	#
	# Video bitrate in bytes per second
	$bitrate = `mediainfo --Output=Video;%BitRate% $videoFile`;
	if (length($bitrate) >0) {
		$bitrate = $bitrate/1024/1024; # convert to Megabytes
		$bitrate = sprintf "%.1f", $bitrate;
	}
	#
	# Video resolution - width
	$width = `mediainfo --Output=Video;%Width% $videoFile`;
	chomp $width;
	#
	# Video resolution - height
	$height = `mediainfo --Output=Video;%Height% $videoFile`;
	chomp $height;
	#
	# Video resolution - aspect ratio
	$aspect = `mediainfo --Output=Video;%DisplayAspectRatio/String% $videoFile`;
	chomp $aspect;
	#
	# Video frames per second
	$framerate = `mediainfo --Output=Video;%FrameRate% $videoFile`;
	chomp $framerate;
	if (length($framerate) >0) {
		$framerate = sprintf "%.2f", $framerate;
	}
	#
	# Number of video frames
	$framecount = `mediainfo --Output=Video;%FrameCount% $videoFile`;
	chomp $framecount;
	#
	# Progressive or Interlaced
	$scantype = `mediainfo --Output=Video;%ScanType% $videoFile`;
	chomp $scantype;
    #
	# File created date
	$fileCreatedDate = `mediainfo --Output=General;%File_Created_Date% $videoFile`;
	chomp $fileCreatedDate;
	#
	#
	$videoFile = substr $videoFile, 1;
    #
	say $fh_out "$filePath/$fileDataset,$name$ext,$durationF,$durationV,$durationA,$formatFile,$formatVid $formatVidVer,$formatA $formatAP,$streamSizeV,$streamSizeA,$bitrate,$width x $height,$aspect,$framerate,$framecount,$scantype,$volumeMean,$volumeMax,$fileCreatedDate";
	say "$filePath/$fileDataset$name$ext";
}

close $fh_out;
close $fout;
exit;

# subroutine to recursively find all files with VisualSoft video extensions
sub vsVideo {
    if ($File::Find::name =~ /\.(asf|wmv|off|arc|blk|mpg|mpv|mof|mar|mbk|mp4|m4v|m4o|m4a|m4b)$/){
        push @content, $File::Find::name;
    }
    return;
}
