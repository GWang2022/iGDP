#!/usr/bin/perl -w
use strict;
open FL,$ARGV[0];
open ID,$ARGV[1];
my %hs;
my $tag;
while(<FL>)
{
	chomp;
	if($_=~/>/){
		($tag)=($_=~/>(.*)/);
	}else{
		$hs{$tag}.=$_;
	}
}
while(<ID>)
{
	chomp;
	if($hs{$_}){
		print ">$_\n$hs{$_}\n";
	}
}
