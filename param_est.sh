#!/bin/bash
#SBATCH -p dev # Partición (cola)
#SBATCH -N 1 # Número de nodos
#SBATCH -n 30 # Número de núcleos
#SBATCH -t 29-23:00 # Límite de tiempo (D-HH:MM)
#SBATCH -o salida2.out # Salida STDOUT
#SBATCH -e error.err # Salida STDERR
# mail alert at start, end and abortion of execution
#SBATCH --mail-type=ALL

# send mail to this address
#SBATCH --mail-user=fabianc.salgado@urosario.edu.co

module load parallel

srun="srun --exclusive -N1 -n1"
for i in {1..100}
do
  mkdir sfs"$i"
  cp all_SFS/random_"$i"_MSFS.obs sfs"$i/"polythore_8_MSFS.obs
  cp polythore_8* sfs"$i/"
  cd sfs"$i"
  for r in {1..100}; do
  cp polythore_8_MSFS.obs run"$r"_MSFS.obs
  cp polythore_8.tpl run"$r".tpl
  cp polythore_8.est run"$r".est; done
  parallel "$srun /home/fabianc.salgado/shared/polythore_total/new_data/final_analysis/model_selection/fsc26_linux64/fsc26 -t run{1}.tpl -e run{1}.est -m -n 10000 -L 40 --multiSFS -x -M" ::: {1..100}
  cd ..; done
