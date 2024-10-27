:: Chop the input video on the command line to a much shorter test video
@echo off

set ARG1=%1
echo %ARG1%
set OUTFILE=%ARG1%_wee.asf
echo %OUTFILE%
ffmpeg -i %ARG1% -ss 00:00:05 -t 5 -b:v 4M %OUTFILE%
