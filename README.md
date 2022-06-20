# Introduction
Genome Refinement Pipeline (GRP) is an automatic workflow to refine the target genome assembled from wild samples of eukaryotic microbes by combining homology search approach and telomere-reads assisted approach. It can be applied to different sequencing technology such as NGS, sing-cell sequencing and third-generation sequencing, and different types of omics data such as genomic and transcriptomic data.

# Dependencies
MMseqs2. https://github.com/soedinglab/mmseqs2/

samtools. https://github.com/samtools/samtools

bwa. https://github.com/lh3/bwa

# Workflow of GRP
![gpr2](https://user-images.githubusercontent.com/107245708/174463561-1a5649e0-84c6-4c26-b4c7-b85a90413627.jpg)


# How to run GRP

## *Homology Search Approach*
```
perl homology_recall.pl -i <input.contigs.fa> -o <output_dir> -b <bin_size> -p <path_to_GRP_scripts> -d <mmseqs_DB> [options]
```

The options for using this approach are below.
```
        -i <required>:  input contigs [fa.gz or uncompress]
        -o <required>:  path to output directory
        -p <required>:  path to directory of GRP scripts
        -d <required>:  database for mmseqs search
        -b [optional]:  bin size [contig is cut to -b bp for homology search; default: 1000]
        -s [optional]:  mmseqs sensitivity [1.0 faster; 4.0 fast; 7.5 sensitive; default: 4.0]
        -t [optional]:  number of threads used for MMseqs2 seach [default: 48]
        -T [optional]:  translation table of the target genome [default: 6 for ciliates]
```

## *Telomere-reads Assisted Approach*
```
perl telo_reads_recall.pl -i <input.contigs.fa> -o <output_dir> -p <path_to_GRP/scripts> -r1 <reads1> -r2 <reads2> [options]
```

The options for using this approach are below.
        -i  <required>:  input contigs [fa.gz or uncompress]
        -o  <required>:  path to output directory
        -p  <required>:  path to directory of GRP scripts
        -r1 <required>:  read1 input file name [fq.gz or uncompress]
        -r2 <required>:  read1 input file name [fq.gz or uncompress]
        -u  [optional]:  5' to 3' telomeric repeat unit of the target genome [default: CCCCAA for Tetrahymena species]
        -b  [optional]:  threads for bwa mem [default: 8]
        -s  [optional]:  threads for samtools view [default: 8]
```

        
