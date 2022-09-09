#!/bin/bash
N=10
#select randon one nucleotide
for k in $(echo {1..100}); do
((i=i%N)); ((i++==0)) && wait
python3 easySFS.py -i random_$k.vcf -p fivepops_sorted.txt --ploidy 2 --proj 20,34,15,10,35 -f -o random_$k; done
