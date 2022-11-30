#!/usr/bin/perl -w
use strict;
use Getopt::Long qw(:config no_ignore_case); 
my %opts;GetOptions(\%opts,"i=s","o=s","r1=s","r2=s","b=n","s=n");
my $usage = <<"USAGE";
Usage:

iGDP_clustering.pl -i <input.contigs.fa> -o <output_dir> -r1 <reads1> -r2 <reads2> [options]

options:
        -i  <required>:  input assembled contigs [uncompressed file]
        -o  <required>:  output directory [e.g. clustering]
        -r1 <required>:  read1 input file name [.gz or uncompress]
        -r2 <required>:  read2 input file name [.gz or uncompress]
        -b  [optional]:  threads for bwa mem [default: 8]
        -s  [optional]:  threads for samtools view [default: 8]

USAGE
die $usage if(!($opts{i}&&$opts{o}&&$opts{r1}&&$opts{r2}));

my $outdir ||= `pwd`; chomp $outdir;
my $outfile = $opts{o}; chomp $outfile;
`mkdir -p $outdir/$outfile/`;
my $infile = $opts{i};
$infile =~ /.gz$/ ? open IF,"gzip -dc $infile | "||die "error:can't open infile:$infile\n" : open IF,"$infile"||die "$!\n";
open OF,">$outdir/$outfile/raw.assembly.fa"||die "$!\n";
while(<IF>)
{
	chomp;	
	if($_=~/>/){ 
		$_=~s/\s+/_/g;
		print OF "$_\n";
 	}else{
		print OF "$_\n";
	}
}
close IF;close OF;

my $r1 = $opts{r1}; chomp $r1;
my $r2 = $opts{r2}; chomp $r2;
$opts{b} ||= 8;
my $tb = $opts{b};
$opts{s} ||= 8;
my $ts = $opts{s};
`cp $r1 $outdir/$outfile/read1.fq;
 cp $r2 $outdir/$outfile/read2.fq;
 cd $outdir/$outfile/;
 cat ../*homology.recall.contigs ../*telo_reads.recall.contigs | sort | uniq > homology.telomere_reads.recall.contigs;
 get_contig_seqs.pl raw.assembly.fa homology.telomere_reads.recall.contigs > homology.telomere_reads.recall.contigs.fa;
 cat ../*/*mmseqs.out.tophit | classify_contigs_at_phylum_level.pl - | cut -f 1 | sort | uniq > classfified.contigs;
 comm -23 classfified.contigs homology.telomere_reads.recall.contigs > contaminant.contigs;
 cat raw.assembly.fa |grep '>' | sed 's/>//' | sort > all.contigs;
 cat homology.telomere_reads.recall.contigs classfified.contigs | sort | uniq |comm -23 all.contigs - > unclassfied.contigs;
 N50_longer_contigs.pl homology.telomere_reads.recall.contigs.fa | grep '>' | sed 's/>//' | sort > N50_longer.contigs;
 cat N50_longer.contigs unclassfied.contigs | sort | uniq | get_contig_seqs.pl raw.assembly.fa - > N50_longer.unclassfied.contigs.fa;
 bwa index raw.assembly.fa;
 bwa mem -t $tb -M raw.assembly.fa read1.fq read2.fq -o clustering.sam 2>>log;
 samtools view -@ $ts -b -f 0x2 -F 0x100 -F 0x800 -q 20 clustering.sam > clustering.sam.bam 2>>log;
 rm -f clustering.sam;
 samtools sort -O bam -@ 24 -o clustering.sort.bam -T clustering.sam.bam-tmp clustering.sam.bam 2>>log;
 rm -f clustering.sam.bam;
 jgi_summarize_bam_contig_depths --outputDepth depth.txt clustering.sort.bam 2>>log;
 cut -f 1 depth.txt | get_contig_seqs.pl N50_longer.unclassfied.contigs.fa - > N50_longer.unclassfied.contigs.sort.fa;
 metabat2 -m 1500 -t 36 -i N50_longer.unclassfied.contigs.sort.fa -a depth.txt -o N50_longer_anclassfied.cluster --saveCls --unbinned;
 metabat_cluster.pl N50_longer.contigs N50_longer_anclassfied.cluster | sort | comm -23 - homology.telomere_reads.recall.contigs > $outfile.contigs;
 cat homology.telomere_reads.recall.contigs $outfile.contigs | sort | uniq | get_contig_seqs.pl raw.assembly.fa - > final_genome.fa;
 cp $outfile.contigs final_genome.fa ../;
 rm -f read1.fq read2.fq
`;

