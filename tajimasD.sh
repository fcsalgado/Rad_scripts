# Calculate missing data per individual in the VCF file
vcftools --vcf <your_input_vcf> --missing-indv

# Create an intermediate file for Tajima's D calculation
touch temp_diversity.txt

# Process each population in the VCF
cut -f 1 -d "_" out.imiss | sort | uniq | while read pop; 
do 
  grep -E "$pop" out.imiss | cut -f 1 > $pop.txt
  vcftools --vcf common_tags.vcf --TajimaD 150 --keep $pop.txt --out $pop
  num=$(awk 'NR>1' $pop.Tajima.D | wc -l)
  paste <(echo "$(printf "$pop\n%.0s" {1..$num})") <(echo "$(cut -f 4 $pop.Tajima.D | awk 'NR >1')") --delimiters '\t' >> temp_diversity.txt
done

## Open R to plot Tajima's D
library(tidyverse)

# Read the intermediate file into R
data <- read_delim("temp_diversity.txt", col_names = FALSE)
names(data) <- c("tag", "value", "pop")

# Define population levels and color palette
levels <- c("beata", "mutata", "spnov2", "concinna", "spnov1", "procera", "gigantea", "terminata", "derivata", "ornata", "neopicta", "victoria")
data$pop <- factor(data$pop, levels = levels, ordered = TRUE)
palette1 <- c("#00802a", "#e8d479", "#d82567", "#ff72ce", "#536200", "#00ddcb", "#002277", "#ff9a7c", "#95e790", "#cf6c0f", "#4b64db", "#7a002d")

# Plot Tajima's D values
ggplot(data, aes(pop, value, fill = pop)) +
  geom_point(shape = 21, size = 2, position = position_jitter(width = .05), alpha = 0.75) +
  geom_violin(alpha = 0.4, position = position_dodge(width = .75), size = 1) +
  geom_boxplot(outlier.size = -1, lwd = 1.2, alpha = 0.7) +
  scale_fill_manual(values = palette1) +
  scale_colour_manual(values = palette1) +
  theme_classic()
