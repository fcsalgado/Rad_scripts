##before starting maybe you want to change your samples' names, for that, you need to jhave a key file, such as new_key.txt

for i in $(cat new_key.txt);
do s=$(grep $i new_key.txt | cut -f 1)
n=$(grep $i new_key.txt | cut -f 2)
sed -i -r "s/\w+\_$s\_\w+_\w+/$n/g" 090_filtered.vcf; done #look that I'm using some regular expressions here, this is not necessary in all the cases
######
for i in $(cut -f 1 out.imiss);        
do s=$(echo "$i" | sed -E 's/(\w+)_sorted/\1/g')
n=$(grep -E "_$s$" spider_key2.txt)
sed -iE "s/\t$i\t/\t$n\t/g" head.txt ; done
#######

### Step 1: Filter VCF for variants with successful genotyping, a minor allele count ≥ 3, and a minimum quality of 30.

module load vcftools/0.1.16
vcftools --vcf <your_vcf> --max-missing 0.70 --mac 3 --minQ 30 --recode --recode-INFO-all --out <your_filtered_vcf1>

### Step 2: Remove indels and non-bi-allelic variants.

vcftools --vcf <your_filtered_vcf1> --recode --min-alleles 2 --max-alleles 2 --remove-indels --recode-INFO-all --out <your_filtered_vcf2>

### Optional: Filter individuals with high missing data (>50%).

# Check missing data across samples.
vcftools --vcf <your_filtered_vcf2> --missing-indv

# Remove individuals with missing data >50%.
awk '$5 > 0.5' out.imiss | cut -f1 > lowDP.indv
vcftools --vcf <your_filtered_vcf2> --remove lowDP.indv --recode --recode-INFO-all --out <your_filtered_vcf3>

### Step 3: Further filter for high-quality SNPs (90% call rate, 0.05 MAF, and mean depth of genotypes ≥ 10).

vcftools --vcf <your_filtered_vcf3> --max-missing 0.95 --maf 0.05 --min-meanDP 10 --recode --recode-INFO-all --out <your_filtered_vcf4>

### Step 4: Filter by Hardy-Weinberg Equilibrium (HWE) and create a new VCF.

vcftools --vcf <your_filtered_vcf3> --hwe 0.05 --recode --out <vcf_hwe_snps>

### Step 5: Select one SNP per tag (use random_snp.sh script) and convert VCF to Plink format.

vcftools --vcf <vcf_hwe_snps> --plink --out <plink_hwe>
plink --file <plink_hwe> --make-bed --out <plink_for_admixture>

