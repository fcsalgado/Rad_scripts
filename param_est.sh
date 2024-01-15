#!/bin/bash
#SBATCH -p normal       # Specify the partition (queue)
#SBATCH -N 1            # Number of nodes
#SBATCH -n 30           # Number of cores
#SBATCH -t 29-23:00     # Time limit (D-HH:MM)
#SBATCH -o salida2.out  # STDOUT output file
#SBATCH -e error.err    # STDERR output file
#SBATCH --mail-type=ALL # Send email alerts for all events

# Send mail to this address
#SBATCH --mail-user=fabianc.salgado@urosario.edu.co

# Load the 'parallel' module
module load parallel

# Define srun command with exclusive node usage
srun="srun --exclusive -N1 -n1"

# Iterate through simulations from 78 to 100
for i in {1..100}
do
  # Create a directory for each simulation
  mkdir sfs"$i"
  
  # Copy MSFS file and related files to the simulation directory
  cp all_SFS/random_"$i"_MSFS.obs sfs"$i/"gasteracantha_five_90_MSFS.obs
  cp gasteracantha_five_90* sfs"$i/"
  
  # Change directory to the simulation folder
  cd sfs"$i"
  
  # Create 100 copies of MSFS file, tpl file, and est file
  for r in {1..100}; do
    cp gasteracantha_five_90_MSFS.obs run"$r"_MSFS.obs
    cp gasteracantha_five_90.tpl run"$r".tpl
    cp gasteracantha_five_90.est run"$r".est
  done
  
  # Run fsc26 for each simulation in parallel
  parallel "$srun /home/fabianc.salgado/shared/polythore_total/new_data/final_analysis/model_selection/fsc26_linux64/fsc26 -t run{1}.tpl -e run{1}.est -m -n 100000 -L 40 --multiSFS -x -M" ::: {1..100}
  
  # Change back to the parent directory
  cd ..
done
