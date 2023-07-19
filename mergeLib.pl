#!/usr/bin/perl

# This script is sourced from Brown (with slight modifications). It merges
# several timing libraries into one.
# ------------------------------------------------------------------------------

use strict;
use warnings;

my $sclname = $ARGV[0];
shift @ARGV;
my $cnt = @ARGV;
my %lookup_table = ();

if($cnt>0){
    process_header($ARGV[0]);
    my $file;
    foreach my $file (@ARGV) {
        process_lookup_table($file)
    }
    foreach my $file (@ARGV) {
        process_cells($file)
    }
    print "\n}\n";
} else {
    print "use: mergeLib.pl new_library_name lib1 lib2 lib3 ....";
}

sub process_header {
    my $filename  = shift;
    open(my $fh, '<', $filename) or die "Could not open file $filename $!";
    while (<$fh>) {
        $_ =~ s/\s*$//;
        if(/library\s*\(/) {
            print "library ($sclname) {\n";
            next;
        }
        last if(/^[\t\s]*cell\s*\(/);
        print "$_\n";

        if(/^[\t\s]*\w+\s*\((\w+)\)\s*\{/ and (not /operating_conditions/)) {
            $lookup_table{$1} = 1;
        }
    }
}

sub process_cells {
    my $filename  = shift;

    open(my $fh, '<', $filename) or die "Could not open file $filename $!";

    my $flag = 0;
    # cut the cells
    while (<$fh>) {
        $_ =~ s/\s*$//;
        if(/^[\t\s]*cell\s*\(/) {#&& $flag==0){
            die "Error! new cell before finishing the previous one!\n" if($flag!=0);
            print "\n$_\n";
            $flag=1;
        } elsif($flag > 0){
            $flag++ if(/\{/);
            $flag-- if(/\}/);
            print "$_\n";
        }
    }
}

sub process_lookup_table {
    my $filename  = shift;

    open(my $fh, '<', $filename) or die "Could not open file $filename $!";

    my $flag = 0;
    # cut the cells
    while (<$fh>) {
        $_ =~ s/\s*$//;
        last if(/^[\t\s]*cell\s*\(/);
        if(/^[\t\s]*\w+\s*\((\w+)\)\s*\{/ and (not /\W*operating_conditions.*/) and (not /\W*library.*/)) {
            next if(exists $lookup_table{$1});
            $lookup_table{$1} = 1;
            print "\n$_\n";
            $flag=1;
        } elsif($flag > 0){
            $flag++ if(/\{/);
            $flag-- if(/\}/);
            print "$_\n";
        }
    }
}
