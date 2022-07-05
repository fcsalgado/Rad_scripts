#! /bin/bash

#To run this script you hace to execute it follow by the name of your VCF file

file=${1?Error: no given name}

grep "#" $file > random_vcf.vcf
lines=$(wc -l random_vcf.vcf | cut -f 1 -d " ")
#calculate missingness per site
vcftools --vcf $file --missing-site
#select the snp per tag with less missing data
awk 'NR>1' out.lmiss | cut -f 1 | sort | uniq | while read locus;do
site=$(grep -E $(echo "^"$locus) out.lmiss | sort -k6,6n | awk 'NR==1' | cut -f 1,2)
grep $site $file >> random_vcf.vcf; done

vcftools --vcf random_vcf.vcf --hwe 0.05 --recode --out gasteracantha_filtered.vcf
