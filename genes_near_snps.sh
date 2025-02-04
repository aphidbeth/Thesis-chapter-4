# Notes on annotation of snps 

# run in an interactive session

# Resources required: 
# Sitobion avenae genome (https://figshare.com/articles/dataset/Sitobion_avenae_genome_sequence_primary_/14675367?file=28177452)
# The gff file for this genome from figshare (https://figshare.com/articles/dataset/Sitobion_avenae_genome_annotation_primary_/14675391?file=28177587)
# Protein sequences for this genomes from figshare (https://figshare.com/articles/dataset/Sitobion_avenae_proteins_primary_/14675418?backTo=%2Fcollections%2FGrain_aphid_Sitobion_avenae_genomics%2F5425896&file=28177614)
# snpEff for annotation : https://pcingola.github.io/SnpEff/
# gffread for creating a CDS file (download using conda below)
# Java for running snpEff  (download using conda below)

# Create conda environment with java: 

conda create -n java

conda install java -n java

conda install gffread -n gffread

source activate java

# Create the files and folders we need: 

cd snpEff

mkdir data/sa_v1.0

mv S.avenae-primary-V1.0.braker.gff3 data/sa_v1.0/genes.gff
mv S.avenae-primary-V1.0.proteins.fasta data/sa_v1.0/proteins.fa
mv S.avenae-primary-V1.0.fna data/sa_v1.0/sequences.fa
 
# create CDS file

gffread -g sequences.fa -x cds.fa genes.gff

# Compress files: 
gzip genes.gff
gzip sequences.fa
gzip proteins.fa
gzip cds.fa

# Build custom database with snpEff: 

# add a line to the config file under # Non-standard Databases manually using nano 
# sa_V1.0.genome : sitobion_avenae


# Build the custom database

java -jar snpEff.jar build -gff3 -v sa_v1.0

# this should put a bunch of .bin files in your data/sa_v1.0 folder


# Run again with your vcf file to find out where the variants lie

java -jar snpEff.jar -v -i bed -o bedAnn sa_V1.0 all.SNPs.bed > test.ALL.SNPS.ann.bed # note this needs updating to VCF when I get home.
