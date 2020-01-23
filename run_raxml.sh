### First you have to filter your vcf for
module load vcftools/0.1.16

vcftools --vcf <your_vcf> --max-missing 0.55 --mac 3 --recode --recode-INFO-all --out <your_filtered_vcf>

#then trnsform that vcf to phylip using the vcf2phylip.py script obtained from: https://github.com/edgardomortiz/vcf2phylip/blob/master/vcf2phylip.py

python vcf2phylip.py --input <your_filtered_vcf>

###With obteined phylyip your have to implemet a correction to the branch length, prepare the input using this script
module load py34-biopython/1.71

module load python3.6/3.6.6

module swap py3-numpy py36-numpy/1.14.2

python3 ascbias.py -p polythore_filtered.min4.recode.min4.phy

##run RAxML

raxmlHPC-PTHREADS -T 30 -f a -# 100 -m ASC_GTRGAMMA --asc-corr=lewis -p 12345 -x 12345 -s variable_sites.phy -n polythore_tree.tre

####change the tips names using the key files given by snpsaurus

for i in $(cut -f 1 new_key.txt);do
x=$(grep $i new_key.txt | cut -f 2)
sed -i "s/$i/$x/g" RAxML_bipartitions.polythore_tree.tre;
done

####useful filtering command in vcftools

vcftools --vcf <your.vcf> --missing-indv

mawk '$5 > 0.5' <your.vcf> | cut -f1 > lowDP.indv

vcftools --vcf <your.vcf> --remove lowDP.indv --recode --recode-INFO-all --out remove_filtered
