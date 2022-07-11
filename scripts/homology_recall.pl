#! /usr/bin/perl -w
use strict;
#! /usr/bin/perl -w
use strict;
use Getopt::Long qw(:config no_ignore_case); 
my %opts;GetOptions(\%opts,"i=s","o=s","p=s","d=s","b=n","s=s","t=n","T=n");
my $usage = <<"USAGE";
Usage:

perl $0 -i <input.contigs.fa> -o <output_dir> -p <path_to_GRP/scripts> -d <mmseqs_DB> [options]

The options for using this approach are below.
	-i <required>:  input contigs [fa.gz or uncompress]
	-o <required>:  path to output directory
	-p <required>:  path to directory of GRP scripts
	-d <required>:  database for mmseqs search
	-b [optional]:  bin size [contig is cut to -b bp for homology search; default: 1000]
	-s [optional]:  MMseqs2 seach sensitivity [1.0 faster; 4.0 fast; 7.5 sensitive; default: 4.0]
	-t [optional]:  number of threads used for MMseqs2 seach [default: 48]
	-T [optional]:  translation table of the target genome [default: 6 for ciliates]

USAGE
die $usage if(!($opts{i}&&$opts{o}&&$opts{p}&&$opts{d}));

my $infile = $opts{i};
my $outfile = $opts{o}; chomp $outfile;
$opts{b} ||= 1000;
my $bin = $opts{b};
my $outdir ||= `pwd`; chomp $outdir;
my $scripts = $opts{p};
my $mmseqs_DB = $opts{d};
my $win=$bin."bpbin";
`mkdir -p $outdir/$outfile/`;
$infile =~ /.gz$/ ? open IF,"gunzip $infile"||die "error:can't open infile:$infile\n" : open IF,"$infile"||die "$!\n";
open OF,">$outdir/$outfile/$outfile.split.$win.fasta"||die "$!\n";
while(<IF>){
        chomp;
        my $sid = $_;
        $sid =~ s/\s+/_/g;
        my $seq = <IF>;
        chomp   $seq;
        my $n = 0;
        my $p = length($seq)/$bin;
        for (my $i = 0;$n < $p;$i = $i+$bin){
                my $s = substr($seq,$i,$bin);$n++;
                length ($s) < $bin/2 ? print OF "$s" : print OF "\n$sid\#$n\n$s";  ## merge <1000/2 bp to last one
        }
        print OF "\n";
}

$opts{s} ||= 4.0;
my $sensitivity = $opts{s};
$opts{t} ||= 48;
my $threads = $opts{t};
$opts{T} ||= 6;
my $translation_table = $opts{T};

close IF;close OF;
`sed -i '1d' $outdir/$outfile/$outfile.split.$win.fasta`;
`cd $outdir/$outfile/;
 mmseqs createdb $outfile.split.$win.fasta queryDB;
 mmseqs search --translation-table $translation_table --threads $threads -s $sensitivity --max-accept 5 --max-rejected 5 queryDB $mmseqs_DB output tmp;
 mmseqs convertalis queryDB $mmseqs_DB output $outfile.split.$win.mmseqNR.out --format-output query,target,evalue,pident,taxid,taxname,taxlineage;
 mkdir mmseqs/;mv output* queryDB* tmp mmseqs/;
 awk '!a[\$1]++' $outfile.split.$win.mmseqNR.out | perl $scripts/Alveolata_taxon_hit_contigs.pl - > $outfile.homology.recall.contig.id
`;
