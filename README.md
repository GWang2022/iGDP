# Introduction
Genome Refinement Pipeline (GRP) is an automatic workflow to refine the target genome assembled from wild samples of eukaryotic microbes by combining homology search approach and telomere-reads assisted approach. It can be applied to different sequencing technology such as NGS, sing-cell sequencing and third-generation sequencing, and omics data such as genomic and transcriptomic data.

# Dependencies
MMseqs2. https://github.com/soedinglab/mmseqs2/

samtools. https://github.com/samtools/samtools

bwa. https://github.com/lh3/bwa

# Workflow of GRP
![gpr2](https://user-images.githubusercontent.com/107245708/174463561-1a5649e0-84c6-4c26-b4c7-b85a90413627.jpg)


# How to run GRP
Homology search approach

perl homo_recall.pl -i <input.contigs.fa> -o <output_dir> -b <bin_size> -p <path_to_GRP_scripts> -d <mmseqs_DB> [options]

The options for using this approach is below.
        -i <required>:  input contigs [fa.gz or uncompress]
        -o <required>:  path to output directory
        -b <required>:  bin size [contig is cut to -b bp for homology search]
        -p <required>:  path to directory of GRP scripts
        -d <required>:  database for mmseqs search
        -s [optional]:  mmseqs sensitivity [1.0 faster; 4.0 fast; 7.5 sensitive; default 4.0]  
        e.g. perl homo_recall.pl -i input.contigs.fa -o output -b 1000 -p path_to_GRP/scripts -d mmseqs_DB
