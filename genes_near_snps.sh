!/bin/bash

# Notes on annotation of snps 

# download the gff file from figshare (https://figshare.com/articles/dataset/Sitobion_avenae_genome_annotation_alternate_/14675394?file=28177590)

# Create conda environment with bedtools and bedops: 

conda create -n bedtools 

conda install bedtools bedops -n bedtools

# Convert the gff to a bed file using gff2bed

gff2bed <  S.avenae-alternate-V1.0.braker.gff3 > GENES.bed

# Get the chromosome and co-ordinates of our putative adaptive snps (uploaded output from R)

head SNPs.bed

# Look at the closest genes to the these snps: 

closest-features --closest --dist < SNPs.bed GENES.bed > genes-closest-to-snps.bed

# Filter out any that are more than 10000 up/downstream of snps:

 awk -F "|" -v max_distance=10000 '{ \
    if ($3 <= max_distance) { \
        print $0; \
    } \
}'  genes-closest-to-snps.bed >  genes-closest-to-snps-filtered.bed

# Visualise the results
