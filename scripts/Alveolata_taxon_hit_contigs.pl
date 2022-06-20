#!/usr/bin/perl -w
use strict;
open FL, $ARGV[0];
my %hash;
while (<FL>){
	if ($_!~/^\#/){
		chomp;
		my @ar=split(/\t/,$_);
		my @tmpx=split(/\#/,$ar[0]);
		$ar[0]=$tmpx[0];
		my @x=(split /\;/, $ar[6])[1..3];
		my $name;
		my @dpc;
		foreach my $a (@x){
			push @dpc,$a if ($a)
		}
		if (@dpc > 0){
			my $taxon = join (";", @dpc);
			$hash{$ar[0]}.="$taxon\t";	
		}	
	}
}
my $besthit;
foreach my $key (sort keys %hash){
	my @ar=split (/\t/,$hash{$key});
	$besthit=$ar[0];
	my %freq;
	foreach my $ele (@ar){
		$freq{$ele}++;
	}
	my $first;
	my $firstC;
	my $Alveo="NA:0";
	my $AlveoC=0;
	my $c=0;
	foreach my $x (sort {$freq{$b} <=> $freq{$a}} keys %freq){
		if ($x eq "d_Eukaryota\;-_Sar\;\-_Alveolata"){
			$AlveoC=$freq{$x};
		}
		$c++;
		if ($c==1){
			$firstC=$freq{$x};
		}
	}
	if($AlveoC>=$firstC){
		print "$key\n";
	}
}
