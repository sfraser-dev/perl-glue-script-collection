#!/usr/bin/perl
use warnings;
use strict;
use feature qw(say);
use File::Path qw(make_path);
use File::Find;
use File::Basename;

our @content;

# target scss files
sub file_wanted {
    if ($File::Find::name =~ /\.scss$/){
        push @content, $File::Find::name;
    }
    return;
}

# find all scss files
find( \&file_wanted, '.');

# compile each sass file to css (normal and minified)
make_path("../css/");
foreach my $file_name (@content) {
    my ($name,$file_dir,$ext) = fileparse($file_name,'\..*');
    # ignore scss partials (filenames begin with underscore)
    if ($name =~ /^_/) {
        next;
    }
    my $input_name = $file_dir.$name.$ext;
    my $output_name = "../css/".$name.".css";
    qx(sass $input_name:$output_name --no-source-map);
    $output_name = "../css/".$name.".min.css";
    qx(sass $input_name:$output_name --no-source-map --style compressed);
}
