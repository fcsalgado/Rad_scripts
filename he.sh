# Script to calculate heterozygosity using VCFtools

# Prerequisites:
# - VCF file named polythore_popgen.vcf
# - A file named pops.txt with population information in the second column (e.g., SampleID_Population)
# - Ensure VCFtools is installed: https://vcftools.github.io/index.html

# Create an intermediate file for each population
cut -f 1 -d "_" pops.txt | sort | uniq | while read pop;
do 
  grep -E "$pop" pops.txt > "$pop".txt
  
  # Calculate heterozygosity using VCFtools
  vcftools --vcf polythore_popgen.vcf --het --keep "$pop".txt --out $pop
  
  # Clean up temporary files
  rm -rf "$pop".txt
  rm -rf tmp.txt
  
  # Process results and append to a summary file
  num=$(awk 'NR>1' $pop.het | wc -l)
  paste <(echo "$(printf "$pop\n%.0s" {1..$num})") <(echo "$(cat $pop.het | awk 'NR >1')") --delimiters '\t' >> het.txt
done
