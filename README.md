# iGDP v1.1.0

![Good](https://img.shields.io/badge/latest%20version-v1.1.0-red) ![Active](https://www.repostatus.org/badges/latest/active.svg) ![GPL](https://img.shields.io/badge/license-GPLv3.0-blue)

## An integrated Genome Decontamination Pipeline (iGDP) for wild ciliated microeukaryotes

iGDP works as a "positive filter" to select target ciliate sequences from genomic sequencing data containing various contaminants by integrating homology search, telomere reads-assisted and clustering approaches.

</br>
<div align=center>
<img src = "https://user-images.githubusercontent.com/107245708/204684430-ead5e9c4-3b43-4aaa-95a2-cd50a9212f87.jpg", width = "500">
</div>

</br>

* Issues, bug reports and feature requests: [GitHub issues](https://github.com/GWang2022/iGDP/issues)
* Contact: Guangying Wang (wangguangying@ihb.ac.cn); Chuanqi Jiang (jiangchuanqi@ihb.ac.cn)
* Citation: [iGDP: An integrated Genome Decontamination Pipeline for wild ciliated microeukaryotes. Unpublished.]()

# Install
* ## Depend tools (Please ignore if already available)  
```
# mmseqs2 (>=v13.45111)
$ conda install -c bioconda mmseqs2
  
# bwa (>=v0.7.17)
$ conda install -c bioconda bwa
  
# samtools (>=v1.7)
$ conda install -c bioconda samtools
  
# metabat2 (>=v2.12.1)
$ conda install -c bioconda metabat2
```
* ## iGDP 
```
$ git clone https://github.com/GWang2022/iGDP.git
# add iGDP scripts directory to your PATH environment variable
$ echo 'PATH=$(pwd)/iGDP/scripts/:$PATH' >> ~/.bashrc
$ source ~/.bashrc
```
# Download NCBI NR protein database using mmseqs
```
# Usage: mmseqs databases <name> <o:sequenceDB> <tmpDir> [options]
# Downloading NR database named with prefix 'NRdb' in your working directory using the following command
$ mmseqs databases NR NRdb tmpDir
```
*Tip:* You can creat your own database for homology search using ```mmseqs createdb``` module. For more details, see [mmseqs](https://github.com/soedinglab/MMseqs2).
# Usage
## Workflow
<div align=center>
<img src = "https://user-images.githubusercontent.com/107245708/204125506-400ad79a-a7e2-436e-abd4-b290eb2fd640.jpg", width = "600">
</div>  
<div align=center>
<img src = "https://user-images.githubusercontent.com/107245708/215422762-7d1dac72-a9cc-47d9-a1df-43a38060531e.png", width = "600">
</div> 

## Run iGDP
* ### Implement homology search program
```
$ iGDP_homology_search.pl -i <input.contigs.fa> -o <output_dir> -d <mmseqs_DB> [options]

options:
  -i <required>:  input assembled contigs [.gz or uncompressed]
  -o <required>:  output directory [e.g. homology_search]
  -d <required>:  database for mmseqs search
  -rank [optional]: target taxonomic space of homology search [format, rank:taxon; rank must be phylum/class/order/family/genus/species and taxon begins     
                  with a capital letter; default: phylum:Ciliophora]
  -b [optional]:  bin size [contig is cut to -b bp for homology search; default: 1000]
  -s [optional]:  mmseqs seach sensitivity [1.0 faster; 4.0 fast; 7.5 sensitive; default: 5.7]
  -t [optional]:  number of threads used for mmseqs [default: 72]
  -T [optional]:  translation table of the target genome [default: 6 for ciliates]
```

* ### Implement telomere reads-assisted program
```
$ iGDP_telomere_reads.pl -i <input.contigs.fa> -o <output_dir> -r1 <reads1> -r2 <reads2> [options]

options:
  -i  <required>:  input assembled contigs [.gz or uncompressed]
  -o  <required>:  output directory [e.g. telomere_reads]
  -r1 <required>:  read1 input file name [.gz or uncompress]
  -r2 <required>:  read2 input file name [.gz or uncompress]
  -u  [optional]:  5' to 3' telomeric repeat unit of the target genome [default: CCCCAA for Tetrahymena species]
  -b  [optional]:  threads for bwa mem [default: 8]
  -s  [optional]:  threads for samtools view [default: 8]
```

* ### Implement clustering program
```
$ iGDP_clustering.pl -i <input.contigs.fa> -o <output_dir> -r1 <reads1> -r2 <reads2> [options]

options:
  -i  <required>:  input assembled contigs [.gz or uncompressed]
  -o  <required>:  output directory [e.g. clustering]
  -r1 <required>:  read1 input file name [.gz or uncompress]
  -r2 <required>:  read2 input file name [.gz or uncompress]
  -b  [optional]:  threads for bwa mem [default: 8]
  -s  [optional]:  threads for samtools view [default: 8]
```
*Tip:* Running `iGDP_clustering.pl` must be after implementing `iGDP_homology_search.pl` and `iGDP_telomere_reads.pl` programs.

# An example of running iGDP
Please enter the `iGDP/` directory after downloading iGDP and NR protein database.

You will see three files in the `example/` directory:

* The file `assemly.fa.gz` is a contaminated genome assembly.  
* The files `read1.fq.gz` and `read2.fq.gz` are paired-end short-read sequencing data for the above genome.

Enter the `example/` directory and implement the following command lines:
```
$ iGDP_homology_search.pl -i assemly.fa.gz -o homology_search -d {path_to_NR}/NRdb
$ iGDP_telomere_reads.pl -i assemly.fa.gz -o telomere_reads -r1 read1.fq.gz -r2 read2.fq.gz
$ iGDP_clustering.pl -i assemly.fa.gz -o clustering -r1 read1.fq.gz -r2 read2.fq.gz
```

Then the follwong data files will be created and deposited in the `example/` directory:  
* The files `homology_search.homology.recall.contigs`, `telomere_reads.telo_reads.recall.contigs` and `clustering.contigs` contain contig IDs obtained by `iGDP_homology_search.pl`, `iGDP_telomere_reads.pl` and `iGDP_clustering.pl` programs, respectively;

* The folders `homology_search/`, `telomere_reads/` and `clustering/` contain intermediate data files generate by the above commands.

* The file `final_genome.fa` is the final genome after contamination removal.

# Update
* 2022/10/14
   * intergate clustering program into iGDP
   * add `-rank` option allowing user to set the homology search space for the target species.
