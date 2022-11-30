#! /usr/bin/perl -w
use strict;
use Getopt::Long qw(:config no_ignore_case); 
my %opts;GetOptions(\%opts,"i=s","o=s","r1=s","r2=s","u=s","b=n","s=n");
my $usage = <<"USAGE";
Usage:

iGDP_telomere_reads.pl -i <input.contigs.fa> -o <output_dir> -r1 <reads1> -r2 <reads2> [options]

options:
        -i  <required>:  input assembled contigs [.gz or uncompressed]
        -o  <required>:  output directory [e.g. telomere_reads_approach]
        -r1 <required>:  read1 input file name [fq.gz or uncompress]
        -r2 <required>:  read1 input file name [fq.gz or uncompress]
        -u  [optional]:  5' to 3' telomeric repeat unit of the target genome [default: CCCCAA for Tetrahymena species]
        -b  [optional]:  threads for bwa mem [default: 8]
        -s  [optional]:  threads for samtools view [default: 8]

USAGE
die $usage if(!($opts{i}&&$opts{o}&&$opts{r1}&&$opts{r2}));

my $outdir = `pwd`; chomp $outdir;
my $outfile = $opts{o}; chomp $outfile;
`mkdir -p $outdir/$outfile/`;
$opts{u} ||= "CCCCAA";
my $t1 = $opts{u};
my $r1 = $opts{r1};
my $r2 = $opts{r2};
$r1 =~ /.gz$/ ? open IE,"gzip -dc $r1|"||die "error:can't open infile:$r1\n" : open IE,"$r1"||die "$!\n";
$r2 =~ /.gz$/ ? open IF,"gzip -dc $r2|"||die "error:can't open infile:$r2\n" : open IF,"$r2"||die "$!\n";
open OE,">$outdir/$outfile/$outfile.telo_read1.fq"||die "$!\n";
open OF,">$outdir/$outfile/$outfile.telo_read2.fq"||die "$!\n";

my @telo = split(//,$t1);
my @telo_res = reverse @telo;
my $t2 = join "",@telo_res;
$t2 =~ tr/AGCT/TCGA/;
my $str1 = ($t1 x 4);
my $str2 = ($t2 x 4);
my $t1len = length($str1);
my $t2len = length($str2);
my (%rj, %tp, $rid);
while (<IE>) {
                $rid = ($_ =~ /\//) ? (split /\//,$_)[0] : (split /\s+/,$_)[0];
                chomp(my $re1 = <IE>);my $qua = <IE>;my $qub = <IE>;
                my $sub1 = substr($re1,0,$t1len);
                my $sub2 = substr($re1,0,$t1len/2);
                my $sub11 = substr($re1,-$t1len);
                my $sub22 = substr($re1,-$t1len/2);
                $rj{$rid}{'1'} = join("",$re1,"\n",$qua,$qub);
                $tp{$rid}++ if $sub1 =~ /($t1){2,}/ or $str1 =~ /$sub2/ or $sub11 =~ /($t2){2,}/ or $str2 =~ /$sub22/; 
}
while (<IF>) {
                $rid = ($_ =~ /\//) ? (split /\//,$_)[0] : (split /\s+/,$_)[0];
                chomp(my $re2 = <IF>);my $qua = <IF>;my $qub = <IF>;
                my $sub1 = substr($re2,0,$t2len);
                my $sub2 = substr($re2,0,$t2len/2);
                my $sub11 = substr($re2,-$t2len);
                my $sub22 = substr($re2,-$t2len/2);
                $rj{$rid}{'2'} = join("",$re2,"\n",$qua,$qub);
                $tp{$rid}++ if $sub1 =~ /($t1){2,}/ or $str1 =~ /$sub2/ or $sub11 =~ /($t2){2,}/ or $str2 =~ /$sub22/;
}
foreach my $k (keys %tp) {
                print OE "$k\/1\n$rj{$k}{'1'}";
                print OF "$k\/2\n$rj{$k}{'2'}";
}
close IE;close IF;close OE;close OF;
my $infile = $opts{i};

`mkdir -p $outdir/$outfile/bwa`;
$infile =~ /.gz$/ ? open IG,"gzip -dc $infile | "||die "error:can't open infile:$infile\n" : open IG,"$infile"||die "$!\n";
open OG,">$outdir/$outfile/bwa/raw.assembly.fa"||die "$!\n";
while(<IG>)
{
        chomp;
        if($_=~/>/){
                $_=~s/\s+/_/g;
                print OG "$_\n";
        }else{
                print OG "$_\n";
        }
}
close IG;close OG;

$opts{b} ||= 8;
my $tb = $opts{b};
$opts{s} ||= 8;
my $ts = $opts{s};
`mv $outdir/$outfile/$outfile.telo_read1.fq $outdir/$outfile/$outfile.telo_read2.fq $outdir/$outfile/bwa;
 cd $outdir/$outfile/bwa;
 bwa index raw.assembly.fa 2>>bwa.log;
 bwa mem -t $tb -T 30 -K 10000000 -M raw.assembly.fa $outfile.telo_read1.fq $outfile.telo_read2.fq > $outfile.telo_reads.bwamap.sam 2>>bwa.log;
 samtools view -@ $ts -h -f 0x2 -F 0x100 -F 0x800 $outfile.telo_reads.bwamap.sam | telo_reads_support_contigs.pl - > $outfile.telo_reads.recall.contigs;
 cp $outfile.telo_reads.recall.contigs ../../
`;
