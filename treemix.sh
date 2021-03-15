###Transform yo vcf to plink 
vcftools --vcf polythore_treemix.vcf --plink --out polythore_plink
###Tranform your ped file to assign family (species/population) categories
cut -f 1 --complement polythore_plink.ped > tem.txt
cut -f 1 polythore_plink.ped | cut -d "_" -f 1 > family.txt
paste family.txt tem.txt > polythore_plink.ped
##Create your bed file
plink --file polythore_plink --make-bed --out polythore_plink
#Calculate SNP frecuencies per population
plink -bfile polythore_plink --freq --missing --family
##Gzip the output
gzip plink.frq.strat
##Create your input for treemix
python2 /home/fabian/software/treemix-1.13/src/plink2treemix.py plink.frq.strat.gz treemix_input.frq.gz
##Now run treemix
#Generate a common topology
/home/fabian/software/treemix-1.13/src/./treemix -i treemix_input.frq.gz -root mutata -o out_topology
#bootstrapt over this topology (optional)
/home/fabian/software/treemix-1.13/src/./treemix -i treemix_input.frq.gz -root mutata -bootstrap -k 100 -o out_topology
##you have to cover a range of possible migration events, lets test fo 1 to 6
for i in in $(echo {1..10}); do
for m  in $(echo {1..6});  
do /home/fabian/software/treemix-1.13/src/./treemix -i treemix_input.frq.gz -m $m -g out_topology.vertices.gz out_topology.edges.gz -o out_migration"$m"_"$i";done;done

##After this open the R package OptM an run the following lineto select the best migration edge

optM(".", tsv = NULL, method = "Evanno", thresh = 0.05)

##Explore the llik files to look for the best value of m, the open R and plot the result
source("/home/fabian/software/treemix-1.13/src/plotting_funcs.R")
plot_tree("out_migration1")

