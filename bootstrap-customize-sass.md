# Customise Bootstrap by Compiling its Sass Source Code

This script sets up an environment to easily create customised versions of bootstrap
by compiling its sass source code.

- USAGE:
  - copy bs_setup.pl and bs_setup.html to the project top dir (same dir as index.html)
  - run bs_setup.pl
  - will install bootstrap source files into ./node_modules/
  - will create a customize.scss for us in ./assets/css
  - will use customize.scss to compile customized bootstrap files (in ./assets/css)
  - will open chrome with an html file using new customized bootstrap files (a test)
  - will create a new perl file in ./assets/css for more compilations (if needed)

