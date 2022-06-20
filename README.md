# Introduction
Genome Refinement Pipeline (GRP) is an automatic workflow to refine the target genome assembled from wild samples of eukaryotic microbes by combining homology search approach and telomere-reads assisted approach. It can be applied to different sequencing technology such as NGS, sing-cell sequencing and third-generation sequencing, and different types of omics data such as genomic and transcriptomic data.

# Dependencies
MMseqs2. https://github.com/soedinglab/mmseqs2/

samtools. https://github.com/samtools/samtools

bwa. https://github.com/lh3/bwa

# Workflow of GRP
![gpr1](https://user-images.githubusercontent.com/107245708/174552229-62107082-3d7b-4555-b1c8-0cba361ac7af.jpg)


# How to run GRP

* ## *Homology Search Approach*
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

* ## *Telomere-reads Assisted Approach*
```
perl telo_reads_recall.pl -i <input.contigs.fa> -o <output_dir> -p <path_to_GRP/scripts> -r1 <reads1> -r2 <reads2> [options]
```

The options for using this approach are below.
```
        -i  <required>:  input contigs [fa.gz or uncompress]
        -o  <required>:  path to output directory
        -p  <required>:  path to directory of GRP scripts
        -r1 <required>:  read1 input file name [fq.gz or uncompress]
        -r2 <required>:  read1 input file name [fq.gz or uncompress]
        -u  [optional]:  5' to 3' telomeric repeat unit of the target genome [default: CCCCAA for Tetrahymena species]
        -b  [optional]:  threads for bwa mem [default: 8]
        -s  [optional]:  threads for samtools view [default: 8]
```

* ## *Combining Sequences From Two Approaches*
```
cat target.homology.recall.contig.id target.telo_reads.recall.contig.id | sort | uniq | perl /path_to_GRP/scripts/combine_contigs.pl input.contigs.fa - > final.target.genome.fasta
```

# Quality evaluation of the refined target genome

The quality of refined target genome including recall rate, purity and completeness can be evaluated using the corresponding metrics shown in the workflow diagram.
