#!/usr/bin/perl
use warnings;
use strict;
use feature qw(say);
use File::Copy qw(move);

# run in top level of a web dev project
# installs sass, postcss and bootstrap in node_modules
#   installed bootstrap to have access to its source files for customization
#   installed sass and postcss so we can run them as scripts from package.json
#   postcss needs browserslist property set within package.json file
# adapts the package.json file so can run sass and postcss from cmd line via npm
# $> npm run compile:sass
# $> npm run compile:sassmin
# $> npm run compile:prefix
# perl file created to run these npm commands consecutively
# note: no npm for latest fontawesome version, so described manual install procedure

# rename json files
if (-e "package.json") {
    move "package.json", "package.json.prev";
}
if (-e "package-lock.json") {
    move "package-lock.json", "package-lock.json.prev";
}

# install npm-run-all (aka: run-s)
qx(npm i npm-run-all);

# initialize
qx(npm init -y);

# install sass
qx(npm i sass);

# install bootstrap
my $cmd = <<STR_END;
npm i bootstrap\@5.3.0
STR_END
system($cmd);

# fontawesome (no npm for version 6)
# manually downloaded "free for web" zip file from fontawesome
# now don't need to use the "cdn" kit
# important: must also copy the webfonts/ folder to project root directory
# see portfolio-justit-version2/sass/fontawesome.scss:
#@use "../fontawesome-free-6.4.0-web/scss/brands.scss";
#@use "../fontawesome-free-6.4.0-web/scss/regular.scss";
#@use "../fontawesome-free-6.4.0-web/scss/fontawesome.scss";
#@use "../fontawesome-free-6.4.0-web/scss/solid.scss";
# sass compile to ./css/fontawesome.css
# index.html: <link rel="stylesheet" href="./css/fontawesome.css">
# copy webfonts/ dir to the project root dir too

# install postcss and autoprefixer
qx(npm install postcss postcss-cli autoprefixer);

# change package.json
modify_package_json_scripts();
modify_package_json_browser();

# perl file to transpile all
my $str = <<STR_END;
#!/usr/bin/perl
use warnings;
use strict;
qx(npm run compile:sass);
qx(npm run compile:sassmin);
qx(npm run compile:prefix);
qx(npm run compile:prefixmin);
#qx(npm run build:all);
STR_END
my $file_name = "./transpile-everything.pl";
open(my $fh, ">", $file_name) or die ("Could not open '$file_name': $!");
say $fh $str;
close $fh;

sub modify_package_json_scripts {
	my $file_name = "package.json";
	my $line_contains = "\"test\":";
    my $temp1 = "    \"compile:sass\": \"sass ./sass:./css/ --no-source-map\",\n    ";
    my $line_new1 = $temp1."\"compile:sassmin\": \"sass ./sass:./css/min/ --no-source-map --style compressed\",";
    my $temp2 = "    \"compile:prefix\": \"postcss ./css/*.css --use autoprefixer --no-map -d ./css/prefixed/\",\n";
	my $temp3 = "    \"compile:prefixmin\": \"postcss ./css/min/*.css --use autoprefixer --no-map -d ./css/prefixedmin/\",\n";
    my $line_new2 = $temp2.$temp3."    \"build:all\": \"run-s compile:sass compile:sassmin compile:prefix compile:prefixmin\"";
	change_line($file_name, $line_contains, $line_new1, $line_new2);
}

sub modify_package_json_browser{
	my $file_name = "package.json";
	my $line_contains = "\"author\":";
	my $line_new1 = "  \"author\": \"\",";
    my $line_new2 = "  \"browserslist\": \"last 4 versions\",";
	change_line($file_name, $line_contains, $line_new1, $line_new2);
}

# Change a line in "file_name" containing "line_contains" to "line_new".
sub change_line {
	my $file_name = $_[0];
	my $line_contains = $_[1];
	my $line_new1 = $_[2];
	my $line_new2 = $_[3];

	my @new_file;
	my $re = qr/$line_contains/;
	open (my $fh, '<', $file_name) or die("Could not open '$file_name': $!");
	while(my $line = <$fh>) {
		if ($line =~ m/$line_contains/) {
			push(@new_file, $line_new1);
			push(@new_file, $line_new2);
		}
		else {
            chomp $line;
			push (@new_file, $line);
		}
	}
	close $fh;
	open ($fh, '>', $file_name) or die ("Could not open file '$file_name': $!");
	foreach my $line (@new_file) {
		say $fh $line;
	}
	close $fh;
	say "...modified $file_name";
}
