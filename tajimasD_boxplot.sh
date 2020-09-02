vcftools --vcf polythore_popgen.vcf --missing-indv
cut -f 1 -d "_" out.imiss| sort | uniq > pops.txt
touch total_tajima.txt
cat pops.txt | while read pop; 
do grep -oE "$pop\w+" out.imiss > $pop.txt
vcftools --vcf polythore_popgen.vcf --TajimaD 150 --keep $pop.txt --out $pop
R -e "tabla<-read.table('$pop.Tajima.D',head=T); taj<-tabla[,4]; pop<-rep('$pop',length(taj));tem<-data.frame(pop,taj);write.table(tem,file='$pop.box',col.names=F,row.names=F)"
cat $pop.box >> total_tajima.txt; done

##Open R to plot TajimasD
library(ggplot2)
tabla<-read.table("tem_tajima.txt",head=F)
col<-read.table("../../paleta_colores.txt",head=F)
col<-col[order(col$V1),]
pdf("tajimasD.pdf",height=15,width=20)
ggplot(tabla,aes(x=V1,y=V2,fill=V1))+geom_boxplot()+scale_fill_manual(values=as.character(col$V2))+scale_x_discrete(name="Species")+scale_y_continuous(name="Tajima's D",limits=c(-3,4))+theme_classic()
dev.off()




