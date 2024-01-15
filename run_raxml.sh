# Script for Transforming VCF to Phylip Format, Correcting Branch Lengths, and Running RAxML

## Note: Ensure that the required software (python, RAxML) is installed and available in your PATH.

# Transform VCF to Phylip using vcf2phylip.py script
# Note: Obtain the vcf2phylip.py script from https://github.com/edgardomortiz/vcf2phylip/blob/master/vcf2phylip.py
python ~/shared/polythore_total/old_plate/scripts/vcf2phylip.py --input <your_filtered_vcf>

# Implement a correction to the branch length using ascbias.py script
# Note: Obtain the ascbias.py script from https://github.com/btmartin721/raxml_ascbias/tree/d13d6eee640b732c0529c9c94cd99cd8838d9b7a
# Note: Ascertain the correct path to the ascbias.py script
module load py34-biopython/1.71
module load python3.6/3.6.6
module swap py3-numpy py36-numpy/1.14.2

python3 ~/shared/polythore_total/old_plate/scripts/ascbias.py -p polythore_filtered.min4.recode.min4.phy

# Run RAxML for phylogenetic analysis
raxmlHPC-PTHREADS -T 30 -f a -# 100 -m ASC_GTRGAMMA --asc-corr=lewis -p 12345 -x 12345 -s variable_sites.phy -n polythore_tree.tre
