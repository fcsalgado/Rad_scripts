ls *.tpl | sed "s/.tpl//g" | while read modelo; do
mkdir $modelo 
cp $modelo.tpl $modelo.est "$modelo"_MSFS.obs $modelo
cd $modelo
for i in {1..100}
do
  mkdir run$i
  cp $modelo.tpl $modelo.est "$modelo"_MSFS.obs run$i"/"
  cd run$i
  ~/software/fsc26_linux64/./fsc26 -t $modelo.tpl -e $modelo.est -m -n 200000 -L 40 --multiSFS -x -M -c 30
  cd ..
done 
cd ..
done
