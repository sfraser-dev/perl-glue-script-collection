use warnings;
use strict;
use feature qw /say/;
use Cwd;

# compile to get .o object files
`clang++ -c test.cpp test-joe.cpp`;
# link files to produce .exe
`clang++ test.o test-joe.o -o test-exe-file.exe`;
# get the full path name of the executable
my $cwd = getcwd;
my $exe = $cwd."/test-exe-file.exe";
# run exe. store program output in variable (hidden by default when run from perl file) 
my $output = `$exe`;
# print exe output to screen
say $output;
