#!/bin/bash

# Run this script within the vcfs folder

# Step 1: Create the header for all the SFS
awk 'NR<3' random_"$k"/fastsimcoal2/random_"$k"_MSFS.obs > ../all_SFS/header.txt

# Specify the number of parallel processes
N=10

# Step 2: Iterate through 100 random simulations
for k in $(seq 1 100); do 
    # Avoid race condition by limiting the number of parallel processes
    ((i=i%N)); ((i++==0)) && wait

    # Step 3: Extract information and add invariable sites
    first=$(awk -F " " 'NR==3 {print $1}' random_"$k"/fastsimcoal2/random_"$k"_MSFS.obs)
    inv_sites=$(python -c "print($first+75000)") ## Add the invariable sites, calculate this carefully considering the number of snps and size of the tags used

    # Step 4: Paste the information to the body file
    paste <(echo $inv_sites) <(awk 'NR==3' random_"$k"/fastsimcoal2/random_"$k"_MSFS.obs | cut -d " " -f 2-) --delimiters ' ' >> ../all_SFS/body.txt

    # Step 5: Combine header and body to create the final MSFS.obs file
    cat ../all_SFS/header.txt ../all_SFS/body.txt > ../all_SFS/random_"$k"_MSFS.obs

    # Step 6: Clean up temporary body file
    rm ../all_SFS/body.txt
done
