Computers were named wrong (had ampersands (@) in their names). This was creating a probelm as filenames in datasets also had ampersands. This perl file changes filenames in our dataset; @ is replaced with AT. The perl file also changes the lines in Properties.ini that have @ to AT (so they point to the new dataset file names).

