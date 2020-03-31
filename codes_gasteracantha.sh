for i in $(cat new_key.txt);
do s=$(grep -E "$i" new_key.txt | cut -f 2)
n=$(grep -E "^$s\_" codes.txt)
sed -i -E "s/(\s)$i$/\1$n/g" new_key2.txt; done
