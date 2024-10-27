#!/usr/bin/perl
use warnings;
use strict;
use feature qw(say);
use File::Path qw(make_path);

# Rewrite with proper indentation.
sub modify_tailwind_config_js_and_fix_formatting {
    my $file_name = "tailwind.config.js";

    my @new_file;
	my $str = <<STR_END;
/** \@type {import('tailwindcss').Config} */

module.exports = {

    content: ["./**/*.{html,js}"],
    theme: {

        extend: {},

    },

    plugins: [],

};
STR_END
 
    open (my $fh, '>', $file_name) or die ("Could not open file '$file_name': $!");
	say $fh $str;
	close $fh;
    say "...modified $file_name and fixed formatting";
}

# Add content property.
sub modify_tailwind_config_js {
	my $file_name = "tailwind.config.js";
	my $line_contains = "content";
	my $line_new = "content: [\"./**/*.{html,js}\"],";

	change_line($file_name, $line_contains, $line_new);
}

# Create build-css script.
sub modify_package_json {
	my $file_name = "package.json";
	my $line_contains = "\"test\":";
	my $line_new = "    \"build-css\": \"npx tailwindcss -i ./tailwind/tailwind.css -o ./css/style.css --watch\"";

	change_line($file_name, $line_contains, $line_new);
}

# Change a line in "file_name" containing "line_contains" to "line_new".
sub change_line {
	my $file_name = $_[0];
	my $line_contains = $_[1];
	my $line_new = $_[2];

	my @new_file;
	my $re = qr/$line_contains/;
	open (my $fh, '<', $file_name) or die("Could not open '$file_name': $!");
	while(my $line = <$fh>) {
		if ($line =~ m/$line_contains/) {
			push(@new_file, $line_new);
		}
		else {
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

# Populate index.html with boilerplate code and a simple Tailwind class.
sub populate_with_boilerplate {
	my $file_name = $_[0];
	
	my $str = <<STR_END;
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta http-equiv="X-UA-Compatible" content="IE=edge">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<link rel="stylesheet" href="./css/style.css">
<title>Document</title>
</head>
<body>
    <h1 class="bg-green-500">tailwind test</h1>
</body>
</html>
STR_END

	open (my $fh, '>', $file_name) or die("Could not open '$file_name': $!");
	say $fh $str;
	close $fh;
	say "...boilerplate added to $file_name";
}

# Adding Tailwind functionality.
sub populate_with_tailwind_directives{
	my $file_name = $_[0];

	my @arr;
	push(@arr, "\@tailwind base;");
	push(@arr, "\@tailwind components;");
	push(@arr, "\@tailwind utilities;");

	open (my $fh, '>', $file_name) or die("Could not open '$file_name': $!");
	foreach my $line (@arr) {
		say $fh $line;
	}
	close $fh;
	say "...tailwind directives added to $file_name";
}

sub populate_with_npm_command {
	my $file_name = $_[0];

	open (my $fh, '>', $file_name) or die("Could not open '$file_name': $!");
    say $fh "#!/usr/bin/perl";
    say $fh "use warnings;";
    say $fh "use strict;\n";
	say $fh "qx(npm run build-css);";
	close $fh;
    say "...npm command added to $file_name";
}

#----- Main -----#
make_path("./css");
make_path("./tailwind");

populate_with_boilerplate("./index.html");
populate_with_tailwind_directives("./tailwind/tailwind.css");
populate_with_npm_command("./watcher-restart.pl");

# Run npm init (creates package.json).
qx(npm init -y);
# Install Tailwind as a development dependency (creates node_modules/).
qx(npm install -D tailwindcss);
# Initialise Tailwind (creates tailwind.config.js).
qx(npx tailwindcss init);

# Give content property in tailwind.config.js an array of files to process.
modify_tailwind_config_js_and_fix_formatting();
# Modify package.json to run a build-css script.
modify_package_json();


# Build the tailwind.css style sheet.
qx(npx tailwindcss -i ./tailwind/tailwind.css -o ./css/style.css --watch);
