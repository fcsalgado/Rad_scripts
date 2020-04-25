cut -f 1 popgen.vcf| grep "locus" | sort | uniq  > loci.txt

echo "locus size" > size_loci.txt
cat loci.txt | while read loci;
do in=$(echo $loci | sed -E 's/\w+\_(\w+)/|\1|/g')
s=$(grep -B 1 $in polythore.loci | awk 'NR==1'| tr -s ' ' | cut -f 2 -d " ")
echo "$loci ${#s}" >> size_loci.txt; done 
