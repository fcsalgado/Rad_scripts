for i in $(cat spider_key.txt);
do s=$(grep -E "$i" spider_key.txt| awk 'NR==1' | cut -f 2)
w=$(grep -E "$i" spider_key.txt | awk 'NR==1'| cut -f 1)
n=$(grep -E "\_$s$" spider_key2.txt)
sed -i "s/$w/$n/g" cabeza.txt ; done
