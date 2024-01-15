#!/bin/bash

# Specify the number of parallel processes
N=10

# Step 1: Iterate through 100 random VCF files
for k in $(seq 1 100); do
    # Avoid race condition by limiting the number of parallel processes
    ((i=i%N)); ((i++==0)) && wait

    # Step 2: Run easySFS.py on each random VCF file
    python3 easySFS.py -i random_$k.vcf -p fivepops_sorted.txt --ploidy 2 --proj 20,34,15,10,35 -f -o random_$k
done
