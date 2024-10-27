#!/usr/bin/perl -w

# runs with Strawberry Perl: http://strawberryperl.com/

# Copy and paste the SquadNotes sheet "date, GBP and comments" to a new spreadsheet "sheet.ods"
# Save "sheet.ods" as a CSV file with the following options
# file -> save as -> csv -> "sheet.txt" (edit filter settings, text csv format, ...
# ... character set Western Europe, field delimiter :, Text delimiter ", ...
# ... save cell contents as shown, quote all text cells)
#
# Only have to convert "sheet.ods" to "sheet.txt" once, can then work with "sheet.txt"
# in LibreCalc directly after that.

use strict;
use warnings;
use feature qw(say);
use File::Find; 
use File::Basename;
use Cwd;
use POSIX qw(floor);
use File::Slurp;
use utf8; # need to be able to handle the UK "£" symbol

my @contentFile;
my $name;
my $fileDir;
my $ext;
my $filePath;
my $fileName;
my $folderToAnalyse;
my $fullPathname;
my @splitter;
my $poundSign = chr(156);
my $formattedFile;

$folderToAnalyse = "F:\\dev\\abosSpreadsheet";
checkFolderExists($folderToAnalyse) ? 1 : exit;

# find "sheet.txt" from the folder (and its sub-folders) to analyse
find( \&fileWanted, $folderToAnalyse); 
analyseFiles(\@contentFile);

exit;

sub analyseFiles {
    # expect one argument
    if (@_ != 1){
        say "Error on line: ".__LINE__;
        exit;
    }
    # input array argument passed by reference, de-reference it
    my @foundProjFiles = @{$_[0]};
    my @arrOfProjFilePaths;

    foreach my $found (@foundProjFiles) {
        # get filename, directory and extension of the found video
        ($name,$fileDir,$ext) = fileparse($found,'\..*');
        $fileDir =~ s/\//\\/g;
        $filePath="$fileDir";
        $fileName="$name$ext";
        chomp $filePath;
        chomp $fileName;
        $fullPathname = $filePath.$fileName;

        push(@arrOfProjFilePaths, $fullPathname);
    }

    foreach my $file (@arrOfProjFilePaths) {
        my @afile = read_file($file);
        my $lineCountTotal = 0;
        my @payments;
        my @paymentsCash;
        my @paymentsDate;
        my $paymentsLines = 0;
        my @miscSpends;
        my @miscSpendsCash;
        my @miscSpendsDate;
        my $miscSpendsLines = 0;
        my @miscReceives;
        my @miscReceivesCash;
        my @miscReceivesDate;
        my $miscReceivesLines = 0;
        my @referees;
        my @refereesCash;
        my @refereesDate;
        my $refereesLines = 0;
        my @pitches;
        my @pitchesCash;
        my @pitchesDate;
        my $pitchesLines = 0;
        my @refunds;
        my @refundsCash;
        my @refundsDate;
        my $refundsLines = 0;
        my @fundraisings;
        my @fundraisingsCash;
        my @fundraisingsDate;
        my $fundraisingsLines = 0;
        my @facilities;
        my @facilitiesCash;
        my @facilitiesDate;
        my $facilitiesLines = 0;
        my @fines;
        my @finesCash;
        my @finesDate;
        my $finesLines = 0;
        foreach my $line (@afile){
            # ignore lines that are just whitespace
            ($line =~ /^\s*$/) ? next : 1;

            # count lines to make sure all rows in spreadsheet are read
            $lineCountTotal++;

            # payments 
            if ($line =~ /\"Abo payment/) {
                # split at ":"
                my @cols = split /:/, $line;
                push @payments, $cols[2];
                push @paymentsCash, $cols[1];
                push @paymentsDate, $cols[0];
                $paymentsLines++;
            }

            # miscelleneous spend
            if ($line =~ /\"Miscellaneous spend/) {
                # split at ":"
                my @cols = split /:/, $line;
                push @miscSpends, $cols[2];
                push @miscSpendsCash, $cols[1];
                push @miscSpendsDate, $cols[0];
                $miscSpendsLines++;
            }

            # miscelleneous received
            if ($line =~ /\"Miscellaneous received/) {
                # split at ":"
                my @cols = split /:/, $line;
                push @miscReceives, $cols[2];
                push @miscReceivesCash, $cols[1];
                push @miscReceivesDate, $cols[0];
                $miscReceivesLines++;
            }

            # referees
            if ($line =~ /\"Referee /) {
                # split at ":"
                my @cols = split /:/, $line;
                push @referees, $cols[2];
                push @refereesCash, $cols[1];
                push @refereesDate, $cols[0];
                $refereesLines++;
            }

            # pitches
            if ($line =~ /\"Pitch /) {
                # split at ":"
                my @cols = split /:/, $line;
                push @pitches, $cols[2];
                push @pitchesCash, $cols[1];
                push @pitchesDate, $cols[0];
                $pitchesLines++;
            }

            # refunds
            if ($line =~ /\"Refund /) {
                # split at ":"
                my @cols = split /:/, $line;
                push @refunds, $cols[2];
                push @refundsCash, $cols[1];
                push @refundsDate, $cols[0];
                $refundsLines++;
            }

            # fundraising
            if ($line =~ /\"Fundraising /) {
                # split at ":"
                my @cols = split /:/, $line;
                push @fundraisings, $cols[2];
                push @fundraisingsCash, $cols[1];
                push @fundraisingsDate, $cols[0];
                $fundraisingsLines++;
            }

            # facilities
            if ($line =~ /\"Facility /) {
                # split at ":"
                my @cols = split /:/, $line;
                push @facilities, $cols[2];
                push @facilitiesCash, $cols[1];
                push @facilitiesDate, $cols[0];
                $facilitiesLines++;
            }

            # fines
            if ($line =~ /\"Fine /) {
                # split at ":"
                my @cols = split /:/, $line;
                push @fines, $cols[2];
                push @finesCash, $cols[1];
                push @finesDate, $cols[0];
                $finesLines++;
            }
        }

        my $paymentsSum = 0;
        my $miscSpendsSum = 0;
        my $miscReceivesSum = 0;
        my $refereesSum = 0;
        my $pitchesSum = 0;
        my $refundsSum = 0;
        my $fundraisingsSum = 0;
        my $facilitiesSum = 0;
        my $finesSum = 0;

        # remove the filename extension and rename
        ($formattedFile = $file) =~ s/\.[^.]+$//;
        $formattedFile= $formattedFile."Formatted.txt";
        # write formatted information to file
        open(my $fh, '>', $formattedFile) or die "Could not open file '$formattedFile' $!";


        printf $fh "\n";
        printf $fh "********** Category: Abo Payments **********\n";
        for(my $i=0; $i<scalar(@payments); $i++){
            $paymentsSum += $paymentsCash[$i];
            chomp $payments[$i];
            printf $fh ("Line %-5d %-10d %-10.2f %s\n", $i+1, $paymentsDate[$i], $paymentsCash[$i], $payments[$i]);
        }
        printf $fh "Should be $paymentsLines separate Abo payments\n";
        printf $fh "Total payments from Abos = £$paymentsSum\n";

        printf $fh "\n";
        printf $fh "\n";
        printf $fh "********** Category: Miscellaneous Spends **********\n";
        for(my $i=0; $i<scalar(@miscSpends); $i++){
            $miscSpendsSum += $miscSpendsCash[$i];
            chomp $miscSpends[$i];
            printf $fh ("Line %-5d %-10d %-10.2f %s\n", $i+1, $miscSpendsDate[$i], $miscSpendsCash[$i], $miscSpends[$i]);
        }
        printf $fh "Should be $miscSpendsLines separate miscellaneous spends\n";
        printf $fh "Total miscelleneous spends = £$miscSpendsSum\n";

        printf $fh "\n";
        printf $fh "\n";
        printf $fh "********** Category: Miscellaneous Received **********\n";
        for(my $i=0; $i<scalar(@miscReceives); $i++){
            $miscReceivesSum += $miscReceivesCash[$i];
            chomp $miscReceives[$i];
            printf $fh ("Line %-5d %-10d %-10.2f %s\n", $i+1, $miscReceivesDate[$i], $miscReceivesCash[$i], $miscReceives[$i]);
        }
        printf $fh "Should be $miscReceivesLines separate miscellaneous receives\n";
        printf $fh "Total miscelleneous received = £$miscReceivesSum\n";

        printf $fh "\n";
        printf $fh "\n";
        printf $fh "********** Category: Referee Costs **********\n";
        for(my $i=0; $i<scalar(@referees); $i++){
            $refereesSum += $refereesCash[$i];
            chomp $referees[$i];
            printf $fh ("Line %-5d %-10d %-10.2f %s\n", $i+1, $refereesDate[$i], $refereesCash[$i], $referees[$i]);
        }
        printf $fh "Should be $refereesLines separate referee payments\n";
        printf $fh "Total referee costs = £$refereesSum\n";

        printf $fh "\n";
        printf $fh "\n";
        printf $fh "********** Category: Pitch Costs **********\n";
        for(my $i=0; $i<scalar(@pitches); $i++){
            $pitchesSum += $pitchesCash[$i];
            chomp $pitches[$i];
            printf $fh ("Line %-5d %-10d %-10.2f %s\n", $i+1, $pitchesDate[$i], $pitchesCash[$i], $pitches[$i]);
        }
        printf $fh "Should be $pitchesLines separate pitch payments\n";
        printf $fh "Total pitch costs = £$pitchesSum\n";

        printf $fh "\n";
        printf $fh "\n";
        printf $fh "********** Category: Refunds **********\n";
        for(my $i=0; $i<scalar(@refunds); $i++){
            $refundsSum += $refundsCash[$i];
            chomp $refunds[$i];
            printf $fh ("Line %-5d %-10d %-10.2f %s\n", $i+1, $refundsDate[$i], $refundsCash[$i], $refunds[$i]);
        }
        printf $fh "Should be $refundsLines separate refunds\n";
        printf $fh "Total refunds = £$refundsSum\n";

        printf $fh "\n";
        printf $fh "\n";
        printf $fh "********** Category: Fundraising **********\n";
        for(my $i=0; $i<scalar(@fundraisings); $i++){
            $fundraisingsSum += $fundraisingsCash[$i];
            chomp $fundraisings[$i];
            printf $fh ("Line %-5d %-10d %-10.2f %s\n", $i+1, $fundraisingsDate[$i], $fundraisingsCash[$i], $fundraisings[$i]);
        }
        printf $fh "Should be $fundraisingsLines separate fundraising contributions\n";
        printf $fh "Total fundraisings = £$fundraisingsSum\n";

        printf $fh "\n";
        printf $fh "\n";
        printf $fh "********** Category: Facilities **********\n";
        for(my $i=0; $i<scalar(@facilities); $i++){
            $facilitiesSum += $facilitiesCash[$i];
            chomp $facilities[$i];
            printf $fh ("Line %-5d %-10d %-10.2f %s\n", $i+1, $facilitiesDate[$i], $facilitiesCash[$i], $facilities[$i]);
        }
        printf $fh "Should be $facilitiesLines separate facility payments\n";
        printf $fh "Total cost for facilities = £$facilitiesSum\n";

        printf $fh "\n";
        printf $fh "\n";
        printf $fh "********** Category: Fines **********\n";
        for(my $i=0; $i<scalar(@fines); $i++){
            $finesSum += $finesCash[$i];
            chomp $fines[$i];
            printf $fh ("Line %-5d %-10d %-10.2f %s\n", $i+1, $finesDate[$i], $finesCash[$i], $fines[$i]);
        }
        printf $fh "Should be $finesLines separate fine payments\n";
        printf $fh "Total cost of fines = £$finesSum\n";

        printf $fh "\n";
        printf $fh "\n";
        printf $fh "********** Summary **********\n";
        printf $fh "Total payments from Abos = £$paymentsSum\n";
        printf $fh "Total miscelleneous spends= £$miscSpendsSum\n";
        printf $fh "Total miscelleneous received = £$miscReceivesSum\n";
        printf $fh "Total referee costs = £$refereesSum\n";
        printf $fh "Total pitch costs = £$pitchesSum\n";
        printf $fh "Total refunds = £$refundsSum\n";
        printf $fh "Total fundraisings = £$fundraisingsSum\n";
        printf $fh "Total cost for facilities = £$facilitiesSum\n";
        printf $fh "Total cost for fines = £$finesSum\n";
        my $summation = $paymentsSum + $miscSpendsSum + $miscReceivesSum + $refereesSum + $pitchesSum + $refundsSum + $fundraisingsSum + $facilitiesSum + $finesSum;
        printf $fh "Net debit / credits = £$summation\n";
        printf $fh "Read $lineCountTotal lines (in total) from file $file\n";
        my $categoryLinesTotal = $paymentsLines + $miscSpendsLines + $miscReceivesLines + $refereesLines + $pitchesLines + 
            $refundsLines + $fundraisingsLines + $facilitiesLines + $finesLines;
        printf $fh ("Summation of all lines in each category = %d", $categoryLinesTotal);

        # close the file
        close $fh;
    }
}

sub fileWanted {
    # expect zero arguments
    if (@_ != 0){
        say "Error on line: ".__LINE__;
        exit;
    }
    if ($File::Find::name =~ /sheet\.txt$/){
        push @contentFile, $File::Find::name;
    }
    return;
}

sub checkFolderExists {
    # expect one argument
    if (@_ != 1){
        say "Error on line: ".__LINE__;
        exit;
    }
    # pass folder name as first argument to this function
    my $folderName = $_[0];
    if (-d $folderName){
        #say "$folderName exists, continuing ...";
        return 1;
    }
    else {
        say "Error: folder '$folderName' doesn't exist";
        return 0;
    }
}
