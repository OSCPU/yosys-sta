#!/usr/bin/perl

# This script is sourced from Brown (with slight modifications). It merges
# several timing libraries into one.
# ------------------------------------------------------------------------------

use warnings;

my $lib_file     = $ARGV[0];
my $dontuse_list = $ARGV[1];

if(@ARGV > 0) {
    open(my $fh, '<', $lib_file) or die "Could not open file $lib_file $!";
    my $remove_cell_flag = 0;
    my $remove_info_flag = 0;
    while (<$fh>) {
        if($_ =~ /^[\t\s]*cell\s*\(\s*("?\w+)/) {
            my $cell_name = $1;
            die "Error! new cell before finishing the previous one!\n" if($remove_cell_flag != 0);
            foreach $apatten (split /\s+/,$dontuse_list) {
                $apatten =~ s/\*/.*/g;
                $remove_cell_flag = 1 if ($cell_name =~ /$apatten/);
            }
            print "$_" if($remove_cell_flag == 0);
        } elsif($remove_cell_flag > 0){
            $remove_cell_flag++ if(/\{/);
            $remove_cell_flag-- if(/\}/);
        } else {
            #print "$_" ;
            if($_ =~ /^\s*(output_current\w*|ccsn_first_stage|ccsn_last_stage|receiver_capacitance)\s*\(/) {
                $remove_info_flag = 1 ;
            } elsif($remove_info_flag > 0){
                $remove_info_flag++ if(/\{/);
                $remove_info_flag-- if(/\}/);
            } else {
                print "$_" ;
            }
        }


    }
} else {
    print "use: removeDontUse.pl lib_file dontuse_list";
}

