# iGDP v1.0

The integrated Genome Decontamination Pipeline (iGDP) works as a positive filter to select the target sequences from contaminated genome assemblies of wild ciliated microeukaryotes.


Issues, bug reports and feature requests: https://github.com/GWang2022/iGDP/issues
Contact: Guangying Wang (wangguangying@ihb.ac.cn)

# Dependencies
MMseqs2. https://github.com/soedinglab/mmseqs2/

bwa. https://github.com/lh3/bwa

samtools. https://github.com/samtools/samtools

# Workflow of GRP
![1](https://user-images.githubusercontent.com/107245708/203978844-f047e839-64c0-431b-8747-6e2d674a2838.jpg)

# How to run GRP

* ## *Homology Search Approach*
```
perl homology_recall.pl -i <input.contigs.fa> -o <output_dir> -b <bin_size> -p <path_to_GRP/scripts> -d <mmseqs_DB> [options]
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
