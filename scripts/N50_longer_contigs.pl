#!/usr/bin/perl -w
use strict;
open FL,$ARGV[0];
my %hs;
my $tag;
while (<FL>){
	chomp;
	if ($_=~/^\>/){
		($tag) =($_ =~ /^\>(.*)/);
	}else{
		 $hs{$tag}.=$_;
	}
}
my @x;
my $total;
foreach (keys %hs)
{
	chomp;
	push @x,length($hs{$_});	
	$total+=length($hs{$_});
}
my $N50;
@x=sort{$b<=>$a} @x; 
my $count=0;

for (my $j=0;$j<@x;$j++){
        $count+=$x[$j];
        if ($count>=$total/2){
                $N50=$x[$j];
                last;
        }
}
foreach (keys %hs)
{       
        chomp;  
        if(length($hs{$_})>=$N50){
		print ">$_\n$hs{$_}\n";
	}
}

