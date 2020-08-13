##before starting maybe you want to change your samples' names, for that, you need to jhave a key file, such as new_key.txt

for i in $(cat new_key.txt);
do s=$(grep $i new_key.txt | cut -f 1)
n=$(grep $i new_key.txt | cut -f 2)
sed -i -r "s/\w+\_$s\_\w+_\w+/$n/g" 090_filtered.vcf; done #look that I'm using some regular expressions here, this is not necessary in all the cases

### First you have to filter your vcf for variants that have been succsfully genoetyped in 70% of individuals (--max-missing 0.70) and fileter SNPs that have a minor allele count less than 3 (--mac 3), and a limit leave just quality SNPs --minQ 30
module load vcftools/0.1.16

vcftools --vcf <your_vcf> --max-missing 0.70 --mac 3 --minQ 30 --recode --recode-INFO-all --out <your_filtered_vcf1>

##Remove indels or variants that are not bi-allelic --min-alleles 2 --max-alleles 2 and --remove-indels

vcftools --vcf <your_filtered_vcf1> --recode --min-alleles 2 --max-alleles 2 --remove-indels --recode-INFO-all --out <your_filtered_vcf2>

#If you want to filter individuals with high missing data

#Check the amount of missing data across your samples, look the out.imiss file genetated

vcftools --vcf <your_filtered_vcf2> --missing-indv

#Remove individuals with missing data higher that 50%

awk '$5 > 0.5' out.imiss | cut -f1 > lowDP.indv

vcftools --vcf <your_filtered_vcf2> --remove lowDP.indv --recode --recode-INFO-all --out <your_filtered_vcf3>

###If you want to keep high quality snps, restrict the data to variants called in a high percentage of individuals (say 90%), minor allele frequency (0.05) and filter by mean depth of genotypes (20)

vcftools --vcf <your_filtered_vcf3> --max-missing 0.95 --maf 0.05 --min-meanDP 20 --recode --recode-INFO-all  --out <your_filtered_vcf4>

#Create a new VCF for your admixture or structure analysis 

##Filter by hwe

vcftools --vcf <your_filtered_vcf3> --hwe 0.05 --recode --out <vcf_hwe_snps>

##Remember to select one snps per tag, for that you have to run the random_snp.sh script ;)
##Convert your VCF to plink

vcftools --vcf <vcf_hwe_snps> --plink --out <plink_hwe>

##

plink --file <plink_hwe> --make-bed --out <plink_for_admixture>
