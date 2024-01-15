#!/bin/bash
#SBATCH -p normal # Partition (queue)
#SBATCH -N 1 # Number of nodes
#SBATCH -n 30 # Number of cores
#SBATCH -t 29-23:00 # Time limit (D-HH:MM)
#SBATCH -o salida2.out # STDOUT output
#SBATCH -e error.err # STDERR output
# Mail alert at start, end, and abortion of execution
#SBATCH --mail-type=ALL

# Send mail to this address
#SBATCH --mail-user=fabianc.salgado@urosario.edu.co

# Load GDAL module version 3.2.1
module load gdal/3.2.1

# Create a directory for analysis tables
mkdir tables_analyses

# Edit so that no data value is either -999 or -9999
gdalwarp -dstnodata -9999 variables/kernel.tif variables/kernel_noNA.tif

# Extract values at specified coordinates for different variables
cat coords_m.txt | gdallocationinfo -valonly -wgs84 variables/Alt.tif > tables_analyses/alt.txt
cat coords_m.txt | gdallocationinfo -valonly -wgs84 variables/Bio18.tif > tables_analyses/Bio18.txt
cat coords_m.txt | gdallocationinfo -valonly -wgs84 variables/Bio15.tif > tables_analyses/Bio15.txt
cat coords_m.txt | gdallocationinfo -valonly -wgs84 variables/Bio2.tif > tables_analyses/Bio2.txt
cat coords_m.txt | gdallocationinfo -valonly -wgs84 variables/Bio3.tif > tables_analyses/Bio3.txt
cat coords_m.txt | gdallocationinfo -valonly -wgs84 variables/kernel_noNA.tif > tables_analyses/kernel.txt
cat coords_m.txt | gdallocationinfo -valonly -wgs84 variables/Probability.tif > tables_analyses/niche.txt
