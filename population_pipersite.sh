cut -f 1 -d "_" out.imiss| sort | uniq > pops.txt
touch tem_div.txt
cat pops.txt | while read pop; 
do grep -oE "$pop\w+" out.imiss > $pop.txt
vcftools --vcf polythore_popgen.vcf --site-pi --keep $pop.txt --out $pop
R -e "tabla<-read.table('$pop.sites.pi',head=T); pi<-tabla[,3]; pi_media<-mean(na.omit(pi));print(pi_media)" | grep -oE "\0\.\w+" >> tem_div.txt; done
paste pops.txt tem_div.txt > vcftools_nucdiv.txt
