##before starting maybe you want to change your samples' names, for that, you need to jhave a key file, such as new_key.txt

for i in $(cat new_key.txt);
do s=$(grep $i new_key.txt | cut -f 1)
n=$(grep $i new_key.txt | cut -f 2)
sed -i -r "s/\w+\_$s\_\w+_\w+/$n/g" 090_filtered.vcf; done #look that I'm using some regular expressions here, this is not necessary in all the cases

### First you have to filter your vcf for variants that have been succsfully genoetyped in 50% of individuals (--max-missing 0.50) and fileter SNPs that have a minor allele count less than 3 (--mac 3)
module load vcftools/0.1.16

vcftools --vcf <your_vcf> --max-missing 0.50 --mac 3 --recode --recode-INFO-all --out <your_filtered_vcf>

#If you want to filter individuals with high missing data

#Check the amount of missing data across your samples, look the out.imiss file genetated

vcftools --vcf <your_vcf> --missing-indv

#Remove individuals with missing data higher that 50%

awk '$5 > 0.5' out.imiss | cut -f1 > lowDP.indv

vcftools --vcf <your_vcf> --remove lowDP.indv --recode --recode-INFO-all --out <your_filtered_vcf>
