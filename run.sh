## homology search approach
perl homo_recall.pl -i input.contigs.fa -o outname -w bin_size -p path_to_GRP_scripts -d mmseqs_DB
## telomere reads assisted approach 
perl telo_reads_recall.pl input.contigs.fa example_read1.fq example_read2.fq CCCCAA sample GRP/scripts/
## obtain final genome sequences
cat sample.homology.recall.contig.id sample.telo_reads.recall.contig.id | sort | uniq | perl combine_contigs.pl input.contigs.fa - > final_genome.fasta
