# Calculate windowed nucleotide diversity and plot in R

# Create an intermediate file for diversity values
touch temp_div.txt

# Process each population in the file pops.txt
cut -f 2 pops.txt | sort | uniq | while read pop; 
do
  grep -E "\s+$pop$" pops.txt | cut -f 1 > tmp.txt
  grep -f tmp.txt out.imiss | cut -f 1 > $pop.txt
  vcftools --vcf gasteracantha_popTotal.vcf --window-pi 150 --keep $pop.txt --out $pop
  rm -rf tmp.txt
  num=$(awk 'NR>1' $pop.windowed.pi | wc -l)
  paste <(echo "$(printf "$pop\n%.0s" {1..$num})") <(echo "$(cut -f 5 $pop.windowed.pi | awk 'NR >1')") --delimiters '\t' >> temp_div.txt
done

# Clean up and prepare the final diversity file
awk 'NR>1' temp_div.txt > pop_div.txt

# Open R for plotting
## Install necessary R libraries if not already installed
# install.packages(c("tidyverse"))

library(tidyverse)

# Read the diversity data into R
data <- read_delim("pop_div.txt", delim = "\t", col_names = FALSE)
colnames(data) <- c("pop", "pi")

# Plot nucleotide diversity using boxplot
ggplot(data, aes(x = pop, y = pi, fill = pop)) +
  geom_boxplot() +
  theme_classic() +
  scale_fill_manual(values = c("red", "grey", "seagreen3")) +
  scale_x_discrete(labels = c("eastAndes", "westAndes", "Dry_Pacific"))
