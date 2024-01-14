# Pipeline for data processing by Fabian Salgado

# Remove duplicates from the VCF file
LC_ALL=C sort -t $'\t' -k1,1 -k2,2n -k4,4 <your_vcf> | awk -F '\t' '/^#/ {print; prev=""; next;} {key=sprintf("%s\t%s\t%s",$1,$2,$4); if(key==prev) next; print; prev=key;}' > no_duplicates.vcf

# Use plink to create input for admixture
plink --vcf no_duplicates.vcf --double-id --allow-extra-chr --set-missing-var-ids @:# --indep-pairwise 50 10 0.1 --out intermediate_file --vcf-idspace-to "-"

# Prune the sites
plink --vcf no_duplicates.vcf --double-id --allow-extra-chr --set-missing-var-ids @:# --extract intermediate_file.prune.in --make-bed --out unlinked_data --vcf-idspace-to "-"

# If your VCF is the output of random_snps_rad.sh, use the following lines
plink --vcf random_vcf.vcf --double-id --allow-extra-chr --make-bed --out gasteracantha --vcf-idspace-to "-"

# After choosing your best K, run the following for fastStructure
for K in $(seq 1 15); do python structure.py -K $K --input=gasteracantha --output=gasteracantha_out; done

# Choose best K

python chooseK.py --input=gasteracantha_out > bestK.txt

# Transform bim file back to VCF
plink --bfile gasteracantha --double-id --allow-extra-chr --set-missing-var-ids @:# --recode vcf --out filter_linked.vcf

# Run fineRADstructure
~/software/fineRADstructure/./RADpainter hapsFromVCF ../vcf/polythore_popgen.vcf > polythore_popgene_input.txt
~/software/fineRADstructure/./RADpainter paint polythore_popgene_input.txt
~/software/fineRADstructure/./finestructure -x 100000 -y 1000000 -z 1000 polythore_popgene_input_chunks.out polythore_popgene_input_chunks.mcmc.xml
~/software/fineRADstructure/./finestructure -m T -x 10000 polythore_popgene_input_chunks.out polythore_popgene_input_chunks.mcmc.xml polythore_popgene_input_chunks.mcmcTree.xml

# To plot the result, please use the R function found at https://cichlid.gurdon.cam.ac.uk/fineRADstructure.html

# If you prefer to run admixture run this: 

# Run admixture
sed -i 's/_//g' gasteracantha.bim
sed -i 's/locus//g' gasteracantha.bim
for K in $(seq 1 15); do admixture --cv=10 gasteracantha.bed $K | tee log${K}.out; done

# Choose the best K
for i in $(ls log*); do grep "K=" $i | cut -f 3,4 -d " " | sed -r 's/\((\K)\=(\w+)\)\:/\1\2/g' >> bestk.txt; done
cut -f 2 -d "K" bestk.txt | sort -k1,1n > bestk_sorted.txt
