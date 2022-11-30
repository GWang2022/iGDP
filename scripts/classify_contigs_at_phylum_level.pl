#!/usr/bin/perl -w
use strict;
open FL, $ARGV[0];
my %hash;
while (<FL>){
	chomp;
        my @ar=split(/\t/,$_);
	if($ar[-1] ne "unclassified" and $ar[-1]!~/-_unclassified entries/ and $ar[-1]!~/-_other entries/){
		$ar[0]=~s/#.*//;
		my $domain=$ar[-1];
		my $phylum=$ar[-1];
		$domain=~s/^.*;d_//;
		$domain=~s/d_//;
		$domain=~s/;.*//;
		if($phylum=~/;p_/){
			$phylum=~s/^.*;p_//;
			$phylum=~s/;.*//;
		}else{
			$phylum=$domain;
		}
		$hash{$ar[0]}.="$domain\t$phylum\;";
	}
}

foreach (sort keys %hash){
	chomp;
	$hash{$_}=~s/;$//;
        my @ar=split (/\;/,$hash{$_});	
	my %freq;
	foreach my $ele (@ar){
		$freq{$ele}++;
	}
	my $first;
	my $firstC;
	my $c=0;
	foreach my $x (sort {$freq{$b} <=> $freq{$a}} keys %freq){
		$c++;
		if ($c==1){	
			$first=$x;
			$firstC=$freq{$x};
		}
	}
	print "$_\t$first\t$firstC\n";
	
}
