#!/usr/bin/perl -w
use strict;
open TARGET,$ARGV[0];
open FL,$ARGV[1];
my %hs;
while(<TARGET>)
{
        chomp;
	$hs{$_}=1;
}
my %group;
while(<FL>)
{
        chomp;
	my @ar=split(/[\,\t]/,$_);
	if($ar[-1]>0){
		if($hs{$ar[0]}){
			$group{$ar[1]}=1;
		}
	}
}

my %final;
open FL,$ARGV[1];
while(<FL>)
{
        chomp;
        my @ar=split(/[\,\t]/,$_);
        if($group{$ar[1]}){
                $final{$ar[1]}.="$ar[0]\n";
        }
}

foreach (sort keys %final)
{
	chomp;
	print "$final{$_}";
}
