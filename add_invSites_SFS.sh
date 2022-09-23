#run this script within vcfs folder
#Let's create the header for all the SFS
awk 'NR<3' random_"$k"/fastsimcoal2/random_"$k"_MSFS.obs > ../all_SFS/header.txt
for k in $(echo {1..100}); do 
	((i=i%N)); ((i++==0)) && wait
	first=$(awk -F " " 'NR==3 {print $1}' random_"$k"/fastsimcoal2/random_"$k"_MSFS.obs)
	inv_sites=$(python -c "print($first+75000)") ##Add the invaribale sites
	paste <(echo $inv_sites) <(awk 'NR==3' random_"$k"/fastsimcoal2/random_"$k"_MSFS.obs | cut -d " " -f 2-) --delimiters ' ' >> ../all_SFS/body.txt
	cat ../all_SFS/header.txt ../all_SFS/body.txt > ../all_SFS/random_"$k"_MSFS.obs
	rm ../all_SFS/body.txt; done
