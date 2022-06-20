#!/usr/bin/perl -w 
use strict;
open FL,$ARGV[0];                                                                         
open CONTIG,$ARGV[1];
my %hs;
my $id;
while (<FL>){
	chomp;
        if ($_=~/^\>/){
		($id) = ($_ =~ /\>(.*)/);
		$id = ~s/\s+/_/g;
        }else{
		$hs{$id} .= $_;
        }
}
while(<CONTIG>){
        chomp;
        if ($hs{$_}){
                print "\>$_\n$hs{$_}\n";
        }
}

