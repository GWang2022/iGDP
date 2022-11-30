#!/usr/bin/perl -w
use strict;
open FL,$ARGV[0];
my %len;
my %telo_contig;
while (<FL>) {
	chomp;
	if($_=~/^@/){
		$_=~s/SN://;
		$_=~s/LN://;
		my @c=split(/\t/,$_);
		$len{$c[1]}=$c[2];
	}else{
		my @temp = split /\t/;
		if($temp[3]<=1000 or abs($temp[3]-$len{$temp[2]})<=1000){  # start position of mapped telomere reads must be within 1kb of contig ends
			my $cid = $temp[2];          # contig id
			my $cigar = $temp[5];
			my $rlen = length($temp[9]); # read length
			my $asi = $temp[14];$asi =~ s/AS:i://;
			my $xsi = $temp[15];$xsi =~ s/XS:i://;
			my $sum;
			while ($cigar =~ /M/) {
				my $mm = $1 if ($cigar =~ /(\d+)M/);
				$sum += $mm;         # matched bases
				$cigar =~ s/M//;
			}
			my $rate = $sum/$rlen;       # match ratio
			if ($rate >= 0.5) {
				$telo_contig{$cid}++;
				if ($asi <= $xsi) {
					foreach my $k (@temp) {
						if ($k =~ /XA:Z:/) {
							$k =~ s/XA:Z://;
							my @sup = split /\;/,$k;
							foreach my $f (@sup) {
								my $sid = (split /\,/,$f)[0];
								$telo_contig{$sid}++;
							}
						}
					}
				}
			}
		}
	}
}
close FL;
foreach (keys %telo_contig) {
        print "$_\n";
}
