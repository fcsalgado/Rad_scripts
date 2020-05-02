cat loci.txt | while read loci;
do end=$(echo $loci | sed -E 's/\w+\_(\w+)/\1/g')
beg=$(grep -B 800 $end data2.loci | grep -Eo "\|\w+\|" | tail -n 2 | awk 'NR==1' | sed -E 's/\|//g')
grep -B 800 $end data2.loci | awk  '/'$beg'/{flag=1;next}/'$end'/{flag=0}flag' | sed -E 's/\s+/\t/g' > "$loci".tmp
nseq=$(wc -l "$loci".tmp | cut -f 1 -d " ")
nom=$(cut -f 1 "$loci".tmp)
seque=$(cut -f 2 "$loci".tmp | awk 'NR==1')
for x in $(echo $nom); 
do rep=$(grep "$x" ~/Documents/Gasteracantha_files/new_key2.txt | cut -f 2)
sed -i "s/$x/$rep/g" "$loci".tmp; done
echo "$nseq" "\t" "${#seque}" > head.tmp 
cat head.tmp "$loci".tmp > sequences/"$loci".phy
rm -f "$loci".tmp
rm -f head.tmp; done 
