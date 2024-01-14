#!/bin/bash

# Usage: ./random_snp.sh <your_vcf_file>

# Check if a file name is provided
file=${1?Error: no file name provided}

# Create a file with the number of SNPs per locus (excluding header lines)
grep "#" "$file" > random_vcf.vcf
lines=$(wc -l random_vcf.vcf | cut -f 1 -d " ")

# Calculate the repetitions per locus
cut -f 1 "$file" | awk -v var="$lines" 'NR > var' | sort | uniq -c | sed -E 's/^\s+(\w+)/\1/g' > counts_by_loci.txt

# Select a random nucleotide for each locus
cat counts_by_loci.txt | while read i;
do
  number=$(grep "$i" counts_by_loci.txt | cut -d " " -f 1)
  locus=$(grep "$i" counts_by_loci.txt | cut -d " " -f 2)
  grep "$locus" "$file" | shuf -n 1 >> random_vcf.vcf
done

# Clean up temporary files
rm counts_by_loci.txt

echo "Random SNP selection completed. Output saved to random_vcf.vcf."
