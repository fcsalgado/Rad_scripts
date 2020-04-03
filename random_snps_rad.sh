#! /bin/bash

#To run this script you hace to execute it follow by the name of your VCF file

file=${1?Error: no given name}
#create a file with the number of SNPs per locus, replace the awk number by the number of header lines
grep "#" $file > random_vcf.vcf
lines=$(wc -l random_vcf.vcf | cut -f 1 -d " ")
#calculate the repetitions per locus
cut -f 1 $file | awk -v var=$lines 'NR > var' | sort | uniq -c | sed -E 's/^\s+(\w+)/\1/g' > counts_by_loci.txt

#select randon one nucleotide
cat counts_by_loci.txt | while read i;
do
number=$(grep "$i" counts_by_loci.txt | cut -d " " -f 1)
locus=$(grep "$i" counts_by_loci.txt | cut -d " " -f 2)
grep "$locus" $file | shuf -n 1 >> random_vcf.vcf; done

rm counts_by_loci.txt
