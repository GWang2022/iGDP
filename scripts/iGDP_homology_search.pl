#! /usr/bin/perl -w
use strict;
use Getopt::Long qw(:config no_ignore_case); 
my %opts;GetOptions(\%opts,"i=s","o=s","d=s","rank=s","b=n","s=s","t=n","T=n");
my $usage = <<"USAGE";
Usage:

iGDP_homology_search.pl -i <input.contigs.fa> -o <output_dir> -d <mmseqs_DB> [options]

options:
	-i <required>:  input assembled contigs [.gz or uncompressed]
	-o <required>:  output directory [e.g. homology_search_approach]
	-d <required>:  database for mmseqs search
	-rank [optional]:  target taxonomic space of homology search [format, rank:taxon; rank must be phylum/class/order/family/genus/species and taxon begins with a capital letter; default: phylum:Ciliophora]
	-b [optional]:  bin size [contig is cut to -b bp for homology search; default: 1000]
	-s [optional]:  mmseqs seach sensitivity [1.0 faster; 4.0 fast; 7.5 sensitive; default: 5.7]
	-t [optional]:  number of threads used for mmseqs [default: 72]
	-T [optional]:  translation table of the target genome [default: 6 for ciliates]

USAGE
die $usage if(!($opts{i}&&$opts{o}&&$opts{d}));

my $infile = $opts{i}; chomp $infile;
my $outfile = $opts{o}; chomp $outfile;
$opts{b} ||= 1000;
my $bin = $opts{b};
my $outdir ||= `pwd`; chomp $outdir;
my $mmseqs_DB = $opts{d};
my $win=$bin."bpbin";
`mkdir -p $outdir/$outfile/`;
$infile =~ /.gz$/ ? open IF,"gzip -dc $infile | "||die "error:can't open infile:$infile\n" : open IF,"$infile"||die "$!\n";

open OF,">$outdir/$outfile/$outfile.split.$win.fasta"||die "$!\n";
my %fasta;
my $fa_id;
while(<IF>)
{
	chomp;
	if($_=~/>/){
		$_=~s/\s+/_/g;
		$fa_id=$_;
	}else{
		$fasta{$fa_id}.=$_;
	}
}
foreach (keys %fasta){
        chomp;
	if(length($fasta{$_})<$bin){

                print OF "$_\#1\n$fasta{$_}\n";
        }else{
	        my $n = 0;
		my $p = length($fasta{$_})/$bin;
	        for (my $i = 0;$n < $p;$i = $i+$bin){
		        my $s = substr($fasta{$_},$i,$bin);$n++;
			length ($s) < $bin/2 ? print OF "$s" : print OF "\n$_\#$n\n$s";  ## merge terminal sequence of < $bin/2 bp to the last bin
		}
		print OF "\n";
	}
}
close IF;close OF;
$opts{s} ||= 5.7;
my $sensitivity = $opts{s};
$opts{t} ||= 72;
my $threads = $opts{t};
$opts{T} ||= 6;
my $translation_table = $opts{T};
$opts{rank} ||= "phylum:Ciliophora";
my @space = split(/\:/,$opts{rank});
my $rank=substr($space[0],0,1)."_";
my $taxon=$rank."$space[1]";

`sed -i '/^\$/d' $outdir/$outfile/$outfile.split.$win.fasta`;
`cd $outdir/$outfile/;
 mmseqs createdb $outfile.split.$win.fasta queryDB;
 mmseqs search --translation-table $translation_table --threads $threads -s $sensitivity queryDB $mmseqs_DB output tmp;
 mmseqs convertalis queryDB $mmseqs_DB output $outfile.split.$win.mmseqs.out --format-output query,target,evalue,pident,taxid,taxname,taxlineage;
 mkdir mmseqs/;mv output* queryDB* tmp mmseqs/;
 awk '!a[\$1]++' $outfile.split.$win.mmseqs.out > $outfile.split.$win.mmseqs.out.tophit;
 target_taxon_hit_contigs.pl $outfile.split.$win.mmseqs.out.tophit $rank $taxon > $outfile.homology.recall.contigs;
 cp $outfile.homology.recall.contigs ../
`;
