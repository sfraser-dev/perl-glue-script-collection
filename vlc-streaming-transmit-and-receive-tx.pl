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
system("Taskkill /IM vlc.exe /F \> nul 2\>\&1");

my $source1= "TheSimpsonsMovieTrailer.mp4";

# ORIGINAL
#system("vlc -vvv $source1 --file-caching=1500 --sout=\"#duplicate{dst=rtp{sdp=rtsp://:8554/stream},dst=display}\" --sout-keep --sout-all");

# LOOPS ON REPEAT
#system("vlc -vvv $source1 --file-caching=1500 --sout=\"#duplicate{dst=rtp{sdp=rtsp://:8554/stream},dst=display}\" --sout-keep");

# LOOPS ON REPEAT and doesn't show display while transmitting (but shows a GUI with an empty display)
#system("vlc -vvv $source1 --file-caching=1500 --sout=\"#rtp{sdp=rtsp://:8554/stream}\" --sout-keep");

# LOOPS ON REPEAT and doesn't show display while transmitting (but pops up a console)
#system("vlc --intf dummy $source1 --file-caching=1500 --sout=\"#rtp{sdp=rtsp://:8554/stream}\" --sout-keep");

# LOOPS ON REPEAT (no GUI and no console)
#system("vlc --intf dummy --dummy-quiet $source1 --file-caching=1500 --sout=\"#rtp{sdp=rtsp://:8554/stream}\" --sout-keep");



#-----------------------------------------------------------------------------
# Cannot do even the simpliest of tramsit and receive on laptop (from file or it's webcam, FET domain issue?)
#-----------------------------------------------------------------------------


#-----------------------------------------------------------------------------
# Overlay / Timecodes

my $source2="sifTest.wmv"; # simpsons is a larger HD video, use smaller one
#system("vlc --intf dummy --dummy-quiet $source2 --sub-source=\"marq{marqueee=%Y%m%d %H%M%S,color=16776960,position=5}\" --sout=\"#rtp{sdp=rtsp://:8554/stream}\" --sout-keep");
#system("vlc $source2 --sub-filter=marq --marq-marquee=\"%Y-%m-%d %H%M%S\" --marq-color=32768 --marq-position=2 --marq-size=25 --sout=\"#transcode{vcodec=mp4v,acodec=mpga,vb=2500000,ab=128,deinterlace,sfilter=marq}:#duplicate{dst=display,dst=rtp{sdp=rtsp://:8554/stream}}\" --sout-keep");
#system("vlc $source2 --sub-filter=marq --marq-marquee=\"%Y-%m-%d %H%M%S\" --marq-color=32768 --marq-position=2 --marq-size=25 --sout=\"#transcode{vcodec=mp4v,acodec=mpga,vb=2500000,ab=128,deinterlace,sfilter=marq}:#duplicate{dst=display,dst=rtp{sdp=rtsp://:8554/stream}\" --sout-keep");

#system("vlc -vvv $source2 --sout=\"#transcode{vcodec=mp4v,acodec=mpga,vb=2500000,ab=128,deinterlace}:duplicate{dst=display,dst=rtp{sdp=rtsp://:8554/stream}}\" --sout-keep");
#system("vlc --intf dummy --dummy-quiet $source2 --sub-filter=marq --marq-marquee=\"%Y-%m-%d %H%M%S\" --marq-color=16776960 --marq-position=1 --marq-size=25 --sout=\"#transcode{vcodec=mp4v,acodec=mpga,vb=2500000,ab=128,deinterlace,sfilter=marq}:rtp{sdp=rtsp://:8554/stream}\" --sout-keep");

#-----------------------------------------------------------------------------
# USB webcam (can also point webcam at clock for timestamps)

#my $source3 = "dshow\:\/\/ \:dshow-vdev= \:dshow-adev=  \:live-caching=300";
#my $source3 = "dshow\:\/\/ \:dshow-vdev=\"Microsoft LifeCam VX-800\" \:dshow-adev=  \:live-caching=300";
#my $source3 = "dshow:\/\/ --dshow-vdev=\"Microsoft LifeCam VX-800\" --dshow-adev=None --dshow-adev=None --dshow-size=160x120 --dshow-fps=30 --live-caching=300";

my $source3 = "dshow\:\/\/ \:dshow-vdev=\"Microsoft LifeCam VX-800\" \:dshow-adev=\"Microphone (Microsoft LifeCam V\" --dshow-size=640x480 --dshow-fps=30 --live-caching=300";
#system("vlc $source3 --sout=\"#duplicate{dst=display,dst=rtp{sdp=rtsp://:8554/stream}}\"");

# GUI (not working too great here either)
# cannot display locally correctly (forzen)
# MRL----- dshow://
# Options----- :dshow-vdev=Microsoft LifeCam VX-800 :dshow-adev=Microphone (Microsoft LifeCam V :dshow-size=320x240 :live-caching=300
#
##
#Capture device
#  dshow://
# :dshow-vdev=Microsoft LifeCam VX-800 :dshow-adev=Microphone (Microsoft LifeCam V :dshow-size=640x480 :live-caching=300
###
#Tx ...  :sout=#transcode{vcodec=h264,acodec=mpga,ab=128,channels=2,samplerate=44100}:rtp{sdp=rtsp://:8554/stream} :sout-keep
#Rx ...  MRL.. rtsp://@:8554/yy  Options..  :network-caching=500
### Takes a few seconds for receiver to come "alive" and wait for an I frame (clean picture)
#system("vlc $source3 --sout=\"#transcode{vcodec=h264,acodec=mpga,ab=128,channels=2,samplerate=44100}:rtp{sdp=rtsp://:8554/stream}\" --sout-keep");
#
# Vorbis for no delay at receiver
system("vlc --intf dummy --dummy-quiet $source3 --sub-filter=marq --marq-marquee=\"%Y-%m-%d %H%M%S\" --marq-color=16776960 --marq-position=1 --marq-size=18  --sout=\"#transcode{vcodec=VP80,vb=2000,acodec=vorb,ab=128,channels=2,samplerate=44100,sfilter=marq}:rtp{sdp=rtsp://:8554/stream}\" --sout-keep");
