cat loci.txt | while read loci;
do end=$(echo $loci | sed -E 's/\w+\_(\w+)/\1/g')
beg=$(grep -B 800 $end data2.loci | grep -Eo "\|\w+\|" | tail -n 2 | awk 'NR==1' | sed -E 's/\|//g')
grep -B 800 $end data2.loci | awk  '/'$beg'/{flag=1;next}/'$end'/{flag=0}flag' > fastas/"$loci".fas; done 
